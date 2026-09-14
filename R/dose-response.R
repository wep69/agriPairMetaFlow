#' Fit correlated agronomic dose-response meta-analysis
#'
#' Fits a true multi-dose treatment-control synthesis while respecting the
#' within-study covariance created by doses sharing a common reference. Random
#' coefficient dose-response models use the optional `dosresmeta` backend. If
#' that package is unavailable, only the fixed-effect generalized least-squares
#' route is provided through `metafor`; a random-intercept model is deliberately
#' not presented as an equivalent substitute for random dose-response curves.
#'
#' @param data Data frame or `apm_effects` containing effect sizes.
#' @param effect Effect-size column, typically `yi` or `lnRR`.
#' @param dose Quantitative dose column.
#' @param study Study identifier.
#' @param V Optional sampling covariance matrix. It may correspond to all input
#'   rows, all complete rows, or retained non-reference rows.
#' @param form Dose-response form: linear, quadratic, or natural spline.
#' @param df Natural-spline degrees of freedom.
#' @param method `"reml"`, `"ml"`, or `"fixed"`.
#' @param covariance `"auto"` reconstructs covariance from shared-arm metadata;
#'   `"user"` requires `V`.
#' @param reference Reference dose, usually zero.
#' @param moderators Optional study-level meta-regression formula for the
#'   `dosresmeta` backend.
#' @param ... Additional arguments passed to the selected backend.
#' @return An `apm_dose` object with covariance provenance, dose basis,
#'   retained/reference row indices, predictions, diagnostics, and backend.
#' @export
#' @examples
#' # Example 1: linear nitrogen dose-response meta-analysis.
#' if (requireNamespace("dosresmeta", quietly=TRUE))
#'   apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'     study=study_id,form="linear")
#' # Example 2: fixed quadratic GLS while preserving shared-control covariance.
#' apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'   study=study_id,form="quadratic",method="fixed")
#' # Example 3: flexible dose-response with soil texture as a study moderator.
#' if (requireNamespace("dosresmeta", quietly=TRUE))
#'   apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'     study=study_id,form="ns",df=3,moderators=~soil_texture)
apm_dose_response <- function(data, effect, dose, study, V = NULL, form = c("linear", "quadratic", "ns"), df = 3, method = "reml", covariance = c("auto", "user"), reference = 0, moderators = NULL, ...) {
  form <- match.arg(form)
  covariance <- match.arg(covariance)
  method <- tolower(method)
  if (!method %in% c("reml", "ml", "fixed")) .apm_abort("{.arg method} must be 'reml', 'ml', or 'fixed'.")

  dat0 <- .apm_df(data)
  qe <- rlang::enquo(effect); qd <- rlang::enquo(dose); qs <- rlang::enquo(study)
  y0 <- .apm_pull_quo(dat0, qe, "effect", TRUE)
  d0 <- .apm_pull_quo(dat0, qd, "dose", TRUE)
  sid0 <- .apm_pull_quo(dat0, qs, "study", TRUE)
  .apm_check_numeric(y0, "effect")
  .apm_check_numeric(d0, "dose")
  if (anyNA(sid0)) .apm_abort("{.arg study} cannot contain missing values.")
  if (!is.numeric(reference) || length(reference) != 1L || !is.finite(reference)) .apm_abort("{.arg reference} must be one finite dose value.")
  if ("dose_unit" %in% names(dat0) && length(unique(stats::na.omit(dat0$dose_unit))) > 1L) .apm_abort("Dose units are heterogeneous. Convert doses to a common unit before dose-response synthesis.")

  mvars <- if (is.null(moderators)) character() else .apm_formula_vars(moderators)
  miss <- setdiff(mvars, names(dat0))
  if (length(miss)) .apm_abort("Moderator variables not found: {paste(miss, collapse=', ')}")

  complete <- is.finite(y0) & is.finite(d0) & !is.na(sid0)
  if (length(mvars)) complete <- complete & stats::complete.cases(dat0[, mvars, drop = FALSE])
  if (!all(complete)) .apm_warn("{sum(!complete)} incomplete dose-response row(s) were omitted and recorded.")
  complete_idx <- which(complete)
  dat_complete <- dat0[complete_idx, , drop = FALSE]
  y_complete <- y0[complete_idx]
  d_complete <- d0[complete_idx]
  sid_complete <- as.character(sid0[complete_idx])

  is_reference <- d_complete == reference
  if (any(is_reference & abs(y_complete) > sqrt(.Machine$double.eps))) {
    .apm_abort("Rows at the reference dose must have zero effect on a contrast scale.")
  }
  reference_idx <- complete_idx[is_reference]
  analysis_idx <- complete_idx[!is_reference]
  dat <- dat_complete[!is_reference, , drop = FALSE]
  y <- y_complete[!is_reference]
  d <- d_complete[!is_reference]
  sid <- sid_complete[!is_reference]
  if (!length(y)) .apm_abort("No non-reference dose contrasts remain after removing reference rows.")

  basis <- .apm_dose_basis(d, form = form, df = df, reference = reference)
  B <- basis$matrix
  p_basis <- ncol(B)
  study_rows <- split(seq_along(sid), sid)
  bad_dose <- names(study_rows)[vapply(study_rows, function(ii) length(unique(d[ii])) < p_basis, logical(1))]
  bad_rank <- names(study_rows)[vapply(study_rows, function(ii) qr(B[ii, , drop = FALSE], tol = 1e-10)$rank < p_basis, logical(1))]
  if (length(bad_dose) || length(bad_rank)) {
    bad <- unique(c(bad_dose, bad_rank))
    .apm_abort("Each study must identify all {p_basis} dose-basis coefficient(s). Insufficient dose support or rank was found in: {paste(bad, collapse=', ')}")
  }

  if (length(mvars)) {
    for (v in mvars) {
      bystudy <- split(dat[[v]], sid)
      varying <- names(bystudy)[vapply(bystudy, function(z) length(unique(z[!is.na(z)])) > 1L, logical(1))]
      if (length(varying)) .apm_abort("Dose-response moderator {.field {v}} must be study-level; it varies within: {paste(varying, collapse=', ')}")
    }
  }

  for (j in seq_len(p_basis)) dat[[colnames(B)[j]]] <- B[, j]
  dat$.apm_y <- y
  dat$.apm_dose <- d
  dat$.apm_study <- sid
  vi <- if ("vi" %in% names(dat)) dat$vi else NULL
  if (is.null(vi)) .apm_abort("Dose-response input must contain sampling variances in {.field vi}; calculate effect sizes first or provide a prepared teaching dataset.")
  if (any(!is.finite(vi) | vi <= 0)) .apm_abort("Sampling variances must be finite and positive for all non-reference contrasts.")
  dat$.apm_vi <- vi

  if (covariance == "user" && is.null(V)) .apm_abort("covariance='user' requires {.arg V}.")
  if (is.null(V)) {
    if (!all(c("treatment", "control") %in% names(dat))) .apm_abort("Automatic covariance requires treatment/control arm metadata or a user-supplied V matrix.")
    tmp <- dat
    tmp$yi <- tmp$.apm_y
    tmp$vi <- tmp$.apm_vi
    V <- apm_vcov(tmp, cluster = .apm_study, shared_control = TRUE)
    covariance_source <- "apm_vcov(shared-control metadata)"
  } else {
    V <- as.matrix(V)
    dims <- dim(V)
    if (all(dims == c(nrow(dat0), nrow(dat0)))) {
      V <- V[analysis_idx, analysis_idx, drop = FALSE]
    } else if (all(dims == c(nrow(dat_complete), nrow(dat_complete)))) {
      V <- V[!is_reference, !is_reference, drop = FALSE]
    } else if (!all(dims == c(nrow(dat), nrow(dat)))) {
      .apm_abort("{.arg V} must correspond to all input rows, all complete rows, or retained non-reference rows.")
    }
    if (max(abs(V - t(V)), na.rm = TRUE) > 1e-10) .apm_abort("{.arg V} must be symmetric.")
    eig <- eigen((V + t(V)) / 2, symmetric = TRUE, only.values = TRUE)$values
    if (min(eig) < -1e-8) .apm_abort("{.arg V} must be positive semidefinite within numerical tolerance.")
    if (max(abs(diag(V) - vi), na.rm = TRUE) > 1e-7) .apm_warn("The supplied V diagonal differs from {.field vi}; the supplied V matrix is authoritative for fitting.")
    covariance_source <- "user"
  }

  ids <- unique(sid)
  Slist <- lapply(ids, function(id) {
    ii <- which(sid == id)
    S <- as.matrix(V[ii, ii, drop = FALSE])
    if (nrow(S) != length(ii) || max(abs(S - t(S))) > 1e-10) .apm_abort("Invalid within-study covariance block for study {.val {id}}.")
    S
  })
  names(Slist) <- ids

  bnames <- colnames(B)
  fml_dos <- stats::as.formula(paste(".apm_y ~", paste(bnames, collapse = " + ")))
  fml_metafor <- stats::as.formula(paste("~ -1 +", paste(bnames, collapse = " + ")))
  has_dosresmeta <- requireNamespace("dosresmeta", quietly = TRUE)

  if (has_dosresmeta) {
    refrows <- lapply(ids, function(id) {
      z <- dat[which(sid == id)[1], , drop = FALSE]
      z$.apm_y <- 0
      z$.apm_vi <- 0
      z$.apm_dose <- reference
      z$.apm_study <- id
      for (nm in bnames) z[[nm]] <- 0
      z
    })
    aug <- do.call(rbind, lapply(ids, function(id) rbind(refrows[[match(id, ids)]], dat[sid == id, , drop = FALSE])))
    mod_formula <- moderators %||% ~1
    fit <- dosresmeta::dosresmeta(
      formula = fml_dos, id = aug$.apm_study, v = aug$.apm_vi,
      data = aug, mod = mod_formula, intercept = FALSE, center = FALSE,
      covariance = "user", method = method, Slist = Slist, ...
    )
    cf <- stats::coef(fit)
    cv <- stats::vcov(fit)
    gof <- tryCatch(dosresmeta::gof(fit), error = function(e) NULL)
    backend <- "dosresmeta"
    backend_version <- .apm_backend_version("dosresmeta")
  } else {
    if (method != "fixed") {
      .apm_abort("Random-effects dose-response synthesis requires optional package 'dosresmeta'. Install it for local validation/use, or set {.arg method = 'fixed'} for the covariance-aware fixed-effect GLS route.")
    }
    if (!is.null(moderators)) .apm_abort("Study-level dose-response moderators require optional package 'dosresmeta'.")
    .apm_require("metafor", "fixed-effect dose-response GLS")
    fit <- metafor::rma.mv(yi = dat$.apm_y, V = as.matrix(V), mods = fml_metafor, data = dat, method = "FE", ...)
    cf <- stats::coef(fit)
    cv <- stats::vcov(fit)
    gof <- NULL
    backend <- "metafor-fixed-gls"
    backend_version <- .apm_backend_version("metafor")
  }

  pred_grid <- NULL
  if (is.null(moderators)) {
    gx <- seq(reference, max(d), length.out = 120L)
    Bg <- .apm_dose_basis(gx, form = form, df = df, reference = reference, meta = basis$info)$matrix
    if (length(cf) == ncol(Bg)) {
      est <- drop(Bg %*% cf)
      sev <- sqrt(pmax(0, rowSums((Bg %*% cv) * Bg)))
      crit <- stats::qnorm(.975)
      psi <- if (backend == "dosresmeta") fit$Psi %||% NULL else NULL
      pise <- if (!is.null(psi) && all(dim(psi) == c(ncol(Bg), ncol(Bg)))) sqrt(pmax(0, rowSums((Bg %*% (cv + psi)) * Bg))) else rep(NA_real_, length(gx))
      pred_grid <- data.frame(
        dose = gx, pred = est, se = sev,
        ci_lower = est - crit * sev, ci_upper = est + crit * sev,
        pi_lower = ifelse(is.finite(pise), est - crit * pise, NA_real_),
        pi_upper = ifelse(is.finite(pise), est + crit * pise, NA_real_),
        support = ifelse(gx >= min(d) & gx <= max(d), "interpolation", "reference-bridge")
      )
    }
  }

  measure <- attr(data, "measure")
  if (is.null(measure) && "measure" %in% names(dat)) {
    mm <- unique(stats::na.omit(as.character(dat$measure)))
    if (length(mm) == 1L) measure <- mm
  }
  if (is.null(measure)) measure <- if (identical(.apm_name_quo(qe), "lnRR")) "ROM" else "GEN"

  out <- list(
    backend_fit = fit,
    coefficients = cf,
    vcov = cv,
    data = dat,
    source_data = dat_complete,
    V = V,
    Slist = Slist,
    dose_info = list(
      dose_name = .apm_name_quo(qd), study_name = .apm_name_quo(qs), effect_name = .apm_name_quo(qe),
      form = form, df = df, reference = reference, basis = basis$info, basis_names = bnames,
      basis_dimension = p_basis, moderators = moderators
    ),
    prediction_grid = pred_grid,
    gof = gof,
    covariance = list(
      mode = covariance, source = covariance_source,
      Slist_dimensions = vapply(Slist, nrow, integer(1))
    ),
    row_provenance = list(
      complete_rows = complete_idx,
      reference_rows = reference_idx,
      analysis_rows = analysis_idx,
      omitted_rows = which(!complete)
    ),
    settings = list(method = method, backend = backend, mods = if (backend == "dosresmeta") fml_dos else fml_metafor, random = NULL),
    measure = measure,
    data_hash = .apm_hash_data(dat0[analysis_idx, , drop = FALSE]),
    source_data_hash = .apm_hash_data(dat_complete),
    backend_version = backend_version
  )
  class(out) <- c("apm_dose", "apm_model")
  out
}
