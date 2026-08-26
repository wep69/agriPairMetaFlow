#' Audit agronomic meta-analysis data and design semantics
#'
#' @param data Raw or effect-size data.
#' @param plan Optional `apm_plan`.
#' @param level Audit depth.
#' @param repair Allow only deterministic reversible label repairs.
#' @return An `apm_audit` object with severity-ranked issues and recommendations.
#' @export
#' @examples
#' # Example 1: detect shared controls in nitrogen experiments.
#' apm_audit(maize_n_shared, level = "full")
#' # Example 2: identify heterogeneous uncertainty reporting.
#' apm_audit(agri_uncertainty_mixed, level = "full")
#' # Example 3: audit multiresponse soil-management summaries.
#' apm_audit(soil_management_multiresponse, level = "basic")
apm_audit <- function(data, plan = NULL, level = c("basic", "full"), repair = FALSE) {
  level <- match.arg(level); dat <- .apm_df(data); issues <- list(); repairs <- data.frame()
  if (anyDuplicated(dat)) issues[[length(issues)+1L]] <- .apm_issue("warning","duplicate_rows","Exact duplicate rows were detected.",paste(which(duplicated(dat)),collapse=","),"Verify duplicate extraction; no rows were removed.")
  idcols <- intersect(c("study_id","study","paper_id","experiment_id","effect_id"), names(dat))
  for (nm in idcols) if (any(is.na(dat[[nm]]) | trimws(as.character(dat[[nm]])) == "")) issues[[length(issues)+1L]] <- .apm_issue("error","missing_identifier",paste0("Missing values in identifier column ",nm,"."))
  if (all(c("study_id","control","treatment") %in% names(dat))) {
    key <- paste(dat$study_id, if ("experiment_id" %in% names(dat)) dat$experiment_id else "", dat$control, sep="::")
    counts <- tapply(as.character(dat$treatment), key, function(x) length(unique(x)))
    shared <- names(counts)[counts > 1L]
    if (length(shared)) issues[[length(issues)+1L]] <- .apm_issue("warning","shared_control",paste0(length(shared)," study/experiment control arm(s) are reused across multiple treatment contrasts."),action="Model sampling dependence in version 0.2.0 or use one independent contrast per experiment in 0.1.0.")
  }
  unc <- intersect(c("sd_t","sd_c","se_t","se_c","cv_t","cv_c","mse"), names(dat))
  if (level == "full" && length(unc)) {
    allmiss <- apply(dat[unc],1,function(z) all(is.na(z)))
    if (any(allmiss)) issues[[length(issues)+1L]] <- .apm_issue("warning","missing_uncertainty","Rows without recognized uncertainty information were detected.",paste(which(allmiss),collapse=","),"Recover uncertainty only when algebraically justified.")
  }
  if (repair) {
    chr <- names(dat)[vapply(dat,is.character,logical(1))]
    for (nm in chr) {
      new <- trimws(dat[[nm]])
      if (!identical(new,dat[[nm]])) { dat[[nm]] <- new; repairs <- rbind(repairs,data.frame(field=nm,action="trim_whitespace",stringsAsFactors=FALSE)) }
    }
  }
  tab <- .apm_bind_issues(issues)
  out <- list(issues=tab, severities=table(factor(tab$severity,levels=c("error","warning","info"))), recommendations=unique(tab$action[!is.na(tab$action)]), repair_log=repairs, data=dat, level=level)
  class(out) <- "apm_audit"; out
}
