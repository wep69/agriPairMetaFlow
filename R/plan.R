#' Plan the treatment-control estimand and experimental hierarchy
#'
#' @param data Study-level data.
#' @param study,treatment,control Required role columns.
#' @param response,experiment,effect_id,dose,site,year,outcome,block,time,cluster Optional role columns.
#' @param units Optional unit map.
#' @param design `"auto"`, `"independent"`, or genuinely `"paired"`.
#' @return An `apm_plan` object.
#' @export
#' @examples
#' # Example 1: shared-control nitrogen-rate experiments.
#' apm_plan(maize_n_shared, study=study_id, experiment=experiment_id,
#'   treatment=treatment, control=control, response=mean_t, dose=N_rate,
#'   site=site, year=year)
#' # Example 2: genuinely paired block summaries.
#' apm_plan(wheat_paired_blocks, study=study_id, treatment=treatment,
#'   control=control, response=mean_t, block=block_id, design="paired")
#' # Example 3: multicrop inoculant evidence.
#' apm_plan(bioinoculant_multicrop, study=study_id, treatment=treatment,
#'   control=control, response=mean_t, outcome=outcome, site=site)
apm_plan <- function(data, study, treatment, control, response = NULL, experiment = NULL, effect_id = NULL, dose = NULL, site = NULL, year = NULL, outcome = NULL, block = NULL, time = NULL, cluster = NULL, units = NULL, design = c("auto", "independent", "paired")) {
  design <- match.arg(design); dat <- .apm_df(data)
  qs <- list(study=rlang::enquo(study), treatment=rlang::enquo(treatment), control=rlang::enquo(control), response=rlang::enquo(response), experiment=rlang::enquo(experiment), effect_id=rlang::enquo(effect_id), dose=rlang::enquo(dose), site=rlang::enquo(site), year=rlang::enquo(year), outcome=rlang::enquo(outcome), block=rlang::enquo(block), time=rlang::enquo(time), cluster=rlang::enquo(cluster))
  vals <- lapply(names(qs), function(nm) .apm_pull_quo(dat, qs[[nm]], nm, required = nm %in% c("study","treatment","control"))); names(vals) <- names(qs)
  roles <- vapply(qs,.apm_name_quo,character(1)); roles <- roles[!vapply(vals,is.null,logical(1)) & !is.na(roles)]
  if (identical(roles[["treatment"]], roles[["control"]])) .apm_abort("Treatment and control roles cannot refer to the same column.")
  if (!is.null(vals$dose)) { .apm_check_numeric(vals$dose,"dose"); if (any(!is.finite(vals$dose),na.rm=TRUE)) .apm_abort("Dose must be finite where observed.") }
  if (design == "paired" && is.null(vals$block) && is.null(vals$time)) .apm_abort("A paired plan requires a pairing key such as {.arg block} or {.arg time}; treatment-control labeling alone is not pairing.")
  detected <- if (design == "auto") if (!is.null(vals$block)) "paired_candidate" else "independent" else design
  expv <- vals$experiment %||% rep("",nrow(dat)); key <- paste(vals$study, expv, vals$control, sep="::")
  sharing <- tapply(as.character(vals$treatment), key, function(x) length(unique(x)))
  shared_keys <- names(sharing)[sharing > 1L]
  rec <- character()
  if (length(shared_keys)) rec <- c(rec,"Shared controls detected: version 0.1.0 can audit them, but covariance modeling is introduced in 0.2.0.")
  if (identical(detected,"paired_candidate")) rec <- c(rec,"A block key was detected. Confirm that treatment and control summaries are truly correlated before using design='paired'.")
  out <- list(roles=roles, design=detected, requested_design=design, hierarchy=roles[intersect(names(roles),c("study","experiment","site","year","block","time","cluster"))], dependence=list(shared_control_keys=shared_keys, n_shared=length(shared_keys)), estimand=list(direction="treatment minus/over control", candidate_measures=c("lnRR","MD","SMD","VR","CVR")), recommendations=rec, units=units, data_hash=.apm_hash_data(dat), data=dat)
  class(out) <- "apm_plan"; out
}
