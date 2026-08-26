#' Validate study summaries, binary data, or precomputed effects
#'
#' @param data A data frame or `apm_data` object.
#' @param schema One of `"summary"`, `"binary"`, or `"effect"`.
#' @param roles Optional named role-to-column mapping.
#' @param strict If `TRUE`, validation errors stop; otherwise they are returned.
#' @return An `apm_validation` object.
#' @export
#' @examples
#' # Example 1: continuous treatment-control summaries.
#' apm_validate(maize_n_shared, schema = "summary", strict = FALSE)
#' # Example 2: binary pest-suppression data.
#' apm_validate(pest_suppression_binary, schema = "binary", strict = FALSE)
#' # Example 3: precomputed effect sizes.
#' apm_validate(agri_effects_benchmark, schema = "effect", strict = FALSE)
apm_validate <- function(data, schema = c("summary", "binary", "effect"), roles = NULL, strict = TRUE) {
  schema <- match.arg(schema); dat <- .apm_df(data); issues <- list()
  if (anyDuplicated(names(dat))) issues[[length(issues)+1L]] <- .apm_issue("error","duplicate_columns","Column names are not unique.")
  num_names <- names(dat)[vapply(dat, is.numeric, logical(1))]
  ncols <- intersect(c("n","n_t","n_c","n_pairs"), num_names)
  for (nm in ncols) if (any(dat[[nm]] <= 0, na.rm=TRUE)) issues[[length(issues)+1L]] <- .apm_issue("error","nonpositive_n",paste0(nm," must be positive."), paste(which(dat[[nm]] <= 0), collapse=","))
  sdcols <- intersect(c("sd","sd_t","sd_c","se","se_t","se_c","vi"), num_names)
  for (nm in sdcols) if (any(dat[[nm]] < 0, na.rm=TRUE)) issues[[length(issues)+1L]] <- .apm_issue("error","negative_uncertainty",paste0(nm," cannot be negative."), paste(which(dat[[nm]] < 0), collapse=","))
  if (schema == "effect") {
    miss <- setdiff(c("yi","vi"), names(dat)); if (length(miss)) issues[[length(issues)+1L]] <- .apm_issue("error","missing_effect_fields",paste("Missing",paste(miss,collapse=", ")))
    if ("vi" %in% names(dat) && any(dat$vi <= 0, na.rm=TRUE)) issues[[length(issues)+1L]] <- .apm_issue("error","nonpositive_vi","Sampling variances must be positive.",paste(which(dat$vi <= 0),collapse=","))
  }
  if (schema == "binary") {
    pairs <- list(c("event_t","n_t"), c("event_c","n_c"))
    for (pr in pairs) if (all(pr %in% names(dat))) {
      bad <- which(dat[[pr[1]]] < 0 | dat[[pr[1]]] > dat[[pr[2]]])
      if (length(bad)) issues[[length(issues)+1L]] <- .apm_issue("error","event_count_out_of_range",paste0(pr[1]," must lie between 0 and ",pr[2],"."),paste(bad,collapse=","))
    }
  }
  if (!is.null(roles)) {
    miss <- setdiff(unname(roles), names(dat)); if (length(miss)) issues[[length(issues)+1L]] <- .apm_issue("error","missing_role_columns",paste("Missing mapped columns:",paste(miss,collapse=", ")))
  }
  tab <- .apm_bind_issues(issues); ok <- !any(tab$severity == "error")
  out <- list(ok=ok, issues=tab, field_summary=data.frame(field=names(dat), class=vapply(dat,function(x) paste(class(x),collapse="/"),character(1)), missing=vapply(dat,function(x) sum(is.na(x)),integer(1))), roles=roles, schema=schema)
  class(out) <- "apm_validation"
  if (strict && !ok) .apm_abort("Validation failed with {sum(tab$severity=='error')} error(s). Run with {.code strict = FALSE} to inspect all issues.")
  out
}
