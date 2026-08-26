#' Fit a multilevel meta-analytic model
#'
#' @param effects Effect-size data containing `yi` and `vi`.
#' @param random Random-effects formula for study/experiment/effect hierarchy.
#' @param V Sampling variance-covariance matrix; defaults to diagonal `vi`.
#' @param mods Moderator formula.
#' @param struct Covariance structure passed to `metafor::rma.mv()`.
#' @param method Variance-component estimator.
#' @param test Test distribution (`"z"` or `"t"`).
#' @param dfs Degrees-of-freedom rule for t tests.
#' @param ... Additional arguments passed to `metafor::rma.mv()`.
#' @return An `apm_multilevel` object inheriting from `apm_model`.
#' @export
#' @examples
#' es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' V <- apm_vcov(es,cluster=experiment_id)
#' apm_multilevel(es,random=~1|study_id/experiment_id,V=V)
#' es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_multilevel(es2,random=~1|study_id/outcome,V=apm_vcov(es2,cluster=study_id,type=outcome,rho=.5,shared_control=FALSE))
#' apm_multilevel(es,random=~1|study_id,V=V,test="z")
apm_multilevel <- function(effects, random = ~ 1 | study_id/effect_id, V = NULL, mods = ~ 1, struct = "CS", method = "REML", test = "t", dfs = c("contain", "residual"), ...) {
  .apm_require("metafor","multilevel meta-analysis"); dfs<-match.arg(dfs); dat<-.apm_df(effects)
  if(!all(c("yi","vi")%in%names(dat))) .apm_abort("{.arg effects} must contain {.field yi} and {.field vi}.")
  if(!inherits(random,"formula")||!inherits(mods,"formula")) .apm_abort("{.arg random} and {.arg mods} must be formulas.")
  vars<-unique(c(all.vars(random),all.vars(mods))); miss<-setdiff(vars,names(dat)); if(length(miss)) .apm_abort("Model variables not found: {paste(miss,collapse=', ')}")
  if(is.null(V)) V<-diag(dat$vi) else V<-as.matrix(V)
  if(!all(dim(V)==c(nrow(dat),nrow(dat)))) .apm_abort("{.arg V} must be square with one row and column per effect.")
  if(max(abs(V-t(V)),na.rm=TRUE)>1e-10) .apm_abort("{.arg V} must be symmetric.")
  fit<-metafor::rma.mv(yi=dat$yi,V=V,mods=mods,random=random,struct=struct,data=dat,method=method,test=test,dfs=dfs,...)
  out<-list(backend_fit=fit,coefficients=stats::coef(fit),vcov=stats::vcov(fit),heterogeneity=list(sigma2=fit$sigma2 %||% numeric(),tau2=fit$tau2 %||% numeric(),rho=fit$rho %||% numeric(),gamma2=fit$gamma2 %||% numeric(),phi=fit$phi %||% numeric(),QE=fit$QE %||% NA_real_,QEp=fit$QEp %||% NA_real_),model_matrix=fit$X %||% NULL,data=dat,V=V,omitted=integer(),settings=list(random=random,mods=mods,struct=struct,method=method,test=test,dfs=dfs,level=.95,backend="metafor"),measure=attr(effects,"measure") %||% "GEN",data_hash=.apm_hash_data(dat),backend_version=.apm_backend_version("metafor"))
  class(out)<-c("apm_multilevel","apm_model"); out
}
