.apm_require <- function(pkg, feature = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    msg <- paste0("Package '", pkg, "' is required", if (!is.null(feature)) paste0(" for ", feature) else "", ".")
    .apm_abort(msg)
  }
  invisible(TRUE)
}

.apm_backend_version <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) return(NA_character_)
  as.character(utils::packageVersion(pkg))
}
