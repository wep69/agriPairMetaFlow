#' Evaluate a user-defined agronomic relevance threshold
#'
#' @param model An `apm_model`.
#' @param threshold User-defined threshold.
#' @param scale Threshold scale: model, ratio, percent, or absolute.
#' @param direction Scientific direction of interest.
#' @param prediction Include the prediction interval when judging transferability.
#' @return An `apm_threshold` object.
#' @export
#' @examples
#' # Example 1: at least five percent improvement.
#' apm_threshold(apm_fit(agri_effects_benchmark), threshold=5, scale="percent")
#' # Example 2: ratio of means at least 1.10.
#' apm_threshold(apm_fit(agri_effects_benchmark), threshold=1.10, scale="ratio", direction="greater")
#' # Example 3: a model-scale threshold in the adverse direction.
#' apm_threshold(apm_fit(agri_effects_benchmark), threshold=0, scale="model", direction="less")
apm_threshold <- function(model, threshold, scale = c("model", "ratio", "percent", "absolute"), direction = c("greater", "less", "two-sided"), prediction = TRUE) {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an apm_model."); scale<-match.arg(scale); direction<-match.arg(direction); if(length(threshold)!=1||!is.finite(threshold)) .apm_abort("{.arg threshold} must be one finite number.")
  thm<-.apm_threshold_to_model(threshold,model$measure,scale); pr<-stats::predict(model$backend_fit); est<-as.numeric(pr$pred); ci<-c(as.numeric(pr$ci.lb),as.numeric(pr$ci.ub)); pi<-c(as.numeric(pr$pi.lb %||% NA),as.numeric(pr$pi.ub %||% NA)); psd<-sqrt((as.numeric(pr$se))^2 + (model$backend_fit$tau2 %||% 0))
  prob_g<-stats::pnorm((est-thm)/psd)
  probability<-switch(direction,greater=prob_g,less=1-prob_g,`two-sided`={ a<-abs(thm); stats::pnorm((-a-est)/psd) + (1-stats::pnorm((a-est)/psd)) })
  relation<-function(int){ if(anyNA(int)) return(NA_character_); if(direction=="greater") if(int[1]>thm)"entirely beyond threshold" else if(int[2]<thm)"entirely below threshold" else "crosses threshold" else if(direction=="less") if(int[2]<thm)"entirely beyond threshold" else if(int[1]>thm)"entirely above threshold" else "crosses threshold" else if(thm>=int[1]&&thm<=int[2])"contains threshold" else "does not contain threshold" }
  out<-list(threshold=threshold,threshold_model=thm,scale=scale,direction=direction,estimate_model=est,ci_model=ci,pi_model=if(prediction)pi else c(NA,NA),ci_relation=relation(ci),pi_relation=if(prediction)relation(pi) else NA_character_,probability=probability,measure=model$measure); class(out)<-"apm_threshold"; out
}
