# Capability registry -------------------------------------------------------

.apm_capability_registry <- function() {
  data.frame(
    feature = c(
      "core", "effect-sizes", "random-effects", "shared-control", "multilevel",
      "robust", "wild-bootstrap", "meta-regression", "dose-response",
      "multivariate", "bayesian", "bayesian", "bayesian", "publication-bias",
      "publication-bias", "moderator-screen", "interactive", "reports", "xlsx-export",
      "cmdstan"
    ),
    capability = c(
      "package core", "treatment-control effect sizes", "common/random/mixed models",
      "sampling covariance for reused arms", "hierarchical meta-analysis",
      "cluster-robust CR inference", "cluster wild bootstrap", "quantitative/categorical moderators",
      "correlated within-study dose-response", "multivariate outcomes",
      "normal-normal Bayesian meta-analysis", "robust Bayesian model averaging",
      "general Bayesian multilevel models", "selection/sensitivity models",
      "selection-ratio and Copas sensitivity", "exploratory MetaForest screening",
      "interactive plot conversion", "HTML/DOCX/PDF reporting", "XLSX export",
      "CmdStan backend for brms"
    ),
    backend = c(
      "agriPairMetaFlow", "metafor", "metafor", "metafor", "metafor",
      "clubSandwich", "wildmeta", "metafor", "dosresmeta", "mixmeta",
      "bayesmeta", "RoBMA", "brms", "metafor", "PublicationBias/metasens",
      "metaforest", "plotly/htmlwidgets", "rmarkdown/knitr", "openxlsx2", "cmdstanr"
    ),
    package = c(
      "agriPairMetaFlow", "metafor", "metafor", "metafor", "metafor",
      "clubSandwich", "wildmeta", "metafor", "dosresmeta", "mixmeta",
      "bayesmeta", "RoBMA", "brms", "metafor", "PublicationBias", "metaforest",
      "plotly", "rmarkdown", "openxlsx2", "cmdstanr"
    ),
    minimum_version = c(
      NA, "5.0-1", "5.0-1", "5.0-1", "5.0-1", NA, NA, "5.0-1", "2.2.0",
      "1.2.2", "3.5", "4.0.0", NA, "5.0-1", "2.4.0", "0.1.5", NA, NA, NA, NA
    ),
    core = c(
      TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE,
      FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE
    ),
    validation_tier = c(
      "release", "tier-2", "tier-2", "tier-2", "tier-2", "tier-2", "tier-3",
      "tier-2", "tier-2", "tier-2", "tier-3", "tier-3", "tier-3", "tier-2",
      "tier-2", "tier-3", "smoke", "render", "round-trip", "system"
    ),
    stringsAsFactors = FALSE
  )
}

.apm_version_ok <- function(pkg, minimum) {
  if (!requireNamespace(pkg, quietly = TRUE)) return(FALSE)
  if (is.na(minimum) || !nzchar(minimum)) return(TRUE)
  tryCatch(utils::packageVersion(pkg) >= package_version(minimum), error = function(e) FALSE)
}

#' Report agriPairMetaFlow capabilities and optional backends
#'
#' @param feature Optional feature filter such as `"bayesian"`, `"dose-response"`,
#'   or `"robust"`. Partial matching is not used.
#' @param installed If `TRUE`, inspect whether registered R packages and relevant
#'   system engines are available. The function never installs anything.
#' @param detail Output detail level.
#' @return A data frame describing features, backends, version policy,
#'   installation status, and validation tier.
#' @export
#' @examples
#' # Example 1: inspect the complete package capability registry.
#' apm_capabilities()
#' # Example 2: inspect all Bayesian routes before a soil-carbon synthesis.
#' apm_capabilities("bayesian", detail="full")
#' # Example 3: verify whether the dose-response backend is locally available.
#' apm_capabilities("dose-response", installed=TRUE)
apm_capabilities <- function(feature = NULL, installed = TRUE, detail = c("summary", "full")) {
  detail <- match.arg(detail)
  reg <- .apm_capability_registry()
  if (!is.null(feature)) {
    if (!is.character(feature) || !length(feature) || anyNA(feature))
      .apm_abort("{.arg feature} must be NULL or a non-missing character vector.")
    keep <- reg$feature %in% feature
    if (!any(keep)) .apm_abort("Unknown capability feature: {paste(feature, collapse=', ')}. Use apm_capabilities() to list registered features.")
    reg <- reg[keep, , drop = FALSE]
  }

  reg$installed <- NA
  reg$version <- NA_character_
  reg$version_ok <- NA
  reg$system_ready <- NA
  reg$status <- ifelse(reg$core, "REGISTERED CORE", "REGISTERED OPTIONAL")

  if (isTRUE(installed)) {
    for (i in seq_len(nrow(reg))) {
      pkg <- reg$package[i]
      ok <- if (identical(pkg, "agriPairMetaFlow")) TRUE else requireNamespace(pkg, quietly = TRUE)
      reg$installed[i] <- ok
      reg$version[i] <- if (ok && !identical(pkg, "agriPairMetaFlow")) .apm_backend_version(pkg) else if (ok) as.character(utils::packageVersion("agriPairMetaFlow")) else NA_character_
      reg$version_ok[i] <- if (ok && !identical(pkg, "agriPairMetaFlow")) .apm_version_ok(pkg, reg$minimum_version[i]) else ok
      reg$system_ready[i] <- TRUE
      if (identical(pkg, "cmdstanr")) {
        reg$system_ready[i] <- if (ok) tryCatch(nzchar(cmdstanr::cmdstan_version(error_on_NA = FALSE) %||% ""), error=function(e) FALSE) else FALSE
      }
      reg$status[i] <- if (!ok) {
        if (reg$core[i]) "MISSING CORE" else "NOT INSTALLED"
      } else if (!isTRUE(reg$version_ok[i])) {
        "VERSION TOO OLD"
      } else if (!isTRUE(reg$system_ready[i])) {
        "PACKAGE PRESENT / SYSTEM ENGINE MISSING"
      } else "AVAILABLE"
    }
  }

  reg$validation_status <- ifelse(reg$core,
    "core-runtime-validation-required-for-release",
    paste0(reg$validation_tier, "-local-validation-required"))
  reg$notes <- ifelse(reg$core,
    "Required for the core package workflow.",
    "Optional capability; absence must not break the core package.")

  class(reg) <- c("apm_capabilities", class(reg))
  if (detail == "summary") {
    keep <- c("feature","backend","core","installed","version","status","validation_status")
    reg <- reg[, keep, drop = FALSE]
    class(reg) <- unique(c("apm_capabilities", class(reg)))
  }
  reg
}
