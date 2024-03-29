% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reward.R
\name{reward}
\alias{reward}
\alias{reward_node_action}
\title{Calculate the Reward for a POMDP Solution}
\usage{
reward(x, belief = NULL, epoch = 1, ...)

reward_node_action(x, belief = NULL, epoch = 1, ...)
}
\arguments{
\item{x}{a solved \link{POMDP} object.}

\item{belief}{specification of the current belief state (see argument start
in \link{POMDP} for details). By default the belief state defined in
the model as start is used. Multiple belief states can be specified as rows in a matrix.}

\item{epoch}{return reward for this epoch. Use 1 for converged policies.}

\item{...}{further arguments are passed on.}
}
\value{
\code{reward()} returns a vector of reward values, one for each belief if a matrix is specified.

\code{reward_node_action()} returns a list with the components
\item{belief_state}{the belief state specified in \code{belief}.}
\item{reward}{the total expected reward given a belief and epoch. }
\item{pg_node}{the policy node that represents the belief state.}
\item{action}{the optimal action.}
}
\description{
This function calculates the expected total reward for a POMDP solution
given a starting belief state. The value is calculated using the value function stored
in the POMDP solution. In addition, the policy graph node that represents the belief state
and the optimal action can also be returned using \code{reward_node_action()}.
}
\details{
The reward is typically calculated using the value function (alpha vectors)
of the solution. If these are not available, then \code{\link[=simulate_POMDP]{simulate_POMDP()}} is
used instead with a warning.
}
\examples{
data("Tiger")
sol <- solve_POMDP(model = Tiger)

# if no start is specified, a uniform belief is used.
reward(sol)

# we have additional information that makes us believe that the tiger
# is more likely to the left.
reward(sol, belief = c(0.85, 0.15))

# we start with strong evidence that the tiger is to the left.
reward(sol, belief = "tiger-left")

# Note that in this case, the total discounted expected reward is greater
# than 10 since the tiger problem resets and another game staring with
# a uniform belief is played which produces additional reward.

# return reward, the initial node in the policy graph and the optimal action for
# two beliefs.
reward_node_action(sol, belief = rbind(c(.5, .5), c(.9, .1)))

# manually combining reward with belief space sampling to show the value function
# (color signifies the optimal action)
samp <- sample_belief_space(sol, n = 200)
rew <- reward_node_action(sol, belief = samp)
plot(rew$belief[,"tiger-right"], rew$reward, col = rew$action, ylim = c(0, 15))
legend(x = "top", legend = levels(rew$action), title = "action", col = 1:3, pch = 1)

# this is the piecewise linear value function from the solution
plot_value_function(sol, ylim = c(0, 10))
}
\seealso{
Other policy: 
\code{\link{estimate_belief_for_nodes}()},
\code{\link{optimal_action}()},
\code{\link{plot_belief_space}()},
\code{\link{plot_policy_graph}()},
\code{\link{policy_graph}()},
\code{\link{policy}()},
\code{\link{projection}()},
\code{\link{solve_POMDP}()},
\code{\link{solve_SARSOP}()},
\code{\link{value_function}()}
}
\author{
Michael Hahsler
}
\concept{policy}
