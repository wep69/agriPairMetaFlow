#' Compute treatment-control effect sizes and sampling variances
#'
#' @param data Study summaries or an `apm_uncertainty` object.
#' @param measure Effect measure: lnRR, MD, SMD, VR, CVR, RR, OR, RD, ZCOR, or GEN.
#' @param design Independent or genuinely paired/matched design.
#' @param m_t,sd_t,n_t,m_c,sd_c,n_c Continuous treatment/control summaries.
#' @param event_t,event_c Binary event counts; totals use `n_t` and `n_c`.
#' @param r Paired correlation or correlation coefficient for ZCOR.
#' @param yi,vi Precomputed generic effects.
#' @param correct Apply supported small-sample bias correction.
#' @param vtype Sampling-variance approximation passed to `metafor::escalc()`.
#' @param paired_standardization `"change"` maps SMD to SMCC; `"raw"` maps to SMCR.
#' @param append Retain source columns.
#' @return An `apm_effects` data-frame-like object with `yi`, `vi`, and `sei`.
#' @export
#' @examples
#' # Example 1: log response ratio for maize nitrogen treatments.
#' apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
#'   m_c=mean_c, sd_c=sd_c, n_c=n_c)
#' # Example 2: coefficient-of-variation ratio for cover crops.
#' apm_effect_size(covercrop_variability, "CVR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
#'   m_c=mean_c, sd_c=sd_c, n_c=n_c)
#' # Example 3: paired log response ratio for matched wheat blocks.
#' apm_effect_size(wheat_paired_blocks, "lnRR", design="paired", m_t=mean_t,
#'   sd_t=sd_t, n_t=n_pairs, m_c=mean_c, sd_c=sd_c, n_c=n_pairs, r=r_tc)
apm_effect_size <- function(data, measure = c("lnRR", "MD", "SMD", "VR", "CVR", "RR", "OR", "RD", "ZCOR", "GEN"), design = c("auto", "independent", "paired"), m_t = NULL, sd_t = NULL, n_t = NULL, m_c = NULL, sd_c = NULL, n_c = NULL, event_t = NULL, event_c = NULL, r = NULL, yi = NULL, vi = NULL, correct = TRUE, vtype = "LS", paired_standardization = c("change", "raw"), append = TRUE) {
  .apm_require("metafor","effect-size calculation")
  measure<-match.arg(measure); design<-match.arg(design); paired_standardization<-match.arg(paired_standardization); dat<-.apm_df(data)
  qs<-list(m_t=rlang::enquo(m_t),sd_t=rlang::enquo(sd_t),n_t=rlang::enquo(n_t),m_c=rlang::enquo(m_c),sd_c=rlang::enquo(sd_c),n_c=rlang::enquo(n_c),event_t=rlang::enquo(event_t),event_c=rlang::enquo(event_c),r=rlang::enquo(r),yi=rlang::enquo(yi),vi=rlang::enquo(vi))
  x<-lapply(names(qs),function(nm).apm_pull_quo(dat,qs[[nm]],nm)); names(x)<-names(qs)
  if (design=="auto") design <- if (!is.null(x$r) && measure %in% c("lnRR","MD","SMD","VR","CVR")) "paired" else "independent"
  if (measure=="GEN") {
    if (is.null(x$yi) && "yi" %in% names(dat)) x$yi<-dat$yi; if(is.null(x$vi)&&"vi"%in%names(dat)) x$vi<-dat$vi
    if (is.null(x$yi)||is.null(x$vi)) .apm_abort("GEN requires {.arg yi} and {.arg vi}.")
    es <- data.frame(yi=as.numeric(x$yi),vi=as.numeric(x$vi)); backend_measure<-"GEN"
  } else if (measure=="ZCOR") {
    if (design=="paired") .apm_abort("ZCOR is not routed through the paired treatment-control registry in version 0.1.0.")
    if (is.null(x$r)||is.null(x$n_t)) .apm_abort("ZCOR requires {.arg r} and {.arg n_t}.")
    es <- metafor::escalc(measure="ZCOR", ri=x$r, ni=x$n_t); backend_measure<-"ZCOR"
  } else if (measure %in% c("RR","OR","RD")) {
    if (design=="paired") .apm_abort("Paired binary measures require paired 2x2 cell counts, which are scheduled for the binary extension; use independent binary summaries in 0.1.0.")
    if (any(vapply(x[c("event_t","event_c","n_t","n_c")],is.null,logical(1)))) .apm_abort("Binary effects require event_t, event_c, n_t, and n_c.")
    if (any(x$event_t<0|x$event_t>x$n_t|x$event_c<0|x$event_c>x$n_c,na.rm=TRUE)) .apm_abort("Event counts must lie between zero and their arm totals.")
    es <- metafor::escalc(measure=measure, ai=x$event_t, bi=x$n_t-x$event_t, ci=x$event_c, di=x$n_c-x$event_c); backend_measure<-measure
  } else {
    req<-c("m_t","sd_t","n_t","m_c","sd_c"); if(any(vapply(x[req],is.null,logical(1)))) .apm_abort("Continuous effect {.val {measure}} requires treatment/control means, SDs, and treatment n; independent designs also require control n.")
    if (design=="independent" && is.null(x$n_c)) .apm_abort("Independent designs require {.arg n_c}.")
    if (any(c(x$n_t,x$n_c %||% numeric()) <= 1,na.rm=TRUE)) .apm_abort("Continuous sampling variances require arm sample sizes greater than 1.")
    if (measure %in% c("lnRR","CVR") && any(c(x$m_t,x$m_c)<=0,na.rm=TRUE)) .apm_abort("lnRR/CVR require strictly positive means.")
    if (design=="paired") {
      if (is.null(x$r)) .apm_abort("Paired continuous effects require the treatment-control correlation {.arg r}.")
      if (any(x$r < -1 | x$r > 1,na.rm=TRUE)) .apm_abort("Paired correlations must lie in [-1, 1].")
      if (!is.null(x$n_c) && any(x$n_t != x$n_c,na.rm=TRUE)) .apm_abort("Paired summaries require the same number of pairs in treatment and control.")
      backend_measure <- .apm_effect_registry[[measure]]$paired
      if (measure=="SMD" && paired_standardization=="raw") backend_measure <- "SMCR"
      es <- metafor::escalc(measure=backend_measure,m1i=x$m_t,sd1i=x$sd_t,m2i=x$m_c,sd2i=x$sd_c,ri=x$r,ni=x$n_t,correct=correct,vtype=vtype)
    } else {
      backend_measure <- .apm_effect_registry[[measure]]$independent
      es <- metafor::escalc(measure=backend_measure,m1i=x$m_t,sd1i=x$sd_t,n1i=x$n_t,m2i=x$m_c,sd2i=x$sd_c,n2i=x$n_c,correct=correct,vtype=vtype)
    }
  }
  core <- data.frame(yi=as.numeric(es$yi),vi=as.numeric(es$vi),sei=sqrt(as.numeric(es$vi)))
  if (append) { dup <- intersect(names(dat), names(core)); if (length(dup)) dat <- dat[, !names(dat) %in% dup, drop = FALSE] }
  ans <- tibble::as_tibble(if (append) cbind(dat,core) else core)
  class(ans)<-c("apm_effects",class(ans)); attr(ans,"measure")<-measure; attr(ans,"backend_measure")<-backend_measure; attr(ans,"design")<-design; attr(ans,"provenance")<-list(backend="metafor",backend_version=.apm_backend_version("metafor"),correct=correct,vtype=vtype,data_hash=.apm_hash_data(dat))
  ans
}
