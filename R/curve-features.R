#' Extract interpretable features from quantitative moderator curves
#'
#' Computes local slopes, within-support turning points, and practical-threshold
#' crossings from an `apm_curve`. These are descriptive meta-regression features;
#' they are not presented as causal agronomic optima unless the underlying
#' evidence and design justify that interpretation.
#'
#' @param curve An `apm_curve`.
#' @param features Any of `"slope"`, `"turning_point"`, and
#'   `"threshold_crossing"`.
#' @param threshold Threshold on the model/effect-size scale, required for
#'   threshold crossings.
#' @param interval Include uncertainty descriptors.
#' @param level Confidence level.
#' @return An `apm_curve_features` object.
#' @export
#' @examples
#' # Example 1: slopes and turning point of a quadratic rainfall curve.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irrig_quad <- apm_metareg_curve(irr_es,rainfall,"quadratic")
#' apm_curve_features(irrig_quad,c("slope","turning_point"))
#' # Example 2: N rate where the fitted effect crosses a 5% benefit threshold.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' maize_ns <- apm_metareg_curve(mz_es,N_rate,"ns",df=3)
#' apm_curve_features(maize_ns,"threshold_crossing",threshold=log(1.05))
#' # Example 3: local slope pattern for a natural-spline rainfall model.
#' irrig_ns <- apm_metareg_curve(irr_es,rainfall,"ns",df=3)
#' apm_curve_features(irrig_ns,"slope")
apm_curve_features <- function(curve, features = c("slope", "turning_point", "threshold_crossing"), threshold = NULL, interval = TRUE, level = 0.95) {
  if(!inherits(curve,"apm_curve")) .apm_abort("{.arg curve} must be an apm_curve.")
  allowed<-c("slope","turning_point","threshold_crossing");features<-unique(as.character(features));bad<-setdiff(features,allowed)
  if(length(bad)) .apm_abort("Unknown curve feature(s): {paste(bad,collapse=', ')}")
  if("threshold_crossing"%in%features&&(is.null(threshold)||!is.numeric(threshold)||length(threshold)!=1L||!is.finite(threshold))) .apm_abort("A finite model-scale {.arg threshold} is required for threshold_crossing.")
  if(!is.numeric(level)||level<=0||level>=1) .apm_abort("{.arg level} must lie between 0 and 1.")
  xn<-curve$curve_info$x_name; xr<-curve$curve_info$boundary; xg<-seq(xr[1],xr[2],length.out=max(200L,nrow(curve$prediction_grid)%||%100L))
  beta<-as.numeric(stats::coef(curve$backend_fit));Vb<-as.matrix(stats::vcov(curve$backend_fit));crit<-.apm_critical_value(curve,level)
  slope_tab<-NULL;turn_tab<-NULL;cross_tab<-NULL
  if(any(c("slope","turning_point")%in%features)) {
    vals<-lapply(xg,function(x0){D<-.apm_numeric_derivative_design(curve,x0);d<-as.numeric(D);if(length(beta)==length(d)+1L)d<-c(0,d);est<-sum(d*beta);se<-sqrt(drop(t(d)%*%Vb%*%d));c(est=est,se=se)})
    M<-do.call(rbind,vals);slope_tab<-data.frame(x=xg,slope=M[,"est"],se=M[,"se"],ci_lower=M[,"est"]-crit*M[,"se"],ci_upper=M[,"est"]+crit*M[,"se"])
    names(slope_tab)[1]<-xn
  }
  if("turning_point"%in%features) {
    roots<-.apm_root_intervals(xg,slope_tab$slope)
    if(length(roots)) {
      turn_tab<-do.call(rbind,lapply(roots,function(r){
        idx<-which.min(abs(xg-r)); inside<-slope_tab$ci_lower<=0&slope_tab$ci_upper>=0
        if(isTRUE(interval)&&inside[idx]) {
          lo<-idx;hi<-idx;while(lo>1L&&inside[lo-1L])lo<-lo-1L;while(hi<length(inside)&&inside[hi+1L])hi<-hi+1L
          lwr<-xg[lo];upr<-xg[hi]
        } else {lwr<-upr<-NA_real_}
        data.frame(location=r,lower=lwr,upper=upr,inside_support=r>=xr[1]&r<=xr[2],interval_method=if(isTRUE(interval))"region where slope CI includes zero" else "none")
      }))
    } else turn_tab<-data.frame(location=numeric(),lower=numeric(),upper=numeric(),inside_support=logical(),interval_method=character())
  }
  if("threshold_crossing"%in%features) {
    raw<-.apm_curve_predict_raw(curve,xg,level=level,prediction=FALSE)
    roots<-.apm_root_intervals(xg,raw$pred-threshold)
    lo_roots<-.apm_root_intervals(xg,raw$ci_lower-threshold);up_roots<-.apm_root_intervals(xg,raw$ci_upper-threshold)
    if(length(roots)) cross_tab<-do.call(rbind,lapply(roots,function(r){
      cand<-sort(c(lo_roots,up_roots));near<-if(length(cand))cand[order(abs(cand-r))][seq_len(min(2L,length(cand)))] else numeric()
      data.frame(location=r,lower=if(isTRUE(interval)&&length(near))min(near) else NA_real_,upper=if(isTRUE(interval)&&length(near))max(near) else NA_real_,threshold=threshold,inside_support=r>=xr[1]&r<=xr[2],interval_method=if(isTRUE(interval))"nearest CI-threshold crossings" else "none")
    })) else cross_tab<-data.frame(location=numeric(),lower=numeric(),upper=numeric(),threshold=numeric(),inside_support=logical(),interval_method=character())
  }
  out<-list(slope=if("slope"%in%features)slope_tab else NULL,turning_point=turn_tab,threshold_crossing=cross_tab,features=features,threshold=threshold,level=level,
    caution="Moderator-curve features are descriptive across-study associations and are not automatically causal dose recommendations.",model_hash=curve$source_data_hash%||%curve$data_hash)
  class(out)<-"apm_curve_features";out
}
