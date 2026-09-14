# Leave-one-out diagnostics ----------------------------------------------

#' Leave-one-study or leave-one-effect sensitivity analysis
#'
#' Repeats the fitted meta-analysis after omitting one independent study or one
#' effect at a time. Failed refits are retained. Effect-level deletion is never
#' silently substituted for study-level deletion when dependent effects exist.
#'
#' @param model An `apm_model` or subclass.
#' @param unit Delete whole studies or individual effects.
#' @param cluster Optional study/cluster vector or fitted-data column name.
#' @param transform Output transformation.
#' @param parallel Use multicore refits on supported non-Windows systems.
#' @return An `apm_sensitivity` object with refitted estimates, intervals,
#'   heterogeneity and changes from the full model.
#' @export
#' @examples
#' # Example 1: independent yield-response studies.
#' apm_leave_one_out(apm_fit(agri_effects_benchmark), unit="study")
#' # Example 2: explicit effect-level sensitivity as a diagnostic.
#' apm_leave_one_out(apm_fit(agri_effects_benchmark), unit="effect")
#' # Example 3: report results on the percent-change scale.
#' apm_leave_one_out(apm_fit(agri_effects_benchmark), transform="percent")
apm_leave_one_out <- function(model, unit = c("study", "effect"), cluster = NULL,
                              transform = c("auto", "none", "exp", "percent"),
                              parallel = FALSE) {
  .apm_require("metafor", "leave-one-out diagnostics")
  if (!inherits(model, "apm_model")) .apm_abort("{.arg model} must inherit from apm_model.")
  unit <- match.arg(unit); transform <- match.arg(transform)
  dat <- model$data
  if (nrow(dat) < 3L) .apm_abort("At least three fitted effects are required for leave-one-out diagnostics.")
  cl <- if (unit == "study") .apm_resolve_cluster(model, cluster, required=TRUE) else seq_len(nrow(dat))
  if (unit == "effect") {
    dep <- !is.null(model$V) && any(abs(model$V[row(model$V) != col(model$V)]) > 1e-12, na.rm=TRUE)
    if (dep || inherits(model, "apm_multilevel")) .apm_warn("Effect-level deletion was explicitly requested for a dependence-aware model. Interpret it as a diagnostic, not as independent-study sensitivity.")
  }
  groups <- unique(as.character(cl))
  full <- .apm_fit_summary_row(model$backend_fit, "full", model$measure)
  worker <- function(g) {
    keep <- as.character(cl) != g
    tryCatch(.apm_fit_summary_row(.apm_refit_subset(model, keep), g, model$measure),
      error=function(e) .apm_failed_refit_row(g,e))
  }
  rows <- if (isTRUE(parallel) && .Platform$OS.type != "windows" && length(groups) > 2L) {
    parallel::mclapply(groups, worker, mc.cores=max(1L, min(length(groups), parallel::detectCores()-1L)))
  } else {
    if (isTRUE(parallel) && .Platform$OS.type == "windows") .apm_warn("parallel=TRUE uses sequential refits on Windows.")
    lapply(groups, worker)
  }
  res <- do.call(rbind, rows)
  res$estimate_change <- res$estimate - full$estimate
  res$heterogeneity_change <- res$heterogeneity_variance - full$heterogeneity_variance
  raw <- res
  for (nm in c("estimate","ci_lower","ci_upper","pi_lower","pi_upper"))
    res[[nm]] <- .apm_transform_vector(res[[nm]], model$measure, transform)
  backend_reference <- NULL
  if (unit == "effect" && inherits(model$backend_fit,"rma.uni") && length(stats::coef(model$backend_fit)) == 1L) {
    backend_reference <- tryCatch(metafor::leave1out(model$backend_fit), error=function(e) NULL)
  }
  out <- list(results=res, raw=raw, full=full, unit=unit, cluster=cl,
    n_fail=sum(!raw$success), transform=transform, measure=model$measure,
    backend_reference=backend_reference, model_hash=model$data_hash,
    caution="Deletion diagnostics describe sensitivity; they do not justify automatic study exclusion.")
  class(out) <- "apm_sensitivity"
  out
}
