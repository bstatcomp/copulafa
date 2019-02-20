#' The 'copulafa' package.
#'
#' @description The package contains several factor analysis methods, with
#' emphasis to count data. The main methods rely on copulas to estimate the
#' residual covariance, not explained by the latent structure. Additionally, the
#' package contains four data sets for empirical evaluation and one baseline
#' model. The methods use RStan for inference, the only exception is the
#' iPoiss method where we use conjugate posterior.
#'
#' @docType package
#' @name copulafa-package
#' @aliases copulafa
#' @useDynLib copulafa, .registration = TRUE
#' @import methods
#' @import Rcpp
#' @import rstantools
#' @importFrom rstan sampling
#'
#' @references
#' Stan Development Team (2018). RStan: the R interface to Stan. R package version 2.18.2. http://mc-stan.org
#'
NULL
