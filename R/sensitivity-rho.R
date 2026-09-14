#' Sensitivity analysis to unknown within-study correlation
#'
#' @param effects Effect-size data.
#' @param rho Grid of plausible correlations.
#' @param build_vcov Function or list describing how to build V. A list with `pair_id` uses `apm_pair_vcov()`; otherwise `apm_vcov()`.
#' @param fit Optional function used to fit each V; defaults to `apm_fit()`.
#' @param metric Quantity emphasized in print/plot output.
#' @param ... Additional arguments passed to the fitting function.
#' @return An `apm_sensitivity` object containing every attempted rho value.
#' @export
#' @examples
#' es <- apm_effect_size(wheat_paired_blocks,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
#' apm_rho_sensitivity(es,rho=c(.2,.5,.8),build_vcov=list(pair_id="study_id"))
#' es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_rho_sensitivity(es2,rho=c(.25,.5,.75),build_vcov=list(cluster="study_id",type="outcome"))
#' apm_rho_sensitivity(es,rho=seq(.1,.9,.2),build_vcov=list(pair_id="study_id"),metric="se")
apm_rho_sensitivity <- function(effects, rho = seq(0, 0.9, 0.1), build_vcov, fit = NULL, metric = c("estimate", "se", "ci", "pi", "tau2"), ...) {
  metric<-match.arg(metric); dat<-.apm_df(effects)
  if(!is.numeric(rho)||!length(rho)||any(!is.finite(rho))||any(rho<=-1|rho>=1)) .apm_abort("All {.arg rho} values must lie strictly between -1 and 1.")
  if(missing(build_vcov)||is.null(build_vcov)) .apm_abort("{.arg build_vcov} is required.")
  fit_fun <- fit %||% function(effects,V,...) apm_fit(effects,V=V,...)
  build_one <- function(rr) {
    if(is.function(build_vcov)) return(build_vcov(effects,rr))
    if(!is.list(build_vcov)) .apm_abort("{.arg build_vcov} must be a function or list.")
    a<-build_vcov
    if(!is.null(a$pair_id)) {
      pid<-if(is.character(a$pair_id)&&length(a$pair_id)==1L) dat[[a$pair_id]] else a$pair_id
      if(is.null(pid)) .apm_abort("Unknown pair_id column in {.arg build_vcov}.")
      structure<-a$structure %||% "compound"
      return(apm_pair_vcov(effects,pair_id=pid,r=rr,structure=structure,user_V=a$user_V %||% NULL))
    }
    cl<-if(is.character(a$cluster)&&length(a$cluster)==1L) dat[[a$cluster]] else a$cluster
    if(is.null(cl)) .apm_abort("A cluster is required in {.arg build_vcov}.")
    getv<-function(nm) { z<-a[[nm]]; if(is.character(z)&&length(z)==1L&&z%in%names(dat)) dat[[z]] else z }
    apm_vcov(effects,cluster=cl,subgroup=getv("subgroup"),obs=getv("obs"),type=getv("type"),time1=getv("time1"),time2=getv("time2"),rho=rr,phi=a$phi %||% NULL,shared_control=a$shared_control %||% FALSE,near_pd=a$near_pd %||% FALSE,sparse=a$sparse %||% FALSE)
  }
  rows<-vector("list",length(rho)); fits<-vector("list",length(rho)); Vs<-vector("list",length(rho))
  for(i in seq_along(rho)) {
    rr<-rho[i]
    ans<-tryCatch({
      V<-build_one(rr); m<-fit_fun(effects,V=V,...); cf<-coef(m); ci<-tryCatch(confint(m),error=function(e) NULL); pr<-tryCatch(apm_prediction(m),error=function(e) NULL)
      est<-as.numeric(cf[1]); se<-sqrt(diag(vcov(m)))[1]
      lo<-if(!is.null(ci)) as.numeric(ci[1,1]) else NA_real_; hi<-if(!is.null(ci)) as.numeric(ci[1,2]) else NA_real_
      pi_lo<-if(!is.null(pr)&&nrow(pr$table)) pr$table$pi_lower[1] else NA_real_; pi_hi<-if(!is.null(pr)&&nrow(pr$table)) pr$table$pi_upper[1] else NA_real_
      tau2<-m$heterogeneity$tau2 %||% if(length(m$backend_fit$sigma2)) sum(m$backend_fit$sigma2,na.rm=TRUE) else NA_real_
      list(row=data.frame(rho=rr,estimate=est,se=se,ci_lower=lo,ci_upper=hi,pi_lower=pi_lo,pi_upper=pi_hi,tau2=tau2,ok=TRUE,error=NA_character_),V=V,fit=m)
    },error=function(e)list(row=data.frame(rho=rr,estimate=NA,se=NA,ci_lower=NA,ci_upper=NA,pi_lower=NA,pi_upper=NA,tau2=NA,ok=FALSE,error=conditionMessage(e)),V=NULL,fit=NULL))
    rows[[i]]<-ans$row; Vs[[i]]<-ans$V; fits[[i]]<-ans$fit
  }
  tab<-do.call(rbind,rows)
  out<-list(results=tab,rho=rho,metric=metric,fits=fits,V=Vs,n_fail=sum(!tab$ok),data_hash=.apm_hash_data(dat))
  if(out$n_fail>0L) .apm_warn("{out$n_fail} of {length(rho)} sensitivity fits failed; see results$error.")
  class(out)<-c("apm_sensitivity","apm_rho_sensitivity"); out
}
