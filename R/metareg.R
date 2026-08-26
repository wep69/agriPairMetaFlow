#' Fit agronomic meta-regression models
#'
#' Fits mixed-effects meta-regression while retaining moderator support,
#' centering/scaling constants, factor reference levels, residual heterogeneity,
#' and a transparent meta-analytic R-squared descriptor. Continuous moderators
#' are centered by default so the intercept is evaluated at their observed mean.
#'
#' @param effects `apm_effects` or a data frame containing `yi` and `vi`.
#' @param moderators One-sided moderator formula, for example `~ rainfall + crop`.
#' @param V Optional sampling variance-covariance matrix.
#' @param random Optional random-effects formula. Supplying `V` or `random` routes
#'   the fit through `metafor::rma.mv()`.
#' @param method Heterogeneity estimator, default `"REML"`.
#' @param test Inference method supported by the selected `metafor` backend.
#' @param center Center numeric moderators before fitting.
#' @param scale Scale numeric moderators by their SD after centering.
#' @param interactions Optional character vector of prespecified interaction terms
#'   to add to `moderators`.
#' @param ... Additional arguments passed to `metafor::rma.uni()` or
#'   `metafor::rma.mv()`.
#' @return An `apm_metareg` object inheriting from `apm_model`.
#' @export
#' @examples
#' # Example 1: rainfall and temperature as quantitative moderators.
#' irrig_es <- apm_effect_size(irrigation_climate, "lnRR", m_t=mean_t, sd_t=sd_t,
#'   n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
#' apm_metareg(irrig_es, ~ rainfall + mean_temp)
#' # Example 2: adjusted crop differences for an inoculant treatment.
#' bio_es <- apm_effect_size(bioinoculant_multicrop, "lnRR", m_t=mean_t, sd_t=sd_t,
#'   n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
#' apm_metareg(bio_es, ~ crop + site)
#' # Example 3: dependence-aware nitrogen meta-regression.
#' maize_es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t,
#'   n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
#' maize_V <- apm_vcov(maize_es, cluster=experiment_id)
#' apm_metareg(maize_es, ~ N_rate + soil_texture, V=maize_V,
#'   random=~1|study_id/effect_id)
apm_metareg <- function(effects, moderators, V = NULL, random = NULL, method = "REML", test = "t", center = TRUE, scale = FALSE, interactions = NULL, ...) {
  .apm_require("metafor", "meta-regression")
  dat0 <- .apm_df(effects)
  if (!all(c("yi", "vi") %in% names(dat0))) .apm_abort("{.arg effects} must contain {.field yi} and {.field vi}.")
  if (!inherits(moderators, "formula")) .apm_abort("{.arg moderators} must be a one-sided formula.")
  if (length(moderators) != 2L) .apm_abort("{.arg moderators} must be one-sided, for example ~ rainfall + crop.")
  mods <- .apm_add_interactions(moderators, interactions)
  mvars <- .apm_formula_vars(mods)
  miss <- setdiff(mvars, names(dat0))
  if (length(miss)) .apm_abort("Moderator variables not found: {paste(miss, collapse=', ')}")

  keep <- is.finite(dat0$yi) & is.finite(dat0$vi) & dat0$vi > 0
  if (length(mvars)) keep <- keep & stats::complete.cases(dat0[, mvars, drop = FALSE])
  if (!all(keep)) .apm_warn("{sum(!keep)} row(s) with incomplete effect or moderator information were omitted and recorded.")
  dat_source <- dat0[keep, , drop = FALSE]
  if (nrow(dat_source) < 3L) .apm_abort("At least three complete effects are required for meta-regression.")

  prep <- .apm_prepare_moderators(dat_source, mods, center = center, scale = scale)
  dat <- prep$data
  Vfit <- NULL
  if (!is.null(V)) {
    V <- as.matrix(V)
    if (!all(dim(V) == c(nrow(dat0), nrow(dat0)))) .apm_abort("{.arg V} must be square with one row and column per input effect.")
    if (max(abs(V - t(V)), na.rm = TRUE) > 1e-10) .apm_abort("{.arg V} must be symmetric.")
    Vfit <- V[keep, keep, drop = FALSE]
  }

  use_mv <- !is.null(Vfit) || !is.null(random)
  if (!is.null(random) && !inherits(random, "formula")) .apm_abort("{.arg random} must be a formula.")
  test <- tolower(as.character(test)[1])
  if (use_mv && !test %in% c("z", "t")) .apm_abort("rma.mv() meta-regression supports test='z' or test='t' in this package API.")
  if (!use_mv && !test %in% c("z", "t", "knha", "hksj", "adhoc")) .apm_abort("Unsupported rma.uni() inference method supplied in {.arg test}.")

  extra <- list(...)
  if (use_mv) {
    if (is.null(Vfit)) Vfit <- diag(dat$vi)
    fit <- do.call(metafor::rma.mv, c(list(yi = dat$yi, V = Vfit, mods = mods, random = random,
      data = dat, method = method, test = test), extra))
    null_fit <- tryCatch(do.call(metafor::rma.mv, c(list(yi = dat$yi, V = Vfit, mods = ~ 1,
      random = random, data = dat, method = method, test = test), extra)), error = function(e) NULL)
  } else {
    fit <- do.call(metafor::rma.uni, c(list(yi = dat$yi, vi = dat$vi, mods = mods,
      data = dat, method = method, test = test), extra))
    null_fit <- tryCatch(do.call(metafor::rma.uni, c(list(yi = dat$yi, vi = dat$vi, mods = ~ 1,
      data = dat, method = method, test = test), extra)), error = function(e) NULL)
  }

  prep$model_matrix_colnames <- colnames(stats::model.matrix(mods, data = dat))
  prep$reference_levels <- vapply(prep$factor_levels, function(z) if(length(z)) z[1] else NA_character_, character(1))
  joint <- data.frame(
    QM = fit$QM %||% NA_real_,
    df = fit$m %||% max(0L, length(stats::coef(fit)) - 1L),
    p_value = fit$QMp %||% NA_real_,
    stringsAsFactors = FALSE
  )
  meta_r2 <- if (is.null(null_fit)) NA_real_ else .apm_meta_r2(fit, null_fit)
  heterogeneity <- list(
    tau2 = fit$tau2 %||% NA_real_,
    sigma2 = fit$sigma2 %||% numeric(),
    gamma2 = fit$gamma2 %||% numeric(),
    QE = fit$QE %||% NA_real_,
    QEp = fit$QEp %||% NA_real_,
    meta_R2_percent = meta_r2
  )

  out <- list(
    backend_fit = fit,
    null_backend_fit = null_fit,
    coefficients = stats::coef(fit),
    vcov = stats::vcov(fit),
    heterogeneity = heterogeneity,
    joint_test = joint,
    model_matrix = fit$X %||% stats::model.matrix(mods, data = dat),
    data = dat,
    source_data = dat_source,
    V = Vfit,
    omitted = which(!keep),
    moderator_info = prep,
    settings = list(mods = mods, original_mods = moderators, random = random,
      method = method, test = test, center = center, scale = scale,
      interactions = interactions, backend = if (use_mv) "metafor::rma.mv" else "metafor::rma.uni"),
    measure = attr(effects, "measure") %||% if ("measure" %in% names(dat0)) as.character(dat0$measure[1]) else "GEN",
    data_hash = .apm_hash_data(dat_source),
    source_data_hash = .apm_hash_data(dat_source),
    backend_version = .apm_backend_version("metafor")
  )
  class(out) <- c("apm_metareg", "apm_model")
  out
}
