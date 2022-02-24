## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library("pomdp")

## -----------------------------------------------------------------------------
str(args(POMDP))

## ---- eval = FALSE------------------------------------------------------------
#  start = c(0.5 , 0.3 , 0.2)

## ---- eval = FALSE------------------------------------------------------------
#  start = "uniform"

## ---- eval = FALSE------------------------------------------------------------
#  start = 3
#  start = c(1, 3)

## ---- eval = FALSE------------------------------------------------------------
#  start <- "state3"
#  start <- c("state1" , "state3")

## ---- eval = FALSE------------------------------------------------------------
#  start = c("-" , "state2")

## -----------------------------------------------------------------------------
str(args(solve_POMDP))

## -----------------------------------------------------------------------------
library("pomdp")

Tiger <- POMDP(
  name = "Tiger Problem",
  
  discount = 0.75,
  
  states = c("tiger-left" , "tiger-right"),
  actions = c("listen", "open-left", "open-right"),
  observations = c("tiger-left", "tiger-right"),
  
  start = "uniform",
  
  transition_prob = list(
    "listen" = "identity", 
    "open-left" = "uniform", 
    "open-right" = "uniform"),

  observation_prob = list(
    "listen" = matrix(c(0.85, 0.15, 0.15, 0.85), nrow = 2, byrow = TRUE), 
    "open-left" = "uniform",
    "open-right" = "uniform"),
    
  reward = rbind(
    R_("listen",     "*",           "*", "*", -1  ),
    R_("open-left",  "tiger-left",  "*", "*", -100),
    R_("open-left",  "tiger-right", "*", "*", 10  ),
    R_("open-right", "tiger-left",  "*", "*", 10  ),
    R_("open-right", "tiger-right", "*", "*", -100)
  )
)

Tiger

## -----------------------------------------------------------------------------
sol <- solve_POMDP(Tiger)
sol

## -----------------------------------------------------------------------------
sol$solution

## ----fig.width = 10, fig.asp = .7---------------------------------------------
plot_policy_graph(sol)

## -----------------------------------------------------------------------------
alpha <- sol$solution$alpha
alpha

plot_value_function(sol, ylim = c(0,20))

