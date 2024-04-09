## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = TRUE,
  animation.hook = knitr::hook_gifski
)

## ----setup--------------------------------------------------------------------
library(pomdp)

## -----------------------------------------------------------------------------
x <- gridworld_maze_MDP(
                dim = c(6,9),
                start = "s(3,1)",
                goal = "s(1,9)",
                walls = c("s(2,3)", "s(3,3)", "s(4,3)",
                          "s(5,6)",
                          "s(1,8)", "s(2,8)", "s(3,8)"),
                goal_reward = 1,
                step_cost = 0,
                restart = TRUE,
                discount = 0.95,
                name = "Dyna Maze",
                )
x

## -----------------------------------------------------------------------------
gridworld_plot_transition_graph(x)

## -----------------------------------------------------------------------------
gridworld_matrix(x)
gridworld_matrix(x, what = "labels")
gridworld_matrix(x, what = "reachable")

## -----------------------------------------------------------------------------
sol <- solve_MDP(x, method = "value_iteration")
sol

## -----------------------------------------------------------------------------
sol$solution

## -----------------------------------------------------------------------------
gridworld_matrix(sol, what = "values")
gridworld_matrix(sol, what = "actions")

## -----------------------------------------------------------------------------
gridworld_plot_policy(sol)

## -----------------------------------------------------------------------------
sol <- solve_MDP(x, method = "value_iteration", N = 5)
gridworld_plot_policy(sol, zlim = c(0, 2), sub = "Iteration 5")

## -----------------------------------------------------------------------------
gridworld_animate(x, "value_iteration", n = 5, zlim = c(0, 2))

## ----fig.show='animate'-------------------------------------------------------
gridworld_animate(x, "value_iteration", n = 20, zlim = c(0, 2))

## ----fig.show='animate'-------------------------------------------------------
gridworld_animate(x, "policy_iteration", n = 20, zlim = c(0, 2))

## ----fig.show='animate'-------------------------------------------------------
gridworld_animate(x, "q_learning", n = 20, zlim = c(0, 2),  horizon = 100)

## ----fig.show='animate'-------------------------------------------------------
gridworld_animate(x, "sarsa", n = 20, zlim = c(0, 2), horizon = 100)

## ----fig.show='animate'-------------------------------------------------------
gridworld_animate(x, "expected_sarsa", n = 20, zlim = c(0, 2), horizon = 100, alpha = 1)

