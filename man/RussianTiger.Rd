% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RussianTiger.R
\docType{data}
\name{RussianTiger}
\alias{RussianTiger}
\title{Russian Tiger Problem POMDP Specification}
\format{
An object of class \link{POMDP}.
}
\description{
This is a variation of the Tiger Problem introduces in Cassandra et al (1994)
with an absorbing state after a door is opened.
}
\details{
The original Tiger problem is available as \link{Tiger}. The original problem is
an infinite-horizon problem, where when the agent opens a door then the
problem starts over. The infinite-horizon problem can be solved if
a discount factor \eqn{\gamma < 1} is used.

The Russian Tiger problem uses no discounting, but instead
adds an absorbing state \code{done}  which is reached
after the agent opens a door. It adds the action \code{nothing} to indicate
that the agent does nothing. The \code{nothing} action is only available in the
state \code{done} indicated by a reward of \code{-Inf} from all after states. A new
observation \code{done} is only emitted by the state \code{done}. Also, the Russian
tiger inflicts more pain with a negative reward of -1000.
}
\examples{
data("RussianTiger")
RussianTiger

# states, actions, and observations
RussianTiger$states  
RussianTiger$actions 
RussianTiger$observations

# reward (-Inf indicates unavailable actions)
RussianTiger$reward

sapply(RussianTiger$states, FUN = function(s) actions(RussianTiger, s))

plot_transition_graph(RussianTiger, vertex.size = 30, edge.arrow.size = .3, margin = .5)

# absorbing states
absorbing_states(RussianTiger)

# solve the problem.
sol <- solve_POMDP(RussianTiger)
policy(sol)
plot_policy_graph(sol)
}
\seealso{
Other POMDP_examples: 
\code{\link{POMDP}()},
\code{\link{POMDP_example_files}},
\code{\link{Tiger}}
}
\concept{POMDP_examples}
\keyword{datasets}
