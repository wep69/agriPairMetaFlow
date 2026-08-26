#' Read meta-analytic study data with provenance
#'
#' Reads CSV, Excel, or RDS study-level data and attaches explicit role, unit,
#' source, and import metadata. Import never performs statistical imputation.
#'
#' @param path Path to a `.csv`, `.xlsx`, `.xls`, or `.rds` file.
#' @param sheet Excel sheet name or index.
#' @param mapping Optional named character vector mapping scientific roles to columns.
#' @param na Character values interpreted as missing data.
#' @param units Optional named character vector of units.
#' @param strict If `TRUE`, unsupported or ambiguous inputs are errors.
#' @return An object of class `apm_data`.
#' @export
#' @examples
#' # Example 1: maize nitrogen experiments bundled with the package.
#' f1 <- system.file("extdata", "maize_n_shared.csv", package = "agriPairMetaFlow")
#' if (nzchar(f1)) maize <- apm_read(f1)
#'
#' # Example 2: uncertainty fields imported from CSV.
#' f2 <- system.file("extdata", "agri_uncertainty_mixed.csv", package = "agriPairMetaFlow")
#' if (nzchar(f2)) unc <- apm_read(f2, mapping = c(study = "study_id"))
#'
#' # Example 3: explicit agronomic units.
#' f3 <- system.file("extdata", "soil_management_multiresponse.csv", package = "agriPairMetaFlow")
#' if (nzchar(f3)) soil <- apm_read(f3, units = c(mean_t = "Mg ha-1", mean_c = "Mg ha-1"))
apm_read <- function(path, sheet = NULL, mapping = NULL, na = c("", "NA"), units = NULL, strict = TRUE) {
  if (!is.character(path) || length(path) != 1L || !nzchar(path)) .apm_abort("{.arg path} must be one non-empty file path.")
  if (!file.exists(path)) .apm_abort("File does not exist: {.path {path}}")
  ext <- tolower(tools::file_ext(path))
  if (ext == "csv") {
    dat <- utils::read.csv(path, na.strings = na, check.names = FALSE, stringsAsFactors = FALSE)
  } else if (ext == "rds") {
    dat <- readRDS(path)
  } else if (ext %in% c("xlsx", "xls")) {
    if (requireNamespace("readxl", quietly = TRUE)) dat <- readxl::read_excel(path, sheet = sheet, na = na)
    else if (requireNamespace("openxlsx2", quietly = TRUE)) dat <- openxlsx2::read_xlsx(path, sheet = sheet, na.strings = na)
    else .apm_abort("Reading Excel files requires {.pkg readxl} or {.pkg openxlsx2}.")
  } else {
    .apm_abort("Unsupported file extension {.val {ext}}. Use CSV, XLSX/XLS, or RDS.")
  }
  if (!is.data.frame(dat)) {
    if (strict) .apm_abort("Imported object is not tabular.")
    dat <- as.data.frame(dat, stringsAsFactors = FALSE)
  } else dat <- as.data.frame(dat, stringsAsFactors = FALSE)
  names(dat) <- vctrs::vec_as_names(names(dat), repair = "check_unique")
  if (!is.null(mapping)) {
    if (is.null(names(mapping)) || any(!nzchar(names(mapping)))) .apm_abort("{.arg mapping} must be a named character vector.")
    missing <- setdiff(unname(mapping), names(dat))
    if (length(missing)) .apm_abort("Mapped columns not found: {paste(missing, collapse=', ')}")
  }
  if (!is.null(units)) {
    unknown <- setdiff(names(units), names(dat))
    if (length(unknown) && strict) .apm_abort("Unit map refers to unknown columns: {paste(unknown, collapse=', ')}")
  }
  out <- list(
    data = dat, mapping = mapping, units = units,
    provenance = list(path = normalizePath(path, winslash = "/", mustWork = TRUE), imported_at = as.character(Sys.time()), format = ext),
    source_hash = unname(tools::md5sum(path)), issues = list()
  )
  class(out) <- "apm_data"
  out
}
