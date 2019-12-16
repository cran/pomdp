## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library("pomdp")

## ------------------------------------------------------------------------
str(args(POMDP))

## ---- eval = FALSE-------------------------------------------------------
#  start = c(0.5 , 0.3 , 0.2)

## ---- eval = FALSE-------------------------------------------------------
#  start = "uniform"

## ---- eval = FALSE-------------------------------------------------------
#  start = 3
#  start = c(1, 3)

## ---- eval = FALSE-------------------------------------------------------
#  start <- "state3"
#  start <- c("state1" , "state3")

## ---- eval = FALSE-------------------------------------------------------
#  start = c("-" , "state2")

## ---- eval = FALSE-------------------------------------------------------
#  transition_prob = rbind(
#    T_("action1", "state1", "state2", 0.1),
#    T_("action2", "state1", "state3", 0.9),
#    T_("*"      , "state2", "*",      1)
#  )

## ---- eval = FALSE-------------------------------------------------------
#  transition_prob = list(
#    "action1" = matrix(c(
#        0.1, 0.4, 0.5,
#        0,   0.7, 0.3,
#        0.4, 0.4, 0.2), nrow = 3 , byrow = TRUE) ,
#    "action2" = matrix(c(
#        0,   0.6, 0.4,
#        0.1, 0.9, 0,
#        0.7, 0.3, 0), nrow = 3 , byrow = TRUE))
#  
#  transition_prob = list(
#     "action1" = matrix(c(
#        0.1, 0.4, 0.5,
#        0,   0.7, 0.3,
#        0.4, 0.4, 0.2), nrow = 3 , byrow = TRUE) ,
#      "action2" = "uniform")

## ---- eval = FALSE-------------------------------------------------------
#  observation_prob = rbind(
#    O_("*", "state1", "obs1", 0.1),
#    O_("*", "state1", "obs2", 0.9),
#    O_("*", "state2", "obs1", 0.3),
#    O_("*", "state2", "obs2", 0.7),
#    O_("*", "state3", "obs1", 0.5),
#    O_("*", "state3", "obs2", 0.6)
#  )

## ---- eval = FALSE-------------------------------------------------------
#  observation_prob = list(
#    "action1" = matrix(c(0.1, 0.9,
#                         0.3, 0.7,
#                         0.4, 0.6), nrow = 3, byrow = TRUE) ,
#    "action2" = matrix(c(0.1, 0.9,
#                         0.3, 0.7,
#                         0.4, 0.6), nrow = 3, byrow = TRUE))
#  
#  
#  observation_prob = list(
#   "action1" = "uniform",
#   "action2" = matrix(c(0.1, 0.9,
#                        0.3, 0.7,
#                        0.4, 0.6), nrow = 3, byrow = TRUE))

## ---- eval = FALSE-------------------------------------------------------
#  reward = rbind(
#    R_("action1", "*", "state1", "*", 10000),
#    R_("action1", "*", "state2", "*", 2000),
#    R_("action2", "*", "state1", "*", 50),
#    R_("action2", "*", "state2", "*", 100)
#  )

## ---- eval = FALSE-------------------------------------------------------
#  reward = list(
#    "action1" = list(
#       "state1" = matrix(c(1, 2, 3, 4, 5, 6) , nrow = 3 , byrow = TRUE),
#       "state2" = matrix(c(3, 4, 5, 2, 3, 7) , nrow = 3 , byrow = TRUE),
#       "state3" = matrix(c(6, 4, 8, 2, 9, 4) , nrow = 3 , byrow = TRUE)),
#    "action2" = list(
#       "state1" = matrix(c(3, 2, 4, 7, 4, 8) , nrow = 3 , byrow = TRUE),
#       "state2" = matrix(c(0, 9, 8, 2, 5, 4) , nrow = 3 , byrow = TRUE),
#       "state3" = matrix(c(4, 3, 4, 4, 5, 6) , nrow = 3 , byrow = TRUE)))

## ------------------------------------------------------------------------
str(args(solve_POMDP))

## ------------------------------------------------------------------------
library("pomdp")

TigerProblem <- POMDP(
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

TigerProblem

## ------------------------------------------------------------------------
tiger_solved <- solve_POMDP(TigerProblem)
tiger_solved

## ------------------------------------------------------------------------
solution(tiger_solved)

## ----fig.width = 10, fig.asp = .7----------------------------------------
plot(tiger_solved)

## ------------------------------------------------------------------------
alpha <- solution(tiger_solved)$alpha
alpha

plot(NA, xlim = c(0, 1), ylim = c(0, 20), xlab = "Belief space (for tiger is left)", 
  ylab = "Value function")
for(i in 1:nrow(alpha)) abline(a = alpha[i,2], b = alpha[i,1]- alpha[i,2], col = i, xpd = FALSE)
legend("topright", legend = 
    paste0(1:nrow(alpha),": ", solution(tiger_solved)$pg[,"action"]), col = 1:nrow(alpha), lwd=1)

