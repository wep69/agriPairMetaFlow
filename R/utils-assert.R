`%||%` <- function(x, y) if (is.null(x)) y else x

.apm_abort <- function(message, ..., call = rlang::caller_env()) {
  cli::cli_abort(message, ..., call = call, .envir = call)
}

.apm_warn <- function(message, ..., call = rlang::caller_env()) {
  cli::cli_warn(message, ..., call = call, .envir = call)
}

.apm_df <- function(x) {
  if (inherits(x, "apm_data")) return(x$data)
  if (inherits(x, "apm_uncertainty")) return(x$data)
  if (inherits(x, "apm_effects")) return(as.data.frame(x))
  if (is.data.frame(x)) return(x)
  .apm_abort("{.arg data} must be a data frame or an agriPairMetaFlow data object.")
}

.apm_pull_quo <- function(data, quo, arg, required = FALSE) {
  if (rlang::quo_is_null(quo)) {
    if (required) .apm_abort("{.arg {arg}} is required.")
    return(NULL)
  }
  val <- tryCatch(rlang::eval_tidy(quo, data = data), error = function(e) e)
  if (inherits(val, "error")) .apm_abort("Could not evaluate {.arg {arg}}: {conditionMessage(val)}")
  if (length(val) == 1L && nrow(data) != 1L) val <- rep(val, nrow(data))
  if (length(val) != nrow(data)) .apm_abort("{.arg {arg}} must evaluate to one value per row.")
  val
}

.apm_name_quo <- function(quo) {
  if (rlang::quo_is_null(quo)) return(NA_character_)
  expr <- rlang::get_expr(quo)
  if (rlang::is_symbol(expr)) return(rlang::as_name(expr))
  rlang::expr_text(expr)
}

.apm_check_numeric <- function(x, arg, finite = TRUE) {
  if (!is.numeric(x)) .apm_abort("{.arg {arg}} must be numeric.")
  if (finite && any(!is.finite(x), na.rm = TRUE)) .apm_abort("{.arg {arg}} contains non-finite values.")
  invisible(TRUE)
}

.apm_issue <- function(severity, code, message, rows = NA_character_, action = NA_character_) {
  data.frame(severity=severity, code=code, message=message, rows=rows, action=action, stringsAsFactors=FALSE)
}

.apm_bind_issues <- function(xs) {
  xs <- xs[lengths(xs) > 0L]
  if (!length(xs)) return(data.frame(severity=character(), code=character(), message=character(), rows=character(), action=character(), stringsAsFactors=FALSE))
  do.call(rbind, xs)
}


.apm_hash_data <- function(x) {
  tf <- tempfile(fileext = ".rds")
  on.exit(unlink(tf), add = TRUE)
  saveRDS(x, tf, version = 2)
  unname(tools::md5sum(tf))
}
