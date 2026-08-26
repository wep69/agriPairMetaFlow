#' Extract heterogeneity variance components from a multilevel model
#'
#' @param model `apm_multilevel` or compatible model.
#' @param level Confidence level requested for backend intervals when available.
#' @param proportion Report each component as a proportion of modeled heterogeneity.
#' @return An `apm_variance_components` object.
#' @export
#' @examples
#' es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' ml <- apm_multilevel(es,random=~1|study_id/experiment_id,V=apm_vcov(es,cluster=experiment_id))
#' apm_variance_components(ml)
#' apm_variance_components(ml,proportion=FALSE)
#' apm_variance_components(ml,level=.90)
apm_variance_components <- function(model, level = 0.95, proportion = TRUE) {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an agriPairMetaFlow model.")
  if(!is.numeric(level)||length(level)!=1L||level<=0||level>=1) .apm_abort("{.arg level} must lie between 0 and 1.")
  fit<-model$backend_fit; vals<-numeric(); labs<-character()
  add<-function(x,prefix) if(length(x)) { ok<-is.finite(x); vals<<-c(vals,x[ok]); labs<<-c(labs,paste0(prefix,seq_along(x))[ok]) }
  add(fit$sigma2 %||% numeric(),"sigma2_"); add(fit$tau2 %||% numeric(),"tau2_"); add(fit$gamma2 %||% numeric(),"gamma2_")
  if(!length(vals)) .apm_abort("No estimable heterogeneity variance components were found.")
  total<-sum(vals); tab<-data.frame(component=labs,variance=vals,sd=sqrt(pmax(vals,0)),proportion=if(proportion&&total>0) vals/total else NA_real_,percent=if(proportion&&total>0) 100*vals/total else NA_real_,stringsAsFactors=FALSE)
  ci<-tryCatch(stats::confint(fit,level=level*100),error=function(e) NULL)
  out<-list(table=tab,total_heterogeneity=total,level=level,proportion=proportion,backend_ci=ci,model_hash=model$data_hash,backend_version=model$backend_version)
  class(out)<-"apm_variance_components"; out
}
