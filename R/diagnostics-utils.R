# Diagnostic refitting helpers -------------------------------------------

.apm_resolve_cluster <- function(model, cluster = NULL, required = FALSE) {
  dat <- model$data %||% data.frame()
  if (is.null(cluster)) {
    if ("study_id" %in% names(dat)) return(as.character(dat$study_id))
    if (required) .apm_abort("A study-level cluster vector is required and no {.field study_id} column is available.")
    return(NULL)
  }
  if (is.character(cluster) && length(cluster) == 1L && cluster %in% names(dat)) {
    return(as.character(dat[[cluster]]))
  }
  if (length(cluster) != nrow(dat)) .apm_abort("{.arg cluster} must have one value per fitted effect or name a column in the fitted data.")
  as.character(cluster)
}

.apm_refit_subset <- function(model, keep) {
  if (!inherits(model, "apm_model")) .apm_abort("Internal refitting requires an apm_model object.")
  if (!is.logical(keep) || length(keep) != nrow(model$data)) .apm_abort("Internal refit subset has the wrong length.")
  if (sum(keep) < 2L) stop("Too few effects remain after deletion.", call. = FALSE)
  dat <- model$data[keep, , drop = FALSE]
  fit0 <- model$backend_fit
  settings <- model$settings %||% list()
  mods <- settings$mods %||% ~ 1
  method <- settings$method %||% "REML"
  test <- settings$test %||% "z"
  if (identical(test, "knha")) test <- "knha"

  if (inherits(fit0, "rma.mv")) {
    V0 <- model$V %||% diag(model$data$vi)
    V <- as.matrix(V0)[keep, keep, drop = FALSE]
    args <- list(yi = dat$yi, V = V, mods = mods, data = dat, method = method, test = test)
    if (!is.null(settings$random)) args$random <- settings$random
    if (!is.null(settings$struct)) args$struct <- settings$struct
    if (!is.null(settings$dfs)) args$dfs <- settings$dfs
    return(do.call(metafor::rma.mv, args))
  }

  metafor::rma.uni(yi = dat$yi, vi = dat$vi, mods = mods, data = dat,
    method = method, test = test)
}

.apm_fit_summary_row <- function(fit, omitted, measure = "GEN") {
  cf <- stats::coef(fit)
  est <- as.numeric(cf[1])
  cv <- tryCatch(stats::vcov(fit), error = function(e) matrix(NA_real_, 1, 1))
  se <- if (length(cv)) sqrt(as.numeric(cv[1,1])) else NA_real_
  level <- (fit$level %||% 95) / 100
  crit <- if (tolower(fit$test %||% "z") %in% c("t","knha","hksj","adhoc")) {
    df <- fit$ddf %||% max(1, (fit$k %||% 2) - (fit$p %||% 1))
    stats::qt(1 - (1-level)/2, df = as.numeric(df[1]))
  } else stats::qnorm(1 - (1-level)/2)
  pr <- tryCatch(stats::predict(fit), error = function(e) NULL)
  pi.lb <- if (!is.null(pr) && !is.null(pr$pi.lb) && length(pr$pi.lb)) as.numeric(pr$pi.lb[1]) else NA_real_
  pi.ub <- if (!is.null(pr) && !is.null(pr$pi.ub) && length(pr$pi.ub)) as.numeric(pr$pi.ub[1]) else NA_real_
  het <- c(fit$tau2 %||% numeric(), fit$sigma2 %||% numeric(), fit$gamma2 %||% numeric())
  het <- het[is.finite(het) & het >= 0]
  data.frame(omitted = as.character(omitted), estimate = est, se = se,
    ci_lower = est - crit*se, ci_upper = est + crit*se,
    pi_lower = pi.lb, pi_upper = pi.ub,
    heterogeneity_variance = if(length(het)) sum(het) else NA_real_,
    QE = fit$QE %||% NA_real_, QEp = fit$QEp %||% NA_real_,
    success = TRUE, error = NA_character_, stringsAsFactors = FALSE)
}

.apm_failed_refit_row <- function(omitted, error) {
  data.frame(omitted=as.character(omitted), estimate=NA_real_, se=NA_real_,
    ci_lower=NA_real_, ci_upper=NA_real_, pi_lower=NA_real_, pi_upper=NA_real_,
    heterogeneity_variance=NA_real_, QE=NA_real_, QEp=NA_real_, success=FALSE,
    error=conditionMessage(error), stringsAsFactors=FALSE)
}

.apm_seeded <- function(seed, fun) {
  if (is.null(seed)) return(fun())
  if (!is.numeric(seed) || length(seed) != 1L || !is.finite(seed)) .apm_abort("{.arg seed} must be a finite scalar.")
  had <- exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
  if (had) old <- get(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
  on.exit({
    if (had) assign(".Random.seed", old, envir=.GlobalEnv)
    else if (exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)) rm(".Random.seed", envir=.GlobalEnv)
  }, add=TRUE)
  set.seed(as.integer(seed))
  fun()
}

.apm_hash_object <- function(x) .apm_hash_data(x)
