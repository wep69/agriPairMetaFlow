.apm_default_marginal_vars <- function(model) {
  model$moderator_info$variables %||% character()
}

#' Adjusted marginal effects from agronomic meta-regression
#'
#' Computes standardized marginal predictions by averaging the fitted
#' meta-regression design matrix over the observed study distribution while
#' setting selected moderators to explicit levels or values.
#'
#' @param model An `apm_metareg` model.
#' @param variables Moderator names to summarize. Defaults to all fitted
#'   moderators; numeric moderators without explicit values in `at` are
#'   evaluated at their observed support midpoint. Numeric moderators require
#'   explicit values in `at` when `variables` is supplied explicitly.
#' @param at Named list of moderator values at which marginal predictions are
#'   evaluated.
#' @param weights Marginalization rule: equal effect-level weights or equal
#'   study-level weights.
#' @param transform Output transformation.
#' @param level Confidence level.
#' @return An `apm_marginal` object with adjusted estimates and uncertainty.
#' @export
#' @examples
#' # Example 1: crop-adjusted inoculant response.
#' bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' bio_m <- apm_metareg(bio_es, ~ crop + site)
#' apm_marginal_effects(bio_m, variables="crop", transform="percent")
#' # Example 2: irrigation response at three rainfall contexts.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irr_m <- apm_metareg(irr_es, ~ rainfall * climate_zone)
#' apm_marginal_effects(irr_m, at=list(rainfall=c(600,900,1200)))
#' # Example 3: equal-study weighting with shared-control nitrogen effects.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_V <- apm_vcov(mz_es,cluster=experiment_id)
#' mz_m <- apm_metareg(mz_es,~N_rate+soil_texture,V=mz_V,random=~1|study_id/effect_id)
#' apm_marginal_effects(mz_m,variables="soil_texture",weights="study")
apm_marginal_effects <- function(model, variables = NULL, at = NULL, weights = c("equal", "study"), transform = c("auto", "none", "exp", "percent"), level = 0.95) {
  if (!inherits(model, "apm_metareg")) .apm_abort("{.arg model} must inherit from apm_metareg.")
  weights <- match.arg(weights); transform <- match.arg(transform)
  if (!is.numeric(level) || length(level) != 1L || level <= 0 || level >= 1) .apm_abort("{.arg level} must lie between 0 and 1.")
  if (is.null(at)) at <- list()
  if (!is.list(at) || (length(at) && is.null(names(at)))) .apm_abort("{.arg at} must be a named list.")
  if (is.null(variables) && !length(at)) {
    variables <- .apm_default_marginal_vars(model)
    for (v in variables) {
      sup <- model$moderator_info$support[[v]]
      if (!is.null(sup) && identical(sup$type, "numeric") && is.finite(sup$min) && is.finite(sup$max))
        at[[v]] <- mean(c(sup$min, sup$max))
    }
  }
  if (is.null(variables)) variables <- names(at)
  variables <- unique(c(as.character(variables), names(at)))
  if (!length(variables)) .apm_abort("Specify {.arg variables} and/or a named {.arg at} list.")
  bad <- setdiff(variables, model$moderator_info$variables)
  if (length(bad)) .apm_abort("Variables not present in the fitted meta-regression: {paste(bad, collapse=', ')}")

  values <- vector("list", length(variables)); names(values) <- variables
  for (v in variables) {
    sup <- model$moderator_info$support[[v]]
    if (v %in% names(at)) {
      vals <- at[[v]]
    } else if (identical(sup$type, "factor")) {
      vals <- sup$levels
    } else {
      .apm_abort("Numeric moderator {.field {v}} requires explicit evaluation values in {.arg at}.")
    }
    if (identical(sup$type, "numeric")) {
      if (!is.numeric(vals) || any(!is.finite(vals))) .apm_abort("Values supplied for {.field {v}} must be finite numeric values.")
      if (any(vals < sup$min | vals > sup$max)) .apm_abort("Marginal effects do not extrapolate: values for {.field {v}} must remain within [{sup$min}, {sup$max}].")
    } else {
      badlev <- setdiff(as.character(vals), sup$levels)
      if (length(badlev)) .apm_abort("Unknown level(s) for {.field {v}}: {paste(badlev, collapse=', ')}")
    }
    values[[v]] <- vals
  }
  grid <- do.call(expand.grid, c(values, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE))
  source <- model$source_data %||% model$data
  w <- .apm_marginal_weights(source, weights)
  beta <- as.numeric(stats::coef(model$backend_fit)); Vb <- as.matrix(stats::vcov(model$backend_fit))
  alpha <- 1 - level
  crit <- .apm_critical_value(model, level)
  fit <- model$backend_fit
  het_vars <- c(fit$tau2 %||% numeric(), fit$sigma2 %||% numeric(), fit$gamma2 %||% numeric())
  het_vars <- het_vars[is.finite(het_vars) & het_vars >= 0]
  pred_var <- if (length(het_vars) == 1L) het_vars else NA_real_

  ans <- vector("list", nrow(grid))
  for (i in seq_len(nrow(grid))) {
    nd <- source
    for (v in variables) nd[[v]] <- grid[[v]][i]
    mx <- .apm_model_matrix_meta(model, nd)$matrix
    xbar <- as.numeric(colSums(mx * w))
    if (length(beta) == length(xbar) + 1L) xbar <- c(1, xbar)
    if (length(beta) != length(xbar)) .apm_abort("Internal model-matrix dimension mismatch while computing marginal effects.")
    est <- sum(xbar * beta)
    se <- sqrt(drop(t(xbar) %*% Vb %*% xbar))
    pi_se <- if (is.finite(pred_var)) sqrt(se^2 + pred_var) else NA_real_
    ans[[i]] <- data.frame(pred=est,se=se,ci_lower=est-crit*se,ci_upper=est+crit*se,
      pi_lower=if(is.finite(pi_se)) est-crit*pi_se else NA_real_,
      pi_upper=if(is.finite(pi_se)) est+crit*pi_se else NA_real_, stringsAsFactors=FALSE)
  }
  raw <- cbind(grid, do.call(rbind, ans))
  tab <- raw
  for (nm in c("pred","ci_lower","ci_upper","pi_lower","pi_upper")) tab[[nm]] <- .apm_transform_vector(tab[[nm]], model$measure, transform)
  out <- list(table=tab, raw=raw, variables=variables, at=at, weights=weights,
    transform=transform, level=level, prediction_interval=if(is.finite(pred_var)) "single-heterogeneity-component" else "not-identified-for-multiple-components",
    model_hash=model$source_data_hash %||% model$data_hash, measure=model$measure)
  class(out) <- "apm_marginal"
  out
}
