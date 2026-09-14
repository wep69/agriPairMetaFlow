# Multivariate synthesis ----------------------------------------------------

.apm_mv_prepare <- function(effects, outcome, study, V = NULL) {
  dat <- .apm_df(effects)
  qo <- rlang::enquo(outcome)
  qs <- rlang::enquo(study)
  out <- .apm_pull_quo(dat, qo, "outcome", required = TRUE)
  sid <- .apm_pull_quo(dat, qs, "study", required = TRUE)
  if (!all(c("yi", "vi") %in% names(dat))) .apm_abort("Multivariate synthesis requires {.field yi} and {.field vi} columns.")
  if (any(!is.finite(dat$yi)) || any(!is.finite(dat$vi)) || any(dat$vi <= 0)) .apm_abort("{.field yi} must be finite and {.field vi} must be finite and positive.")
  out <- factor(as.character(out), levels = unique(as.character(out)))
  sid <- as.character(sid)
  key <- paste(sid, out, sep = "\r")
  if (anyDuplicated(key)) .apm_abort("Each study-outcome combination must occur at most once in {.arg effects}.")
  dat$.apm_y <- dat$yi
  dat$.apm_vi <- dat$vi
  dat$.apm_outcome <- out
  dat$.apm_study <- sid
  dat$.apm_source_row <- seq_len(nrow(dat))
  measures <- attr(effects, "measure") %||% NULL
  if (is.null(measures) && "measure" %in% names(dat)) measures <- unique(stats::na.omit(as.character(dat$measure)))
  if (length(measures) > 1L) .apm_abort("Mixed effect measures are not allowed in one multivariate model unless they have already been transformed to a coherent common scale.")
  measure <- if (length(measures)) measures[[1]] else "GEN"
  if (is.null(V)) {
    V <- diag(dat$.apm_vi)
    .apm_warn("No within-study covariance matrix was supplied; zero within-study outcome correlation is being assumed. Use apm_mvcor_sensitivity() when correlations are unknown.")
    v_source <- "diagonal-zero-correlation"
  } else {
    V <- as.matrix(V)
    if (!all(dim(V) == c(nrow(dat), nrow(dat)))) .apm_abort("{.arg V} must be a square matrix with one row and column per effect.")
    if (max(abs(V - t(V)), na.rm = TRUE) > 1e-10) .apm_abort("{.arg V} must be symmetric.")
    if (any(diag(V) <= 0) || any(!is.finite(diag(V)))) .apm_abort("The diagonal of {.arg V} must be finite and positive.")
    eig <- eigen((V + t(V))/2, symmetric = TRUE, only.values = TRUE)$values
    if (min(eig) < -1e-8) .apm_abort("{.arg V} must be positive semidefinite within numerical tolerance.")
    if (max(abs(diag(V) - dat$.apm_vi), na.rm = TRUE) > 1e-7) .apm_warn("The supplied V diagonal differs from {.field vi}; V is authoritative for fitting.")
    v_source <- "user"
  }
  list(data = dat, V = V, measure = measure, outcome_name = .apm_name_quo(qo), study_name = .apm_name_quo(qs), source = v_source)
}

.apm_mv_formula <- function(mods) {
  if (!inherits(mods, "formula") || length(mods) != 2L) .apm_abort("{.arg mods} must be a one-sided formula.")
  rhs <- paste(deparse(mods[[2L]], width.cutoff = 500L), collapse = " ")
  if (rhs %in% c("1", "~1")) return(~ .apm_outcome - 1)
  stats::as.formula(paste("~ .apm_outcome - 1 + .apm_outcome:(", rhs, ")"))
}

.apm_mv_outcome_table <- function(beta, Vb, outcomes, level = 0.95) {
  z <- stats::qnorm(1 - (1 - level)/2)
  n <- min(length(outcomes), length(beta))
  se <- sqrt(pmax(0, diag(Vb)))[seq_len(n)]
  data.frame(
    outcome = outcomes[seq_len(n)], estimate = as.numeric(beta[seq_len(n)]), se = se,
    ci_lower = as.numeric(beta[seq_len(n)]) - z * se,
    ci_upper = as.numeric(beta[seq_len(n)]) + z * se,
    context = "reference/zero moderator context", stringsAsFactors = FALSE
  )
}

#' Multivariate treatment-versus-control meta-analysis
#'
#' Jointly synthesizes multiple agronomic outcomes while preserving within-study
#' covariance and estimating a between-outcome heterogeneity structure.
#' @param effects Effect-size data containing `yi` and `vi`.
#' @param outcome Outcome identifier.
#' @param study Independent study identifier.
#' @param V Sampling covariance matrix. If `NULL`, zero within-study correlation is assumed and reported.
#' @param mods One-sided moderator formula.
#' @param random Optional random-effects formula for advanced use.
#' @param structure Between-outcome covariance structure.
#' @param method Estimation method.
#' @param backend `metafor`, `mixmeta`, or automatic routing.
#' @param ... Additional backend arguments.
#' @return An object of class `apm_multivariate`.
#' @export
#' @examples
#' V0 <- diag(soil_management_multiresponse$vi)
#' mv1 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V0)
#' mv2 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V0, mods=~climate_zone)
#' if (requireNamespace("mixmeta", quietly=TRUE)) mv3 <- apm_multivariate(biochar_multiresponse, outcome=outcome, study=study_id, V=diag(biochar_multiresponse$vi), structure="CS", backend="mixmeta")
apm_multivariate <- function(effects, outcome, study, V = NULL, mods = ~ 1, random = NULL,
                             structure = c("UN", "CS", "DIAG"), method = "REML",
                             backend = c("auto", "metafor", "mixmeta"), ...) {
  structure <- match.arg(structure)
  backend <- match.arg(backend)
  prep <- .apm_mv_prepare(effects, {{ outcome }}, {{ study }}, V = V)
  dat <- prep$data
  outcomes <- levels(dat$.apm_outcome)
  if (length(outcomes) < 2L) .apm_abort("Multivariate synthesis requires at least two outcomes.")
  if (length(unique(dat$.apm_study)) < 3L) .apm_abort("At least three independent studies are required for multivariate synthesis.")
  mvmods <- .apm_mv_formula(mods)
  if (backend == "auto") backend <- "metafor"

  fit_V <- prep$V
  if (backend == "metafor") {
    .apm_require("metafor", "multivariate meta-analysis")
    rnd <- random %||% ~ .apm_outcome | .apm_study
    fit <- metafor::rma.mv(yi = dat$.apm_y, V = fit_V, mods = mvmods, random = rnd,
                           struct = structure, method = method, data = dat, ...)
    beta <- stats::coef(fit)
    Vb <- stats::vcov(fit)
    G <- fit$G %||% NULL
    if (is.null(G) && !is.null(fit$tau2) && length(fit$tau2) == length(outcomes)) G <- diag(fit$tau2)
    loglik <- tryCatch(as.numeric(stats::logLik(fit)), error = function(e) NA_real_)
    bver <- .apm_backend_version("metafor")
  } else {
    .apm_require("mixmeta", "multivariate meta-analysis")
    # mixmeta::mixmeta(..., control=list(addSlist=...)) requires covariance
    # blocks to be aligned with the contiguous outer groups. Reorder both the
    # long data and V explicitly and retain .apm_source_row for auditability.
    study_levels <- unique(dat$.apm_study)
    ord <- order(match(dat$.apm_study, study_levels), as.integer(dat$.apm_outcome))
    dat <- dat[ord, , drop = FALSE]
    fit_V <- fit_V[ord, ord, drop = FALSE]
    rownames(dat) <- NULL
    study_factor <- factor(dat$.apm_study, levels = study_levels)
    split_rows <- split(seq_len(nrow(dat)), study_factor, drop = TRUE)
    Slist <- lapply(split_rows, function(ii) fit_V[ii, ii, drop = FALSE])
    if (any(vapply(Slist, nrow, integer(1)) != length(outcomes))) {
      .apm_abort("The mixmeta adapter requires a complete outcome profile for every study. Use backend='metafor' for incomplete multivariate profiles.")
    }
    if (any(vapply(split_rows, function(ii) !identical(as.character(dat$.apm_outcome[ii]), outcomes), logical(1)))) {
      .apm_abort("Internal mixmeta ordering failed to align outcomes consistently within studies; inspect the outcome identifiers.")
    }
    bscov <- c(UN = "unstr", CS = "cs", DIAG = "diag")[[structure]]
    rhs <- paste(deparse(mvmods[[2L]], width.cutoff = 500L), collapse = " ")
    fm <- stats::as.formula(paste(".apm_y ~", rhs))
    rnd <- random %||% ~ .apm_outcome - 1 | .apm_study
    fit <- mixmeta::mixmeta(fm, random = rnd, bscov = bscov, method = tolower(method),
                            data = dat, control = list(addSlist = Slist), ...)
    beta <- stats::coef(fit)
    Vb <- stats::vcov(fit)
    G <- fit$Psi %||% NULL
    loglik <- tryCatch(as.numeric(stats::logLik(fit)), error = function(e) NA_real_)
    bver <- .apm_backend_version("mixmeta")
  }

  Gcor <- if (!is.null(G) && is.matrix(G) && all(diag(G) > 0)) stats::cov2cor(G) else NULL
  outcome_tab <- .apm_mv_outcome_table(beta, Vb, outcomes)
  if (!is.null(G) && is.matrix(G) && all(dim(G) == c(length(outcomes), length(outcomes)))) {
    zpred <- stats::qnorm(.975)
    tau2_outcome <- pmax(0, diag(G))
    pred_se <- sqrt(outcome_tab$se^2 + tau2_outcome)
    outcome_tab$tau <- sqrt(tau2_outcome)
    outcome_tab$pi_lower <- outcome_tab$estimate - zpred * pred_se
    outcome_tab$pi_upper <- outcome_tab$estimate + zpred * pred_se
    prediction_basis <- "normal approximation using outcome-specific between-study variance"
  } else {
    outcome_tab$tau <- NA_real_
    outcome_tab$pi_lower <- NA_real_
    outcome_tab$pi_upper <- NA_real_
    prediction_basis <- "not identified from the fitted between-outcome covariance structure"
  }
  out <- list(
    backend_fit = fit, backend = backend, backend_version = bver,
    coefficients = beta, vcov = Vb, data = dat, V = fit_V,
    outcome_estimates = outcome_tab, between_cov = G, between_cor = Gcor,
    outcomes = outcomes, measure = prep$measure,
    settings = list(mods = mods, fitted_mods = mvmods, random = random, structure = structure, method = method, V_source = prep$source,
                    prediction_basis = prediction_basis, source_row_order = dat$.apm_source_row),
    logLik = loglik, data_hash = .apm_hash_data(dat), call = match.call()
  )
  class(out) <- c("apm_multivariate", "apm_model")
  out
}
