#' Estimate the Belief for Policy Graph Nodes
#'
#' Estimate a belief for each alpha vector (segment of the value function) which represents
#' a node in the policy graph.
#'
#' `estimate_belief_for_nodes()` can estimate the belief in several ways:
#' 1. **Use belief points explored by the solver.** Some solvers return explored belief points.
#'   We assign the belief points to the nodes and average each nodes belief.
#' 2. **Follow trajectories** (breadth first) till all policy graph nodes have been visited and
#'   return the encountered belief. This implementation returns the first (i.e., shallowest) belief point
#'   that is encountered is used and no averaging is performed. parameter `n` can be used to
#'   limit the number of nodes searched.
#' 3. **Sample a large set** of possible belief points, assigning them to the nodes and then averaging
#'   the belief over the points assigned to each node. This will return a central belief for the node.
#'   Additional parameters like `method` and the sample size `n` are passed on to [sample_belief_space()].
#'   If no belief point is generated for a segment, then a
#'   warning is produced. In this case, the number of sampled points can be increased.
#'
#' **Notes:**
#' * Each method may return a different answer. The only thing that is guaranteed is that the returned belief falls
#'   in the range where the value function segment is maximal.
#' * If some nodes not belief points are sampled, or the node is not reachable from the initial belief,
#'   then a vector with all `NaN`s will be returned with a warning.
#'
#' @family policy
#'
#' @param x object of class [POMDP] containing a solved and converged POMDP problem.
#' @param method character string specifying the estimation method. Methods include
#'  `"auto"`, reuse `"solver_points"`, follow `"trajectories"`, sample `"random_sample"`
#'  or `"regular_sample"`. Auto uses
#'  solver points if available and follows trajectories otherwise.
#' @param belief start belief used for method trajectories. `NULL` uses the start belief specified in the model.
#' @param verbose logical; show which method is used.
#' @param ... parameters are passed on to `sample_belief_space()` or the code that follows trajectories.
#'
#' @returns
#' returns a list with matrices with a belief for each policy graph node. The list elements are the epochs and converged solutions
#' only have a single element.
#'
#' @examples
#' data("Tiger")
#'
#' # Infinite horizon case with converged solution
#' sol <- solve_POMDP(model = Tiger, method = "grid")
#' sol
#'
#' # default method auto uses the belief points used in the algorithm (if available).
#' estimate_belief_for_nodes(sol, verbose = TRUE)
#' 
#' # use belief points obtained from trajectories  
#' estimate_belief_for_nodes(sol, method = "trajectories", verbose = TRUE)
#' 
#' # use a random uniform sample 
#' estimate_belief_for_nodes(sol, method = "random", verbose = TRUE)
#'
#' # Finite horizon example with three epochs. 
#' sol <- solve_POMDP(model = Tiger, horizon = 3)
#' sol
#' estimate_belief_for_nodes(sol)
#' @export
estimate_belief_for_nodes <-
  function(x,
    method = "auto",
    belief = NULL,
    verbose = FALSE,
    ...) {
    method <-
      match.arg(
        method,
        choices = c(
          "auto",
          "solver_points",
          "trajectories",
          "random_sample",
          "regular_sample"
        )
      )
    
    is_solved_POMDP(x, stop = TRUE)
    
    .aggregate_beliefs <- function(belief_points, alpha) {
      r <- .rew(belief_points, alpha)
      ind <-
        split(seq_len(nrow(belief_points)), f = factor(r$pg_node, levels = seq_len(nrow(alpha))))
      t(sapply(
        ind,
        FUN = function(i)
          colMeans(belief_points[i, , drop = FALSE], na.rm = TRUE)
      ))
    }
    
    if (method == "auto") {
      if (!is.null(x$solution$belief_points_solver))
        method <- "solver_points"
      else
        method <- "trajectories"
    }
    
    if (verbose)
      cat("Using method", sQuote(method), "\n")
    
    # default checks if the solver already provides belief states, if not it uses trajectories
    if (method == "solver_points") {
      if (is.null(x$solution$belief_points_solver))
        stop("No solver belief points available in the solution.")
      belief <-
        lapply(
          x$solution$alpha,
          FUN = function(a)
            .aggregate_beliefs(x$solution$belief_points_solver, a)
        )
    }
    
    if (method == "trajectories") {
      belief <-
        .estimate_belief_for_nodes_trajectories(x, belief = belief, verbose = verbose, ...)
    }
    
    # use sampling
    if (method == "random_sample")
      method <- "random"
    if (method == "regular_sample")
      method <- "regular"
    if (is.null(belief)) {
      belief <-
        lapply(
          x$solution$alpha,
          FUN = function(a)
            .aggregate_beliefs(sample_belief_space(x, method = method, verbose = verbose, ...),
              a)
        )
    }
    
    # converged solutions return a matrix
    # unconverged solutions return a list
    if (verbose) 
      if (!is.list(belief) &&
          (nrow(belief) < nrow(x$solution$pg[[1L]]) ||
              any(is.na(belief))) ||
          is.list(belief) &&
          any(sapply(
            belief,
            FUN = function(b)
              any(is.na(b))
          )))
        warning(
          "estimate_belief_for_nodes: No belief points found for some policy graph nodes. You can change the estimation method or increase n. The nodes may also be not reachable or redundant."
        )
    
    belief
  }


## find a belief state for each alpha vector by DFS of the trajectories 
##
## TODO: 
## * reimplement in C++
.estimate_belief_for_nodes_trajectories <-
  function(x,
    belief = NULL,
    n = 100000L,
    verbose = FALSE,
    ...) {
    
    if (verbose)
      x <- normalize_POMDP(x)
    
    if (.has_policy_tree(x))
      return(.estimate_belief_for_nodes_trajectories_tree(x, belief = belief, n = n, verbose = verbose, ...))
    
    ## policy graph
    
    pg <- x$solution$pg[[1]]
    found <- logical(nrow(pg)) ### all are FALSE
    a_belief <-
      matrix(NA, nrow = nrow(pg), ncol = length(x$states))
    
    if (verbose)
      cat("Using policy graph trajectories to find beliefs for nodes.\n\n")
    
    # start with the initial belief and mark it found
    if (is.null(belief))
      belief <- start_vector(x)
    #queue <- new.queue()
    #enqueue(queue,  belief)
    frontier <- new.stack()
    push.stack(frontier, belief)
    
    tries <- n
    while (!all(found)) {
      tries <- tries - 1L
      if (tries < 0L) {
        warning("Maximal search tries n = ", n, " reached. Increase n.")
        break
      }
      
      #if (queue.empty(queue))
      if (empty.stack(frontier))
        break
        
      #belief_state <- dequeue(queue)
      belief_state <- pop.stack(frontier)
      rna <- reward_node_action(x, belief_state)
      
      # check if we already have a belief for the associated alpha vector.
      if (found[rna$pg_node])
        next
      
      a_belief[rna$pg_node,] <- rna$belief
      found[rna$pg_node] <- TRUE
      if (verbose)
        cat("\b\rFound", sum(found), "of", length(found), "\n")
        
      # go down the tree
      belief_states <- update_belief(x, belief_state)
      
      # skip impossible states and duplicates
      belief_states <- stats::na.omit(belief_states)
      belief_states <-
        belief_states[!duplicated(belief_states), , drop = FALSE]
      
      for (i in seq_len(nrow(belief_states)))
        #enqueue(queue, belief_states[i, , drop = TRUE])
        push.stack(frontier, belief_states[i, , drop = TRUE])
    }
    
    #delete.queue(queue)
    delete.stack(frontier)
    
    # if (!all(found))
    #   warning("The following states are not reachable from the start state: ", paste(which(!found), collapse = ", "), 
    #     "\n belief for these states is 'NA'")
    
    colnames(a_belief) <- x$states
    list(a_belief)
  }


.estimate_belief_for_nodes_trajectories_tree <-
  function(x,
    belief = NULL,
    n = 100000L,
    verbose = FALSE,
    ...) {
    if (verbose)
      cat("Using policy tree trajectories to find beliefs for nodes.\n\n")
    
    a_belief <- lapply(
      x$solution$pg,
      FUN = function(pg)
        matrix(NA, nrow = nrow(pg), ncol = length(x$states))
    )
    
    ### all are FALSE
    found <-
      lapply(
        x$solution$pg,
        FUN = function(pg)
          logical(nrow(pg))
      )
    
    total <- sum(sapply(found, length))
    
    # start with the initial belief and mark it found
    if (is.null(belief))
      belief <- start_vector(x)
    epoch <- 1L
    
    #queue <- new.queue()
    #enqueue(queue,  )
    frontier <- new.stack()
    push.stack(frontier, list(belief = belief, epoch = epoch))
    
    tries <- n
    while (!all(unlist(found))) {
      tries <- tries - 1L
      if (tries < 0L) {
        warning("Maximal search tries n = ", n, " reached. Increase n.")
        break
      }
      
      #if (queue.empty(queue))
      if (empty.stack(frontier))
        break
      
      #be <- dequeue(queue)
      be <- pop.stack(frontier)
      belief_state <- be[[1]]
      epoch <- be[[2]]
      
      rna <- reward_node_action(x, belief_state, epoch = epoch)
      if (found[[epoch]][rna$pg_node])
        next
      
      a_belief[[epoch]][rna$pg_node,] <- rna$belief
      found[[epoch]][rna$pg_node] <- TRUE
      if (verbose)
        cat("\b\rFound", sum(sapply(found, sum)), "of", total, "\n")
      
      
      if (epoch >= sum(x$horizon))
        next
      
      # go down the tree and add to the queue
      belief_states <-
        update_belief(x, belief_state, episode = epoch_to_episode(x, epoch))
      
      # skip impossible states and duplicates
      belief_states <- stats::na.omit(belief_states)
      belief_states <-
        belief_states[!duplicated(belief_states), , drop = FALSE]
      
      for (i in seq_len(nrow(belief_states)))
        #enqueue(queue, list(belief = belief_states[i, , drop = TRUE], epoch = epoch + 1L))
        push.stack(frontier, list(belief = belief_states[i, , drop = TRUE], epoch = epoch + 1L))
    }
    
    #delete.queue(queue)
    delete.stack(frontier)
    
    # if (!all(unlist(found)))
    #   warning("The following states are not reachable from the start state: ", paste(which(!unlist(found)), collapse = ", "), 
    #     "\n The returned belief for these states is 'NA'")
    
    for (i in seq_along(a_belief))
      colnames(a_belief[[i]]) <- x$states
    a_belief
  }