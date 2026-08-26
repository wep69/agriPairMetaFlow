.apm_measure <- function(x) {
  if (inherits(x, "apm_model")) return(x$measure %||% "GEN")
  if (inherits(x, "apm_effects")) return(attr(x, "measure") %||% "GEN")
  "GEN"
}

.apm_transform_vector <- function(x, measure, transform = c("auto","none","exp","percent")) {
  transform <- match.arg(transform)
  if (transform == "auto") transform <- if (measure %in% .apm_log_measures) "exp" else "none"
  if (transform == "none") return(x)
  if (transform == "exp") return(exp(x))
  if (transform == "percent") {
    if (!measure %in% .apm_log_measures) .apm_abort("Percent transformation is only defined here for log-ratio measures.")
    return(100 * (exp(x) - 1))
  }
  x
}

.apm_threshold_to_model <- function(threshold, measure, scale) {
  if (scale == "model" || scale == "absolute") return(threshold)
  if (!measure %in% .apm_log_measures) .apm_abort("Ratio/percent thresholds require a log-ratio effect measure.")
  if (scale == "ratio") {
    if (any(threshold <= 0)) .apm_abort("Ratio thresholds must be positive.")
    return(log(threshold))
  }
  if (scale == "percent") {
    if (any(threshold <= -100)) .apm_abort("Percent thresholds must be greater than -100.")
    return(log1p(threshold / 100))
  }
  threshold
}
