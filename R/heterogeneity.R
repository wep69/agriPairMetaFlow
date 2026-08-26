#' Summarize heterogeneity and its uncertainty
#'
#' @param model An `apm_model`.
#' @param ci Calculate heterogeneity intervals when supported.
#' @param level Confidence level.
#' @param method_ci `"profile"`, `"QP"`, or automatic routing.
#' @return An `apm_heterogeneity` object.
#' @export
#' @examples
#' # Example 1: heterogeneity of benchmark lnRR effects.
#' apm_heterogeneity(apm_fit(agri_effects_benchmark))
#' # Example 2: heterogeneity of CVR effects.
#' ev <- apm_effect_size(covercrop_variability,"CVR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_heterogeneity(apm_fit(ev))
#' # Example 3: heterogeneity after a rainfall moderator.
#' apm_heterogeneity(apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed"))
apm_heterogeneity <- function(model, ci = TRUE, level = 0.95, method_ci = c("auto", "profile", "QP")) {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an apm_model."); method_ci<-match.arg(method_ci); fit<-model$backend_fit
  tab<-data.frame(k=fit$k %||% nrow(model$data),Q=fit$QE %||% NA_real_,Q_df=fit$k-fit$p,Q_p=fit$QEp %||% NA_real_,tau2=fit$tau2 %||% NA_real_,tau=sqrt(pmax(fit$tau2 %||% NA_real_,0)),I2=fit$I2 %||% NA_real_,H2=fit$H2 %||% NA_real_)
  ciobj<-NULL
  if(ci && inherits(fit,"rma.uni") && !identical(model$settings$model,"common")) {
    ci_method<-if(method_ci=="auto") "QP" else if(method_ci=="profile") "PL" else method_ci
    ciobj<-tryCatch(stats::confint(fit,level=level*100,type=ci_method),error=function(e){.apm_warn("Heterogeneity interval calculation failed: {conditionMessage(e)}");NULL})
  }
  out<-list(table=tab,intervals=ciobj,level=level,method_ci=method_ci,model_hash=model$data_hash); class(out)<-"apm_heterogeneity"; out
}
