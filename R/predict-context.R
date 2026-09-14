#' Predict treatment effects for explicit agronomic contexts
#'
#' Generates model-based predictions for combinations of quantitative and
#' qualitative agronomic moderators while labeling interpolation versus
#' extrapolation and optionally evaluating a practical-effect threshold.
#'
#' @param model An `apm_metareg` or `apm_curve` object.
#' @param newdata Data frame containing moderator contexts.
#' @param level Confidence level.
#' @param prediction Include a prediction interval where supported by the
#'   fitted backend.
#' @param threshold Optional practical threshold on the displayed output scale.
#'   The exceedance probability uses a normal approximation on the prediction
#'   distribution (predicted mean, standard error, and heterogeneity variance).
#' @param transform Output transformation.
#' @return An `apm_prediction` retaining context columns and support flags.
#' @export
#' @examples
#' # Example 1: expected irrigation effect at 800 mm rainfall and 24 C.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irr_m <- apm_metareg(irr_es,~rainfall+mean_temp)
#' apm_predict_context(irr_m,data.frame(rainfall=800,mean_temp=24))
#' # Example 2: crop/site context for an inoculant.
#' bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' bio_m <- apm_metareg(bio_es,~crop+site)
#' apm_predict_context(bio_m,data.frame(crop="maize",site="Areia"),transform="percent")
#' # Example 3: practical 5% threshold along an N-rate curve.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_curve <- apm_metareg_curve(mz_es,N_rate,"quadratic")
#' apm_predict_context(mz_curve,data.frame(N_rate=c(60,120)),threshold=5,transform="percent")
apm_predict_context <- function(model, newdata, level = 0.95, prediction = TRUE, threshold = NULL, transform = c("auto", "none", "exp", "percent")) {
  if(!inherits(model,"apm_metareg")) .apm_abort("{.arg model} must inherit from apm_metareg.")
  transform<-match.arg(transform); if(!is.data.frame(newdata))newdata<-as.data.frame(newdata)
  if(!nrow(newdata)) .apm_abort("{.arg newdata} must contain at least one context row.")
  if(!is.numeric(level)||level<=0||level>=1) .apm_abort("{.arg level} must lie between 0 and 1.")

  if(inherits(model,"apm_curve")) {
    xn<-model$curve_info$x_name
    if(!xn%in%names(newdata)) .apm_abort("Curve predictions require moderator column {.field {xn}} in {.arg newdata}.")
    x<-newdata[[xn]]; .apm_check_numeric(x,xn)
    X_pred<-.apm_curve_design(model,x)
    raw<-.apm_predict_meta_matrix(model,X_pred,level=level,prediction=prediction)
    sup<-model$curve_info$boundary; flags<-ifelse(x<sup[1]|x>sup[2],"extrapolation","interpolation")
  } else {
    mx<-.apm_model_matrix_meta(model,newdata)
    X_pred<-mx$matrix
    raw<-.apm_predict_meta_matrix(model,X_pred,level=level,prediction=prediction)
    flags<-.apm_support_flags(model,newdata)$flag
  }
  shown<-.apm_transform_prediction(raw,model$measure,transform)
  tab<-cbind(newdata,support=flags,shown)
  prob<-rep(NA_real_,nrow(tab)); relation<-rep(NA_character_,nrow(tab)); probability_basis<-"not requested"
  if(!is.null(threshold)) {
    if(length(threshold)!=1L||!is.numeric(threshold)||!is.finite(threshold)) .apm_abort("{.arg threshold} must be one finite number.")
    actual_transform<-if(transform=="auto")if(model$measure%in%.apm_log_measures)"exp" else "none" else transform
    scale<-if(actual_transform=="percent")"percent" else if(actual_transform=="exp")"ratio" else "model"
    thm<-.apm_threshold_to_model(threshold,model$measure,scale)
    fit<-model$backend_fit; hv<-c(fit$tau2%||%numeric(),fit$sigma2%||%numeric(),fit$gamma2%||%numeric());hv<-hv[is.finite(hv)&hv>=0]
    if(!isTRUE(prediction)) {
      prob[]<-NA_real_
      probability_basis<-"not defined: mean-effect confidence uncertainty is not a predictive probability"
    } else if(length(hv)<=1L) {
      tau2<-if(length(hv)) hv else 0
      sd_pred<-sqrt(raw$se^2+tau2)
      ok<-is.finite(raw$pred)&is.finite(sd_pred)&sd_pred>0
      z<-(raw$pred-thm)/sd_pred
      prob[ok]<-stats::pnorm(z[ok])
      probability_basis<-"normal approximation on the prediction distribution"
    } else {
      prob[]<-NA_real_
      probability_basis<-"unavailable: multiple heterogeneity components require an explicit prediction-level variance structure"
    }
    relation<-ifelse(shown$ci_lower>threshold,"above",ifelse(shown$ci_upper<threshold,"below","overlaps"))
  }
  tab$threshold_relation<-relation;tab$probability_above_threshold<-prob;tab$probability_basis<-probability_basis
  out<-list(table=tab,raw=raw,newdata=newdata,method="context",transform=transform,threshold=threshold,
    probability_greater=prob,probability_above_threshold=prob,probability_basis=probability_basis,measure=model$measure,model_hash=model$source_data_hash%||%model$data_hash,
    extrapolated=which(flags=="extrapolation"))
  class(out)<-"apm_prediction";out
}
