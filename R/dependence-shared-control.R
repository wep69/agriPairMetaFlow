#' Detect treatment contrasts that reuse a control arm
#'
#' @param data Data frame, `apm_plan`, or `apm_effects` object.
#' @param study Study or experiment identifier.
#' @param control_id Control-arm identifier.
#' @param treatment_id Optional treatment-arm identifier.
#' @param effect_id Optional effect identifier.
#' @param check_values Verify that repeated control summaries are numerically identical when available.
#' @return An `apm_shared_control` object describing reused controls and conflicts.
#' @export
#' @examples
#' apm_shared_control(maize_n_shared, study=experiment_id, control_id=control)
#' apm_shared_control(bioinoculant_multicrop, study=study_id, control_id=control, treatment_id=treatment)
#' apm_shared_control(soil_management_multiresponse, study=study_id, control_id=control, treatment_id=outcome)
apm_shared_control <- function(data, study, control_id, treatment_id = NULL, effect_id = NULL, check_values = TRUE) {
  dat <- if (inherits(data, "apm_plan")) data$data else .apm_df(data)
  qs <- rlang::enquo(study); qc <- rlang::enquo(control_id); qt <- rlang::enquo(treatment_id); qe <- rlang::enquo(effect_id)
  st <- .apm_pull_quo(dat, qs, "study", TRUE)
  ct <- .apm_pull_quo(dat, qc, "control_id", TRUE)
  tr <- .apm_pull_quo(dat, qt, "treatment_id", FALSE)
  ef <- .apm_pull_quo(dat, qe, "effect_id", FALSE)
  if (anyNA(st) || anyNA(ct)) .apm_abort("{.arg study} and {.arg control_id} cannot contain missing values.")
  key <- paste(st, ct, sep = "\r")
  mult <- table(key)
  shared_keys <- names(mult[mult > 1L])
  shared <- key %in% shared_keys
  groups <- data.frame(
    row = seq_len(nrow(dat)), study = as.character(st), control_id = as.character(ct),
    treatment_id = if (is.null(tr)) NA_character_ else as.character(tr),
    effect_id = if (is.null(ef)) NA_character_ else as.character(ef),
    multiplicity = as.integer(mult[key]), shared = shared,
    stringsAsFactors = FALSE
  )
  conflicts <- data.frame()
  if (isTRUE(check_values) && any(shared)) {
    candidates <- intersect(c("mean_c", "sd_c", "n_c", "event_c"), names(dat))
    if (length(candidates)) {
      bad <- list(); b <- 0L
      for (k in shared_keys) {
        ii <- which(key == k)
        for (nm in candidates) {
          z <- dat[[nm]][ii]
          z <- z[!is.na(z)]
          if (length(unique(z)) > 1L) {
            b <- b + 1L
            bad[[b]] <- data.frame(study=as.character(st[ii[1]]), control_id=as.character(ct[ii[1]]), field=nm, rows=paste(ii,collapse=","), stringsAsFactors=FALSE)
          }
        }
      }
      if (length(bad)) conflicts <- do.call(rbind, bad)
    }
  }
  summary <- data.frame(
    n_rows=nrow(dat), n_studies=length(unique(st)), n_control_groups=length(unique(key)),
    n_shared_control_groups=length(shared_keys), n_rows_in_shared_groups=sum(shared),
    max_multiplicity=if(length(mult)) max(mult) else 0L, n_conflicts=nrow(conflicts)
  )
  out <- list(groups=groups, summary=summary, conflicts=conflicts,
              recommendation=if(length(shared_keys)) "Construct a sampling covariance matrix before synthesis; do not treat these contrasts as independent." else "No reused control arm was detected from the supplied identifiers.",
              identifiers=list(study=.apm_name_quo(qs),control=.apm_name_quo(qc),treatment=.apm_name_quo(qt),effect=.apm_name_quo(qe)),
              data_hash=.apm_hash_data(dat))
  class(out) <- "apm_shared_control"
  out
}
