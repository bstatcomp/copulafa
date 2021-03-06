#' Predict from CFA model
#'
#' This function predicts based on the estimation of the CFA
#' model \code{train_CFA}.
#'
#' @export
#' @param tr_fa An object resulting from \code{train_CFA}.
#' @param gp_test vector. Groups for each observation in the test set.
#' @param test data frame. Test data set for evaluation.
#' @param logl logical. Return log-likelihood? Defaults to TRUE.
#' @return A list.
#'   \item{predictions}{A numeric vector of predictions for all observations
#'   in the test set.}
#'   \item{likelihoods}{A numeric vector of (log-)likelihoods for all
#'   observations in the test set.}
#' @seealso \code{\link{train_CFA}}
pred_CFA <- function (tr_fa, gp_test, test, logl = TRUE) {
  if (is.na(tr_fa$Sigma)) {
    predictions <- NA
    log_lik     <- NA
  } else {
    predictions <- matrix(data = NA, nrow=length(gp_test), ncol=ncol(tr_fa$train))
    loadings    <- matrix(tr_fa$loadings, ncol = ncol(tr_fa$loadings))
    scores      <- t(as.matrix(tr_fa$scores))
    gp_score    <- data.frame(group = tr_fa$gp_train, scores = scores)
    gp_score <- aggregate(gp_score[ ,-1], by = list(gp_score$group), FUN = mean)
    gp_uniq     <- unique(gp_score)
    colnames(gp_uniq)[1] <- "group"
    pr_factors  <- left_join(data.frame(group = gp_test), gp_uniq, by = "group")
    if (anyNA(pr_factors)) {
      ind                 <- apply(is.na(pr_factors), 1, sum)
      ind[ind != 0]       <- 1
      ind                 <- as.logical(ind)
      pr_factors[ind, -1] <- matrix(rep(apply(as.matrix(gp_score[ ,-1]), 2, mean),
                                        times = sum(ind)),
                                    nrow = sum(ind), byrow = T)
    }
    predictions <- as.matrix(pr_factors[ ,-1]) %*% t(loadings)
    means       <- apply(tr_fa$train, MARGIN = 2, FUN = mean)
    sds         <- apply(tr_fa$train, MARGIN = 2, FUN = sd)
    predictions <- sweep(predictions, 2, sds, '*')
    predictions <- sweep(predictions, 2, means, '+')
    predictions <- round(predictions)
    mu_mat      <- as.matrix(pr_factors[ ,-1]) %*% t(loadings)
    sig_mat     <- tr_fa$noise_org
    cop_cov     <- tr_fa$Sigma
    test_st     <- scale(test, center = means, scale = sds)
    log_lik     <- vector(mode = "numeric", length = nrow(test))
    for (i in 1L:length(gp_test)) {
      mus        <- mu_mat[i, ]
      sigs       <- sqrt(diag(sig_mat))
      log_lik[i] <- L_CFA_approx(test_st[i,],
                                 mus,
                                 sigs,
                                 cop_cov,
                                 logl     = TRUE,
                                 sd_train = sds)
    }
  }
  return (list(predictions = predictions,
               likelihoods = log_lik))
}
