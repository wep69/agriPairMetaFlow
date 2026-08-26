# Rule-based interpretation ---------------------------------------------

.apm_fmt_effect <- function(x, measure, transform) {
  z <- .apm_transform_vector(x,measure,transform)
  if(transform=="percent" || (transform=="auto" && measure%in%.apm_log_measures)) {
    if(transform=="auto") return(sprintf("%.3f on the ratio scale",z))
    return(sprintf("%.1f%%",z))
  }
  sprintf("%.3f",z)
}

#' Explain agriPairMetaFlow results with deterministic scientific rules
#'
#' @param x A supported package result object.
#' @param audience Scientific, teaching, or extension-oriented wording.
#' @param transform Effect transformation.
#' @param include_assumptions Include model/design assumptions.
#' @param include_cautions Include interpretation cautions.
#' @return Character paragraphs with machine-readable interpretation tags.
#' @export
#' @examples
#' # Example 1: scientific interpretation of pooled yield response.
#' apm_explain(apm_fit(agri_effects_benchmark), audience="scientific", transform="percent")
#' # Example 2: teaching interpretation of heterogeneity.
#' apm_explain(apm_heterogeneity(apm_fit(agri_effects_benchmark)), audience="teaching")
#' # Example 3: extension-oriented wording without hiding uncertainty.
#' apm_explain(apm_fit(agri_effects_benchmark), audience="extension", transform="percent")
apm_explain <- function(x, audience = c("scientific", "teaching", "extension"),
                        transform = c("auto", "none", "exp", "percent"),
                        include_assumptions = TRUE, include_cautions = TRUE) {
  audience<-match.arg(audience);transform<-match.arg(transform);txt<-character();tags<-list(object_class=class(x)[1],audience=audience)
  if(inherits(x,"apm_model")) {
    fit<-x$backend_fit;cf<-as.numeric(stats::coef(fit)[1]);cv<-stats::vcov(fit);se<-sqrt(as.numeric(cv[1,1]));lo<-if(!is.null(fit$ci.lb))as.numeric(fit$ci.lb[1]) else cf-stats::qnorm(.975)*se;hi<-if(!is.null(fit$ci.ub))as.numeric(fit$ci.ub[1]) else cf+stats::qnorm(.975)*se
    pr<-tryCatch(stats::predict(fit),error=function(e)NULL);pil<-if(!is.null(pr)&&!is.null(pr$pi.lb))as.numeric(pr$pi.lb[1])else NA_real_;piu<-if(!is.null(pr)&&!is.null(pr$pi.ub))as.numeric(pr$pi.ub[1])else NA_real_
    esttxt<-.apm_fmt_effect(cf,x$measure,transform); lotxt<-.apm_fmt_effect(lo,x$measure,transform); hitxt<-.apm_fmt_effect(hi,x$measure,transform)
    if(audience=="scientific") txt<-c(txt,paste0("The pooled meta-analytic estimate is ",esttxt," with an approximate 95% interval from ",lotxt," to ",hitxt,". This interval describes uncertainty in the estimated mean effect, not the range expected in every future agronomic setting."))
    else if(audience=="teaching") txt<-c(txt,paste0("The model combines the study effects into an estimated mean of ",esttxt,". Its uncertainty interval runs from ",lotxt," to ",hitxt,"; this should not be interpreted as proof that all studies share one common response."))
    else txt<-c(txt,paste0("Across the available experiments, the average response is estimated at ",esttxt,". The plausible range for this average is ",lotxt," to ",hitxt,", so the result should be used with its uncertainty rather than as a guaranteed field response."))
    if(is.finite(pil)&&is.finite(piu)) txt<-c(txt,paste0("The 95% prediction interval for a new true study effect extends from ",.apm_fmt_effect(pil,x$measure,transform)," to ",.apm_fmt_effect(piu,x$measure,transform),". A wide interval indicates that response can differ materially among environments, years, crops, soils, or management contexts."))
    if(isTRUE(include_assumptions)) txt<-c(txt,"Interpretation assumes the effect-size calculation, experimental-unit definition, sampling variances, dependence structure, and fitted heterogeneity model are appropriate for the included evidence.")
    if(isTRUE(include_cautions)) txt<-c(txt,"Statistical significance alone is not treated as agronomic importance. Use prediction intervals, practical thresholds, dependence diagnostics, and sensitivity analyses where relevant.")
    tags$estimate<-cf;tags$ci<-c(lo,hi);tags$prediction_interval<-c(pil,piu);tags$measure<-x$measure
  } else if(inherits(x,"apm_heterogeneity")) {
    tab<-x$table; txt<-c(txt,"Heterogeneity describes real between-study dispersion beyond sampling error. I-squared is a relative descriptor and should be read together with tau-squared/tau and the prediction interval rather than used as a stand-alone quality score.")
    if(nrow(tab)) txt<-c(txt,paste0("The reported heterogeneity table contains ",nrow(tab)," summary row(s); inspect uncertainty around heterogeneity when available."))
    if(isTRUE(include_cautions)) txt<-c(txt,"High heterogeneity does not by itself invalidate a meta-analysis, and low heterogeneity does not establish interchangeability of agronomic conditions.")
  } else if(inherits(x,"apm_inference_comparison")) {
    txt<-c(txt,"The comparison places conventional, cluster-robust, and/or bootstrap inference side by side. Differences among intervals or p-values are sensitivity information about inferential assumptions; the package does not select the most favorable method.")
  } else if(inherits(x,"apm_bias")) {
    txt<-c(txt,"The small-study-effect and publication-bias analyses use different assumptions and answer different sensitivity questions. Funnel asymmetry, Egger tests, trim-and-fill, selection models, and S-values are not interchangeable evidence of one mechanism.")
    if(isTRUE(include_cautions)) txt<-c(txt,x$caution)
  } else if(inherits(x,"apm_bayes")) {
    txt<-c(txt,"The Bayesian result should be interpreted only after checking backend-appropriate diagnostics and prior sensitivity. Posterior uncertainty and new-study prediction are distinct quantities.")
  } else .apm_abort("apm_explain() does not yet support objects of class {.cls {class(x)[1]}}.")
  structure(txt,tags=tags,class=c("apm_explanation","character"))
}
