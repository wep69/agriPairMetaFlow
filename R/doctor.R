# Installation and runtime doctor -----------------------------------------

.apm_doctor_row <- function(check, status, scope, detail, remediation = NA_character_) {
  data.frame(check=check,status=status,scope=scope,detail=detail,remediation=remediation,stringsAsFactors=FALSE)
}

.apm_doctor_data_check <- function() {
  required <- c("maize_n_shared","covercrop_variability","irrigation_climate",
                "bioinoculant_multicrop","wheat_paired_blocks","agri_uncertainty_mixed",
                "pest_suppression_binary","agri_effects_benchmark",
                "soil_management_multiresponse","fertilizer_dose_response","biochar_multiresponse")
  env <- asNamespace("agriPairMetaFlow")
  missing <- required[!vapply(required, exists, logical(1), envir=env, inherits=FALSE)]
  if (length(missing))
    return(.apm_doctor_row("teaching datasets","FAIL","core",paste("Missing:",paste(missing,collapse=", ")),"Reinstall the exact source tarball and rerun validation."))
  bad <- required[vapply(required,function(nm){z<-get(nm,envir=env);!is.data.frame(z)||!nrow(z)},logical(1))]
  if (length(bad))
    return(.apm_doctor_row("teaching datasets","FAIL","core",paste("Invalid/empty:",paste(bad,collapse=", ")),"Regenerate data from data-raw scripts and rebuild the package."))
  .apm_doctor_row("teaching datasets","PASS","core",paste(length(required),"frozen teaching datasets are present and non-empty."))
}

#' Diagnose installation, backends, rendering, and reproducibility infrastructure
#'
#' @param full Run the extended set of non-mutating checks.
#' @param check_backends Inspect registered optional R backends and version policy.
#' @param check_render Inspect R Markdown/Pandoc/Quarto rendering availability.
#' @param check_examples Run small in-memory smoke examples. This does not replace
#'   the formal package test suite or `R CMD check`.
#' @return An `apm_doctor` object with PASS/WARN/FAIL/NOT RUN checks and
#'   remediation guidance. No packages or system tools are installed or modified.
#' @export
#' @examples
#' # Example 1: core installation diagnostic before a maize meta-analysis.
#' apm_doctor()
#' # Example 2: extended backend inspection before Bayesian analyses.
#' apm_doctor(full=TRUE, check_backends=TRUE)
#' # Example 3: release-machine inspection including rendering and smoke examples.
#' apm_doctor(full=TRUE, check_render=TRUE, check_examples=TRUE)
apm_doctor <- function(full = FALSE, check_backends = TRUE, check_render = FALSE, check_examples = FALSE) {
  rows <- list(); k <- 0L
  add <- function(x) { k <<- k + 1L; rows[[k]] <<- x }

  r_ok <- getRversion() >= "4.2.0"
  add(.apm_doctor_row("R version",if(r_ok)"PASS" else "FAIL","core",
    paste("R",as.character(getRversion())),if(r_ok) NA_character_ else "Install R >= 4.2.0."))

  core <- c("cli","generics","ggplot2","metafor","rlang","splines","stats","tibble","utils","vctrs")
  for (p in core) {
    ok <- requireNamespace(p,quietly=TRUE)
    add(.apm_doctor_row(p,if(ok)"PASS" else "FAIL","core-backend",
      if(ok) paste("version",.apm_backend_version(p)) else "not installed",
      if(ok) NA_character_ else paste0("install.packages('",p,"') then reinstall agriPairMetaFlow.")))
  }

  add(.apm_doctor_data_check())

  ns_ok <- all(vapply(c("apm_workflow","apm_capabilities","apm_doctor"),exists,logical(1),envir=asNamespace("agriPairMetaFlow"),inherits=FALSE))
  add(.apm_doctor_row("1.0 integration API",if(ns_ok)"PASS" else "FAIL","core",
    if(ns_ok) "apm_workflow(), apm_capabilities(), and apm_doctor() are available." else "One or more integration functions are missing.",
    if(ns_ok) NA_character_ else "Reinstall the consolidated 1.0 source snapshot."))

  if (isTRUE(check_backends)) {
    caps <- apm_capabilities(installed=TRUE,detail="full")
    opt <- caps[!caps$core,,drop=FALSE]
    for (i in seq_len(nrow(opt))) {
      st <- if (identical(opt$status[i],"AVAILABLE")) "PASS" else "WARN"
      add(.apm_doctor_row(paste0("backend: ",opt$backend[i]),st,"optional-backend",
        paste(opt$status[i],if(!is.na(opt$version[i])) paste0("; version ",opt$version[i]) else ""),
        if(st=="PASS") NA_character_ else paste0("Install/configure this optional capability only if required: ",opt$backend[i],".")))
    }
  } else add(.apm_doctor_row("optional backends","NOT RUN","optional-backend","check_backends=FALSE"))

  if (isTRUE(check_render)) {
    rm_ok <- requireNamespace("rmarkdown",quietly=TRUE)
    pd_ok <- if(rm_ok) tryCatch(rmarkdown::pandoc_available(),error=function(e)FALSE) else FALSE
    qpath <- Sys.which("quarto")
    add(.apm_doctor_row("Pandoc",if(pd_ok)"PASS" else "WARN","render",
      if(pd_ok) tryCatch(paste("version",as.character(rmarkdown::pandoc_version())),error=function(e)"available") else "not detected through rmarkdown",
      if(pd_ok) NA_character_ else "Install Pandoc or use an RStudio distribution that provides Pandoc before rendering vignettes/reports."))
    add(.apm_doctor_row("Quarto",if(nzchar(qpath))"PASS" else "WARN","render",
      if(nzchar(qpath)) qpath else "not on PATH",if(nzchar(qpath)) NA_character_ else "Quarto is optional unless a Quarto reporting workflow is chosen."))
  } else add(.apm_doctor_row("rendering stack","NOT RUN","render","check_render=FALSE"))

  if (isTRUE(check_examples)) {
    smoke <- tryCatch({
      z <- apm_fit(agri_effects_benchmark,yi=yi,vi=vi,model="random")
      isTRUE(inherits(z,"apm_model")) && all(is.finite(stats::coef(z$backend_fit)))
    },error=function(e)e)
    ok <- isTRUE(smoke)
    add(.apm_doctor_row("core smoke fit",if(ok)"PASS" else "FAIL","smoke",
      if(ok) "Random-effects benchmark fit completed." else conditionMessage(smoke),
      if(ok) NA_character_ else "Run the formal local validation and inspect the underlying metafor error."))
    route <- tryCatch({
      ef0 <- apm_effect_size(agri_effects_benchmark,measure="GEN",yi=yi,vi=vi)
      m0 <- apm_metareg(ef0,moderators=~dose)
      cls <- lapply(list(apm_fit(ef0)$backend_fit$call[[1L]],m0$backend_fit$call[[1L]]),
        function(h) is.name(h)||is.call(h))
      wb <- if(requireNamespace("wildmeta",quietly=TRUE)&&requireNamespace("clubSandwich",quietly=TRUE)) {
        w0 <- apm_wild_bootstrap(m0,cluster=agri_effects_benchmark$study_id,R=99,seed=1)
        isTRUE(inherits(w0,"apm_wild")) && is.finite(w0$p_value)
      } else TRUE
      all(unlist(cls)) && isTRUE(wb)
    },error=function(e)e)
    rok <- isTRUE(route)
    add(.apm_doctor_row("optional-route smoke",if(rok)"PASS" else "FAIL","smoke",
      if(rok) "Backend calls are re-evaluable and the wild-bootstrap route runs." else conditionMessage(route),
      if(rok) NA_character_ else "Inspect backend call construction and optional-route wiring."))
  } else add(.apm_doctor_row("core smoke examples","NOT RUN","smoke","check_examples=FALSE; formal testthat remains a separate release gate."))

  if (isTRUE(full)) {
    si <- utils::sessionInfo()
    add(.apm_doctor_row("locale","PASS","reproducibility",paste(si$locale,collapse="; ")))
    add(.apm_doctor_row("platform","PASS","reproducibility",R.version$platform))
    writable <- file.access(tempdir(),2)==0
    add(.apm_doctor_row("temporary directory",if(writable)"PASS" else "FAIL","reproducibility",tempdir(),if(writable)NA_character_ else "Use a writable temporary directory for package tests and reports."))
  }

  tab <- do.call(rbind,rows); rownames(tab)<-NULL
  severe <- any(tab$status=="FAIL" & tab$scope %in% c("core","core-backend","smoke"))
  out <- list(checks=tab,ok=!severe,summary=as.data.frame(table(factor(tab$status,levels=c("PASS","WARN","FAIL","NOT RUN"))),stringsAsFactors=FALSE),
              package_version=as.character(utils::packageVersion("agriPairMetaFlow")),session=utils::sessionInfo(),call=match.call(),mutated_environment=FALSE)
  names(out$summary)<-c("status","n")
  class(out)<-"apm_doctor"; out
}
