#' Compare prespecified meta-regression models
#'
#' Compares compatible candidate models without automatic stepwise selection.
#' When fixed-effect design matrices differ, likelihood criteria are calculated
#' from ML refits by default so that AIC/BIC/LRT comparisons are valid. Model
#' nesting is assessed from column spaces rather than coefficient names, which
#' is important for spline bases that can share labels but differ in knots.
#'
#' @param ... Two or more `apm_model` objects fitted to the same effects.
#' @param criterion `"AICc"`, `"AIC"`, `"BIC"`, or `"LRT"`.
#' @param refit_ml Refit REML candidate models by maximum likelihood when fixed
#'   effects differ.
#' @param weights Calculate normalized information-criterion weights.
#' @return An `apm_model_comparison` with criteria, deltas, weights, design
#'   hashes, nesting information, and provenance.
#' @export
#' @examples
#' # Example 1: linear versus quadratic rainfall association.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irrig_lin <- apm_metareg_curve(irr_es,rainfall,"linear")
#' irrig_quad <- apm_metareg_curve(irr_es,rainfall,"quadratic")
#' apm_model_compare(irrig_lin,irrig_quad,criterion="AICc")
#' # Example 2: linear versus spline N-rate relationship.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_V <- apm_vcov(mz_es,cluster=experiment_id)
#' mz_lin <- apm_metareg_curve(mz_es,N_rate,"linear",V=mz_V,random=~1|study_id/effect_id)
#' mz_ns <- apm_metareg_curve(mz_es,N_rate,"ns",df=3,V=mz_V,random=~1|study_id/effect_id)
#' apm_model_compare(mz_lin,mz_ns,criterion="AIC")
#' # Example 3: main effects versus a prespecified crop-by-site interaction.
#' bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' bio_main <- apm_metareg(bio_es,~crop+site)
#' bio_int <- apm_metareg(bio_es,~crop*site)
#' apm_model_compare(bio_main,bio_int,criterion="LRT")
apm_model_compare <- function(..., criterion = c("AICc", "AIC", "BIC", "LRT"), refit_ml = TRUE, weights = TRUE) {
  mods <- list(...)
  criterion <- match.arg(criterion)
  if (length(mods) < 2L) .apm_abort("Provide at least two fitted models.")
  if (any(!vapply(mods, inherits, logical(1), "apm_model"))) .apm_abort("All candidates must inherit from apm_model.")

  hashes <- vapply(mods, function(x) x$source_data_hash %||% x$data_hash, character(1))
  if (length(unique(hashes)) != 1L) .apm_abort("Candidate models must use the same effect dataset.")
  measures <- vapply(mods, function(x) x$measure %||% "GEN", character(1))
  if (length(unique(measures)) != 1L) .apm_abort("Candidate models must use the same estimand.")
  random_sig <- vapply(mods, function(x) {
    rr <- x$settings$random
    if (is.null(rr)) "<none>" else paste(deparse(rr), collapse = "")
  }, character(1))
  if (length(unique(random_sig)) != 1L) .apm_abort("Candidate models must use the same random-effects structure.")
  Vsig <- vapply(mods, function(x) if (is.null(x$V)) "none" else .apm_hash_data(as.matrix(x$V)), character(1))
  if (length(unique(Vsig)) != 1L) .apm_abort("Candidate models must use the same sampling covariance structure.")
  nms <- names(mods)
  if (is.null(nms) || any(!nzchar(nms))) nms <- paste0("model", seq_along(mods))

  get_X <- function(x) {
    X <- x$model_matrix %||% x$backend_fit$X
    if (is.null(X)) .apm_abort("A candidate model does not expose its fixed-effect design matrix; comparison cannot be audited safely.")
    X <- as.matrix(X)
    if (!nrow(X) || !ncol(X) || any(!is.finite(X))) .apm_abort("Candidate fixed-effect design matrices must be finite and non-empty.")
    X
  }
  Xs <- lapply(mods, get_X)
  if (length(unique(vapply(Xs, nrow, integer(1)))) != 1L) .apm_abort("Candidate models must use the same analysis rows.")
  design_hashes <- vapply(Xs, .apm_hash_data, character(1))
  fixed_differ <- length(unique(design_hashes)) > 1L

  matrix_rank <- function(X) qr(X, tol = 1e-10)$rank
  nested <- matrix(FALSE, length(mods), length(mods), dimnames = list(nms, nms))
  for (i in seq_along(mods)) for (j in seq_along(mods)) {
    Xi <- Xs[[i]]
    Xj <- Xs[[j]]
    nested[i, j] <- nrow(Xi) == nrow(Xj) && matrix_rank(cbind(Xj, Xi)) == matrix_rank(Xj)
  }

  original_methods <- vapply(mods, function(x) toupper(as.character(x$backend_fit$method %||% x$settings$method %||% ""))[1], character(1))
  if (length(unique(original_methods)) != 1L) .apm_abort("Candidate models must use the same heterogeneity estimation method before comparison.")
  needs_ml <- fixed_differ & !original_methods %in% c("ML", "FE", "EE")
  if (any(needs_ml) && !isTRUE(refit_ml)) {
    .apm_abort("Likelihood-based comparison across different fixed-effect designs requires ML fits. Set {.arg refit_ml = TRUE} or fit all candidates with ML explicitly.")
  }

  refit_one <- function(x, need) {
    fit <- x$backend_fit
    if (isTRUE(refit_ml) && isTRUE(need)) {
      z <- tryCatch(stats::update(fit, method = "ML"), error = function(e) e)
      if (inherits(z, "error")) .apm_abort("ML refit required for valid model comparison but failed: {conditionMessage(z)}")
      return(z)
    }
    fit
  }
  fits <- Map(refit_one, mods, needs_ml)
  ll <- lapply(fits, stats::logLik)
  loglik <- vapply(ll, as.numeric, numeric(1))
  p <- vapply(ll, function(z) as.numeric(attr(z, "df") %||% NA_real_), numeric(1))
  n <- vapply(mods, function(x) nrow(x$source_data %||% x$data), numeric(1))
  AIC <- vapply(fits, stats::AIC, numeric(1))
  BIC <- vapply(fits, stats::BIC, numeric(1))
  AICc <- AIC + ifelse(n - p - 1 > 0, 2 * p * (p + 1) / (n - p - 1), NA_real_)
  tab <- data.frame(model = nms, k = n, p = p, logLik = loglik, AIC = AIC, AICc = AICc, BIC = BIC, stringsAsFactors = FALSE)

  if (criterion == "LRT") {
    # The smallest parameter dimension is used as the reduced reference only if
    # its fixed-effect column space is nested in all compared larger models.
    base <- which.min(p)
    stat <- df <- pv <- rep(NA_real_, length(mods))
    stat[base] <- 0
    df[base] <- 0
    pv[base] <- NA_real_
    for (j in setdiff(seq_along(mods), base)) {
      if (!nested[base, j]) .apm_abort("LRT requires nested fixed-effect column spaces; {.val {nms[base]}} is not nested in {.val {nms[j]}}.")
      stat[j] <- 2 * (loglik[j] - loglik[base])
      if (stat[j] < -1e-8) .apm_abort("The nominally larger nested model has a lower maximized likelihood than the reduced model. Inspect convergence before using an LRT.")
      stat[j] <- max(0, stat[j])
      df[j] <- p[j] - p[base]
      pv[j] <- if (df[j] > 0) stats::pchisq(stat[j], df = df[j], lower.tail = FALSE) else NA_real_
    }
    tab$LRT <- stat
    tab$LRT_df <- df
    tab$LRT_p <- pv
    tab$delta <- NA_real_
    tab$weight <- NA_real_
  } else {
    val <- tab[[criterion]]
    if (all(!is.finite(val))) .apm_abort("The requested information criterion is unavailable for all candidates.")
    tab$delta <- val - min(val, na.rm = TRUE)
    tab$weight <- if (isTRUE(weights)) {
      w <- exp(-0.5 * tab$delta)
      w / sum(w, na.rm = TRUE)
    } else NA_real_
    tab <- tab[order(val), , drop = FALSE]
  }

  out <- list(
    table = tab,
    criterion = criterion,
    refit_ml = isTRUE(refit_ml) && any(needs_ml),
    weights = weights,
    nested = nested,
    design_hashes = stats::setNames(design_hashes, nms),
    fixed_design_changed = fixed_differ,
    original_methods = stats::setNames(original_methods, nms),
    data_hash = hashes[1],
    measure = measures[1],
    models = mods
  )
  class(out) <- "apm_model_comparison"
  out
}
