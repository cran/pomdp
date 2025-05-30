% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AAA_pomdp-package.R
\docType{package}
\name{pomdp-package}
\alias{pomdp}
\alias{pomdp-package}
\title{pomdp: Infrastructure for Partially Observable Markov Decision Processes (POMDP)}
\description{
Provides the infrastructure to define and analyze the solutions of Partially Observable Markov Decision Process (POMDP) models. Interfaces for various exact and approximate solution algorithms are available including value iteration, point-based value iteration and SARSOP. Hahsler and Cassandra \doi{10.32614/RJ-2024-021}.
}
\section{Key functions}{

\itemize{
\item Problem specification: \link{POMDP}, \link{MDP}
\item Solvers: \code{\link[=solve_POMDP]{solve_POMDP()}}, \code{\link[=solve_MDP]{solve_MDP()}}, \code{\link[=solve_SARSOP]{solve_SARSOP()}}
}
}

\seealso{
Useful links:
\itemize{
  \item \url{https://github.com/mhahsler/pomdp}
  \item Report bugs at \url{https://github.com/mhahsler/pomdp/issues}
}

}
\author{
\strong{Maintainer}: Michael Hahsler \email{mhahsler@lyle.smu.edu} (\href{https://orcid.org/0000-0003-2716-1405}{ORCID}) [copyright holder]

Other contributors:
\itemize{
  \item Hossein Kamalzadeh [contributor]
}

}
\keyword{internal}
