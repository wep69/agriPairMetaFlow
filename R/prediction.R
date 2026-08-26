#' Obtain confidence and prediction intervals
#'
#' @param model An `apm_model`.
#' @param newdata Optional moderator values.
#' @param level Confidence level.
#' @param method Prediction-interval method. Version 0.1.0 validates `"model"`; alternative labels are reserved for optional `pimeta` routing.
#' @param transform Output transformation.
#' @param threshold Optional practical threshold on transformed output scale.
#' @param ... Reserved for backend-specific extensions.
#' @return An `apm_prediction` object.
#' @export
#' @examples
#' # Example 1: pooled prediction expressed as percent change.
#' apm_prediction(apm_fit(agri_effects_benchmark), transform="percent")
#' # Example 2: rainfall-specific predictions.
#' fm <- apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed")
#' apm_prediction(fm, newdata=data.frame(rainfall=c(600,900,1200)))
#' # Example 3: ratio-scale prediction.
#' apm_prediction(apm_fit(agri_effects_benchmark), transform="exp")
apm_prediction <- function(model, newdata = NULL, level = 0.95, method = c("model", "HTS", "HK", "KR", "NNF"), transform = c("auto", "none", "exp", "percent"), threshold = NULL, ...) {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an apm_model."); method<-match.arg(method); transform<-match.arg(transform)
  if(method!="model") .apm_abort("Prediction method {.val {method}} is reserved for the optional pimeta adapter and is not yet runtime-enabled in this 0.2.0 development snapshot; use method='model'.")
  fit<-model$backend_fit; newmods<-NULL
  if(!is.null(newdata)) {
    mods<-model$settings$mods; if(identical(deparse(mods),"~1")) .apm_abort("{.arg newdata} is only meaningful for a model with moderators.")
    mm<-stats::model.matrix(mods,newdata); if("(Intercept)"%in%colnames(mm)) mm<-mm[,setdiff(colnames(mm),"(Intercept)"),drop=FALSE]; newmods<-mm
  }
  pr<-if(is.null(newmods)) stats::predict(fit,level=level*100) else stats::predict(fit,newmods=newmods,level=level*100)
  vals<-data.frame(pred=as.numeric(pr$pred),se=as.numeric(pr$se),ci_lower=as.numeric(pr$ci.lb),ci_upper=as.numeric(pr$ci.ub),pi_lower=as.numeric(pr$pi.lb %||% NA),pi_upper=as.numeric(pr$pi.ub %||% NA))
  raw<-vals; for(nm in c("pred","ci_lower","ci_upper","pi_lower","pi_upper")) vals[[nm]]<-.apm_transform_vector(vals[[nm]],model$measure,transform)
  prob<-NULL
  if(!is.null(threshold)) { thm<-.apm_threshold_to_model(threshold,model$measure,if(transform=="percent")"percent" else if(transform=="exp")"ratio" else "model"); psd<-sqrt((raw$se)^2 + (fit$tau2 %||% 0)); prob<-stats::pnorm((raw$pred-thm)/psd) }
  out<-list(table=vals,raw=raw,newdata=newdata,method=method,transform=transform,threshold=threshold,probability_greater=prob,measure=model$measure,model_hash=model$data_hash); class(out)<-"apm_prediction"; out
}
