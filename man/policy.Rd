% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/policy.R
\name{policy}
\alias{policy}
\title{Extract the Policy from a POMDP/MDP}
\usage{
policy(x, alpha = TRUE, action = TRUE)
}
\arguments{
\item{x}{A solved \link{POMDP} or \link{MDP} object.}

\item{alpha}{logical; include the parameters of the alpha vector defining the segment (POMDP only).}

\item{action}{logical; include the action for that segment (POMDP only).}
}
\value{
A list with the policy for each epoch.
}
\description{
Extracts the policy from a solved POMDP/MDP.
}
\details{
A list (one entry per epoch) with the optimal policy.
For converged, infinite-horizon problems solutions, a list with only the
converged solution is produced.
For a POMDP, the policy is a data.frame consisting of:
\itemize{
\item Part 1: The value function with one column per state (alpha vectors).
\item Part 2: The last column contains the prescribed action.
}

For an MDP, the policy is a data.frame consisting of:
\itemize{
\item The state
\item The state's discounted expected utility U if the policy is followed
\item The prescribed action
}
}
\examples{
data("Tiger")

# Infinite horizon
sol <- solve_POMDP(model = Tiger)
sol

# policy with value function, optimal action and transitions for observations.
policy(sol)
plot_value_function(sol)

# Finite horizon (we use incremental pruning because grid does not converge)
sol <- solve_POMDP(model = Tiger, method = "incprune", horizon = 3, discount = 1)
sol

policy(sol)
# Note: We see that it is initially better to listen till we make a decision in the final epoch.

# MDP policy
data(Maze)

sol <- solve_MDP(Maze)

policy(sol)
}
\seealso{
Other policy: 
\code{\link{estimate_belief_for_nodes}()},
\code{\link{optimal_action}()},
\code{\link{plot_belief_space}()},
\code{\link{plot_policy_graph}()},
\code{\link{policy_graph}()},
\code{\link{projection}()},
\code{\link{reward}()},
\code{\link{solve_POMDP}()},
\code{\link{solve_SARSOP}()},
\code{\link{value_function}()}
}
\author{
Michael Hahsler
}
\concept{policy}
\keyword{graphs}
