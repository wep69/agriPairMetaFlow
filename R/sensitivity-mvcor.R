# Sensitivity to unknown within-study outcome correlation -----------------

.apm_mv_rho_v <- function(dat, study, rho) {
  V <- diag(dat$vi)
  groups <- split(seq_len(nrow(dat)), study)
  for (ii in groups) {
    if (length(ii) > 1L) {
      R <- matrix(rho, length(ii), length(ii)); diag(R) <- 1
      S <- outer(sqrt(dat$vi[ii]), sqrt(dat$vi[ii])) * R
      ev <- eigen((S+t(S))/2, symmetric=TRUE, only.values=TRUE)$values
      if (min(ev) < -1e-10) .apm_abort("Assumed rho={rho} yields a non-positive-semidefinite covariance block.")
      V[ii,ii] <- S
    }
  }
  V
}

#' Sensitivity of multivariate synthesis to unknown outcome correlations
#' @param effects Effect-size data with `yi` and `vi`.
#' @param outcome Outcome identifier.
#' @param study Study identifier.
#' @param rho Grid of assumed within-study correlations.
#' @param fit_args Named list forwarded to `apm_multivariate()`.
#' @param metric Metric emphasized in printed summaries.
#' @return An `apm_sensitivity` object with all fitted rho scenarios.
#' @export
#' @examples
#' s1 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(.25,.5,.75))
#' s2 <- apm_mvcor_sensitivity(biochar_multiresponse, outcome=outcome, study=study_id, rho=seq(0,.8,.2), metric="tau")
#' s3 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(0,.5), fit_args=list(mods=~climate_zone))
apm_mvcor_sensitivity <- function(effects, outcome, study, rho = c(0, 0.25, 0.5, 0.75),
                                  fit_args = list(), metric = c("estimate", "se", "tau", "cor")) {
  metric <- match.arg(metric)
  if (!is.numeric(rho) || !length(rho) || any(!is.finite(rho)) || any(rho <= -1 | rho >= 1)) .apm_abort("{.arg rho} must contain finite correlations strictly between -1 and 1.")
  if (!is.list(fit_args) || is.null(names(fit_args)) && length(fit_args)) .apm_abort("{.arg fit_args} must be a named list.")
  dat <- .apm_df(effects)
  qo <- rlang::enquo(outcome); qs <- rlang::enquo(study)
  dat$.apm_outcome <- .apm_pull_quo(dat, qo, "outcome", TRUE)
  dat$.apm_study <- .apm_pull_quo(dat, qs, "study", TRUE)
  if (!all(c("yi","vi") %in% names(dat))) .apm_abort("Sensitivity analysis requires {.field yi} and {.field vi}.")
  fits <- vector("list", length(rho)); names(fits) <- as.character(rho)
  rows <- list(); failures <- list()
  for (j in seq_along(rho)) {
    r <- rho[[j]]; V <- .apm_mv_rho_v(dat, dat$.apm_study, r)
    fit <- tryCatch(
      rlang::inject(apm_multivariate(dat, outcome = .apm_outcome, study = .apm_study, V = V, !!!fit_args)),
      error = function(e) e
    )
    if (inherits(fit,"error")) { failures[[as.character(r)]] <- conditionMessage(fit); next }
    fits[[j]] <- fit
    ot <- fit$outcome_estimates
    tau <- if (!is.null(fit$between_cov)) sqrt(pmax(0, diag(fit$between_cov))) else rep(NA_real_, nrow(ot))
    if (length(tau) < nrow(ot)) tau <- rep(NA_real_, nrow(ot))
    rows[[length(rows)+1L]] <- data.frame(rho=r, outcome=ot$outcome, estimate=ot$estimate, se=ot$se, tau=tau[seq_len(nrow(ot))], stringsAsFactors=FALSE)
  }
  tab <- if (length(rows)) do.call(rbind, rows) else data.frame()
  out <- list(results=tab, fits=fits, rho=rho, metric=metric, failures=failures, n_fail=length(failures),
              conclusion_range=if(nrow(tab)) stats::aggregate(
                tab[c("estimate","se","tau")], list(outcome=tab$outcome),
                function(z) {
                  z <- z[is.finite(z)]
                  if (!length(z)) c(min=NA_real_, max=NA_real_) else c(min=min(z), max=max(z))
                }
              ) else NULL,
              call=match.call())
  class(out) <- c("apm_mvcor_sensitivity","apm_sensitivity")
  out
}
