.apm_formula_vars <- function(formula) {
  if (!inherits(formula, "formula")) .apm_abort("{.arg moderators} must be a formula.")
  unique(all.vars(formula))
}

.apm_add_interactions <- function(formula, interactions = NULL) {
  if (is.null(interactions) || !length(interactions)) return(formula)
  if (!inherits(formula, "formula")) .apm_abort("{.arg moderators} must be a formula.")
  ints <- as.character(interactions)
  if (any(!nzchar(ints))) .apm_abort("{.arg interactions} cannot contain empty terms.")
  rhs <- paste(c(deparse(formula[[2L]]), ints), collapse = " + ")
  stats::as.formula(paste("~", rhs), env = environment(formula))
}

.apm_prepare_moderators <- function(data, formula, center = TRUE, scale = FALSE) {
  vars <- .apm_formula_vars(formula)
  miss <- setdiff(vars, names(data))
  if (length(miss)) .apm_abort("Moderator variables not found: {paste(miss, collapse=', ')}")
  out <- data
  centers <- setNames(rep(0, length(vars)), vars)
  scales <- setNames(rep(1, length(vars)), vars)
  factor_levels <- list()
  support <- list()
  sparse <- list()

  for (v in vars) {
    z <- out[[v]]
    if (is.character(z)) z <- factor(z)
    if (is.factor(z)) {
      factor_levels[[v]] <- levels(z)
      counts <- table(z, useNA = "no")
      if (length(counts) && any(counts < 3L)) sparse[[v]] <- counts[counts < 3L]
      out[[v]] <- z
      support[[v]] <- list(type = "factor", levels = levels(z))
    } else if (is.numeric(z)) {
      if (any(!is.finite(z))) .apm_abort("Continuous moderator {.field {v}} contains missing or non-finite values.")
      if (length(unique(z)) < 2L) .apm_abort("Continuous moderator {.field {v}} has no variation.")
      support[[v]] <- list(type = "numeric", min = min(z), max = max(z), unique = length(unique(z)))
      if (isTRUE(center)) centers[[v]] <- mean(z)
      if (isTRUE(scale)) {
        s <- stats::sd(z)
        if (!is.finite(s) || s <= 0) .apm_abort("Continuous moderator {.field {v}} cannot be scaled because its SD is zero or non-finite.")
        scales[[v]] <- s
      }
      out[[v]] <- (z - centers[[v]]) / scales[[v]]
    } else {
      .apm_abort("Moderator {.field {v}} must be numeric, factor, or character.")
    }
  }

  if (length(sparse)) {
    txt <- paste(vapply(names(sparse), function(v) paste0(v, ": ", paste(names(sparse[[v]]), collapse = ", ")), character(1)), collapse = "; ")
    .apm_warn("Sparse moderator levels (<3 effects) detected: {txt}. Interpret subgroup coefficients cautiously.")
  }

  mm <- stats::model.matrix(formula, data = out)
  list(
    data = out,
    formula = formula,
    variables = vars,
    centers = centers,
    scales = scales,
    factor_levels = factor_levels,
    support = support,
    model_matrix_colnames = colnames(mm),
    sparse_levels = sparse
  )
}

.apm_prepare_newdata <- function(model, newdata, require_all = TRUE) {
  if (!inherits(model, "apm_metareg")) .apm_abort("{.arg model} must inherit from apm_metareg.")
  if (!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
  info <- model$moderator_info
  vars <- info$variables %||% character()
  if (require_all) {
    miss <- setdiff(vars, names(newdata))
    if (length(miss)) .apm_abort("New-data moderator variables missing: {paste(miss, collapse=', ')}")
  }
  out <- newdata
  for (v in intersect(vars, names(out))) {
    sup <- info$support[[v]]
    if (identical(sup$type, "factor")) {
      bad <- setdiff(unique(as.character(out[[v]])), sup$levels)
      bad <- bad[!is.na(bad)]
      if (length(bad)) .apm_abort("Unknown level(s) for {.field {v}}: {paste(bad, collapse=', ')}")
      out[[v]] <- factor(as.character(out[[v]]), levels = sup$levels)
    } else if (identical(sup$type, "numeric")) {
      if (!is.numeric(out[[v]]) || any(!is.finite(out[[v]]))) .apm_abort("New values for {.field {v}} must be finite numeric values.")
      out[[v]] <- (out[[v]] - info$centers[[v]]) / info$scales[[v]]
    }
  }
  out
}

.apm_model_matrix_meta <- function(model, newdata) {
  nd <- .apm_prepare_newdata(model, newdata, require_all = TRUE)
  mm <- stats::model.matrix(model$moderator_info$formula, data = nd)
  train_cols <- model$moderator_info$model_matrix_colnames
  missing_cols <- setdiff(train_cols, colnames(mm))
  if (length(missing_cols)) {
    add <- matrix(0, nrow = nrow(mm), ncol = length(missing_cols), dimnames = list(NULL, missing_cols))
    mm <- cbind(mm, add)
  }
  extra <- setdiff(colnames(mm), train_cols)
  if (length(extra)) .apm_abort("New-data model matrix contains unsupported columns: {paste(extra, collapse=', ')}")
  mm <- mm[, train_cols, drop = FALSE]
  if ("(Intercept)" %in% colnames(mm)) mm <- mm[, setdiff(colnames(mm), "(Intercept)"), drop = FALSE]
  list(matrix = mm, data = nd)
}

.apm_support_flags <- function(model, newdata) {
  info <- model$moderator_info
  out <- rep("interpolation", nrow(newdata))
  details <- vector("list", nrow(newdata))
  for (i in seq_len(nrow(newdata))) {
    flags <- character()
    for (v in info$variables) {
      sup <- info$support[[v]]
      if (identical(sup$type, "numeric")) {
        z <- newdata[[v]][i]
        if (is.numeric(z) && is.finite(z) && (z < sup$min || z > sup$max)) flags <- c(flags, v)
      }
    }
    if (length(flags)) out[i] <- "extrapolation"
    details[[i]] <- flags
  }
  list(flag = out, variables = details)
}

.apm_predict_meta_matrix <- function(model, X, level = 0.95, prediction = TRUE) {
  fit <- model$backend_fit
  pr <- tryCatch(
    stats::predict(fit, newmods = X, level = level * 100),
    error = function(e) e
  )
  if (inherits(pr, "error")) .apm_abort("Backend prediction failed: {conditionMessage(pr)}")
  pi_lb <- pr$pi.lb %||% rep(NA_real_, length(pr$pred))
  pi_ub <- pr$pi.ub %||% rep(NA_real_, length(pr$pred))
  if (!isTRUE(prediction)) {
    pi_lb[] <- NA_real_
    pi_ub[] <- NA_real_
  }
  data.frame(
    pred = as.numeric(pr$pred),
    se = as.numeric(pr$se),
    ci_lower = as.numeric(pr$ci.lb),
    ci_upper = as.numeric(pr$ci.ub),
    pi_lower = as.numeric(pi_lb),
    pi_upper = as.numeric(pi_ub),
    stringsAsFactors = FALSE
  )
}

.apm_transform_prediction <- function(tab, measure, transform) {
  out <- tab
  for (nm in intersect(c("pred", "ci_lower", "ci_upper", "pi_lower", "pi_upper"), names(out))) {
    out[[nm]] <- .apm_transform_vector(out[[nm]], measure, transform)
  }
  out
}

.apm_marginal_weights <- function(data, type = c("equal", "study")) {
  type <- match.arg(type)
  if (type == "equal") return(rep(1 / nrow(data), nrow(data)))
  if (!"study_id" %in% names(data)) .apm_abort("weights='study' requires a {.field study_id} column in the fitted data.")
  ids <- as.character(data$study_id)
  nstud <- length(unique(ids))
  within <- ave(rep(1, length(ids)), ids, FUN = length)
  1 / (nstud * within)
}

.apm_meta_r2 <- function(fit, null_fit) {
  if (inherits(fit, "rma.mv")) {
    a <- sum(c(fit$sigma2 %||% numeric(), fit$tau2 %||% numeric(), fit$gamma2 %||% numeric()), na.rm = TRUE)
    b <- sum(c(null_fit$sigma2 %||% numeric(), null_fit$tau2 %||% numeric(), null_fit$gamma2 %||% numeric()), na.rm = TRUE)
  } else {
    a <- fit$tau2 %||% NA_real_
    b <- null_fit$tau2 %||% NA_real_
  }
  if (!is.finite(a) || !is.finite(b) || b <= 0) return(NA_real_)
  100 * (b - a) / b
}

.apm_curve_basis <- function(x, form, df = 3, knots = NULL, boundary = NULL, center = NULL) {
  form <- match.arg(form, c("linear", "quadratic", "cubic", "ns", "rcs"))
  if (!is.numeric(x) || any(!is.finite(x))) .apm_abort("Curve moderator values must be finite numeric values.")
  if (is.null(boundary)) boundary <- range(x)
  if (is.null(center)) center <- mean(x)
  z <- x - center
  if (form == "linear") {
    B <- cbind(.apm_x1 = z)
  } else if (form == "quadratic") {
    B <- cbind(.apm_x1 = z, .apm_x2 = z^2)
  } else if (form == "cubic") {
    B <- cbind(.apm_x1 = z, .apm_x2 = z^2, .apm_x3 = z^3)
  } else if (form == "ns") {
    if (df < 2L) .apm_abort("Natural splines require df >= 2.")
    B <- splines::ns(x, df = df, knots = knots, Boundary.knots = boundary, intercept = FALSE)
    colnames(B) <- paste0(".apm_b", seq_len(ncol(B)))
    knots <- attr(B, "knots")
  } else {
    if (is.null(knots)) {
      nk <- max(4L, as.integer(df) + 1L)
      probs <- seq(0.05, 0.95, length.out = nk)
      knots <- as.numeric(stats::quantile(x, probs = probs, names = FALSE, type = 8))
      knots <- unique(knots)
    }
    if (length(knots) < 4L) .apm_abort("Restricted cubic splines require at least four unique knots.")
    if (min(knots) < boundary[1] || max(knots) > boundary[2]) .apm_abort("Restricted cubic spline knots must lie within observed moderator support.")
    K <- length(knots)
    tp <- function(a) pmax(a, 0)^3
    den <- (knots[K] - knots[1])^2
    H <- sapply(seq_len(K - 2L), function(j) {
      (tp(x - knots[j]) - tp(x - knots[K - 1L]) * (knots[K] - knots[j]) / (knots[K] - knots[K - 1L]) +
         tp(x - knots[K]) * (knots[K - 1L] - knots[j]) / (knots[K] - knots[K - 1L])) / den
    })
    if (is.null(dim(H))) H <- matrix(H, ncol = 1L)
    B <- cbind(.apm_x1 = z, H)
    if (ncol(H)) colnames(B)[-1L] <- paste0(".apm_rcs", seq_len(ncol(H)))
  }
  list(matrix = as.matrix(B), form = form, df = df, knots = knots, boundary = boundary, center = center)
}

.apm_curve_design <- function(curve, x) {
  meta <- curve$curve_info
  .apm_curve_basis(x, form = meta$form, df = meta$df, knots = meta$knots, boundary = meta$boundary, center = meta$center)$matrix
}

.apm_curve_predict_raw <- function(curve, x, level = 0.95, prediction = TRUE) {
  X <- .apm_curve_design(curve, x)
  .apm_predict_meta_matrix(curve, X, level = level, prediction = prediction)
}

.apm_numeric_derivative_design <- function(curve, x) {
  span <- diff(curve$curve_info$boundary)
  h <- max(span * 1e-5, .Machine$double.eps^0.25 * max(1, abs(x)))
  (.apm_curve_design(curve, x + h) - .apm_curve_design(curve, x - h)) / (2 * h)
}

.apm_root_intervals <- function(x, y) {
  ok <- is.finite(x) & is.finite(y)
  x <- x[ok]; y <- y[ok]
  if (length(x) < 2L) return(numeric())
  hit <- which(y[-length(y)] == 0 | y[-length(y)] * y[-1L] < 0)
  if (!length(hit)) return(numeric())
  vapply(hit, function(i) {
    if (y[i] == 0) return(x[i])
    x[i] + (0 - y[i]) * (x[i + 1L] - x[i]) / (y[i + 1L] - y[i])
  }, numeric(1))
}

.apm_dose_basis <- function(dose, form = c("linear","quadratic","ns"), df = 3, reference = 0, meta = NULL) {
  form<-match.arg(form)
  if(!is.numeric(dose)||any(!is.finite(dose))) .apm_abort("Dose values must be finite numeric values.")
  if(form=="linear") {
    B<-cbind(.apm_d1=dose-reference); info<-list(form=form,df=1,reference=reference,knots=NULL,boundary=range(c(reference,dose)))
  } else if(form=="quadratic") {
    B<-cbind(.apm_d1=dose-reference,.apm_d2=dose^2-reference^2); info<-list(form=form,df=2,reference=reference,knots=NULL,boundary=range(c(reference,dose)))
  } else {
    if(is.null(meta)) {
      boundary<-range(c(reference,dose)); tmp<-splines::ns(c(reference,dose),df=df,Boundary.knots=boundary,intercept=FALSE)
      refrow<-tmp[1,,drop=FALSE];B<-tmp[-1,,drop=FALSE]-matrix(rep(refrow,length(dose)),nrow=length(dose),byrow=TRUE)
      info<-list(form=form,df=df,reference=reference,knots=attr(tmp,"knots"),boundary=attr(tmp,"Boundary.knots"))
    } else {
      tmp<-splines::ns(c(reference,dose),knots=meta$knots,Boundary.knots=meta$boundary,intercept=FALSE)
      refrow<-tmp[1,,drop=FALSE];B<-tmp[-1,,drop=FALSE]-matrix(rep(refrow,length(dose)),nrow=length(dose),byrow=TRUE);info<-meta
    }
    colnames(B)<-paste0(".apm_d",seq_len(ncol(B)))
  }
  list(matrix=as.matrix(B),info=info)
}

.apm_inference_df <- function(model) {
  fit <- model$backend_fit
  test <- tolower(as.character(model$settings$test %||% fit$test %||% "z")[1])
  if (!test %in% c("t", "knha", "hksj", "adhoc")) return(Inf)
  cand <- c(fit$ddf %||% numeric(), (fit$k %||% NA_real_) - (fit$p %||% length(stats::coef(fit))))
  cand <- suppressWarnings(as.numeric(cand))
  cand <- cand[is.finite(cand) & cand > 0]
  if (!length(cand)) return(NA_real_)
  min(cand)
}

.apm_critical_value <- function(model, level = 0.95) {
  alpha <- 1 - level
  df <- .apm_inference_df(model)
  if (is.finite(df)) return(stats::qt(1 - alpha / 2, df = df))
  stats::qnorm(1 - alpha / 2)
}

.apm_two_sided_p <- function(model, statistic) {
  df <- .apm_inference_df(model)
  if (is.finite(df)) return(2 * stats::pt(-abs(statistic), df = df))
  2 * stats::pnorm(-abs(statistic))
}
