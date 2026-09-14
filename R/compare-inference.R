#' Compare conventional, robust, and wild-bootstrap inference
#'
#' @param model Base `apm_model`.
#' @param robust Optional `apm_robust` result.
#' @param wild Optional `apm_wild` result.
#' @param methods Methods to include.
#' @param transform Output transformation.
#' @return An `apm_inference_comparison` object.
#' @export
#' @examples
#' es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' fit <- apm_fit(es,mods=~rainfall)
#' if (requireNamespace("clubSandwich",quietly=TRUE)) { cr <- apm_robust(fit,cluster=study_id); apm_compare_inference(fit,robust=cr) }
#' apm_compare_inference(fit,methods="model",transform="none")
#' apm_compare_inference(apm_fit(es),methods="model",transform="percent")
apm_compare_inference <- function(model, robust = NULL, wild = NULL, methods = c("model", "CR2", "wild"), transform = c("auto", "none", "exp", "percent")) {
  transform<-match.arg(transform); methods<-unique(methods)
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an agriPairMetaFlow model.")
  if(!is.null(robust) && (!inherits(robust,"apm_robust") || !identical(robust$model_hash,model$data_hash))) .apm_abort("{.arg robust} does not correspond to the same model data.")
  if(!is.null(wild) && (!inherits(wild,"apm_wild") || !identical(wild$model_hash,model$data_hash))) .apm_abort("{.arg wild} does not correspond to the same model data.")
  cf<-stats::coef(model$backend_fit); se<-sqrt(diag(stats::vcov(model$backend_fit)))
  alpha <- 1 - (model$settings$level %||% .95)
  use_t <- identical(model$settings$test, "t") && !is.null(model$backend_fit$ddf)
  ddf <- if(use_t) as.numeric(model$backend_fit$ddf) else rep(NA_real_,length(cf))
  crit <- if(use_t) stats::qt(1-alpha/2,df=ddf) else stats::qnorm(1-alpha/2)
  pv <- model$backend_fit$pval %||% rep(NA_real_,length(cf))
  tab<-data.frame(method="model",term=names(cf),estimate=as.numeric(cf),se=as.numeric(se),df=ddf,ci_lower=as.numeric(cf)-crit*se,ci_upper=as.numeric(cf)+crit*se,p_value=as.numeric(pv),stringsAsFactors=FALSE)
  if(!is.null(robust) && any(toupper(methods)%in%c("CR2","CR1","CR0","ROBUST"))) {
    z<-robust$coefficients; nm<-tolower(names(z)); get<-function(patterns) { for(p in patterns) { j<-grep(p,nm); if(length(j)) return(z[[j[1]]]) }; rep(NA_real_,nrow(z)) }
    cn<-if(!is.null(robust$confint)) tolower(names(robust$confint)) else character()
    getc<-function(patterns) { for(p in patterns) { j<-grep(p,cn); if(length(j)) return(robust$confint[[j[1]]]) }; rep(NA_real_,nrow(z)) }
    rt<-data.frame(method=robust$type,term=z$term,estimate=get(c("^estimate$","^beta$","^coef$")),se=get(c("^se$","^std")),df=get(c("d\\.?f","satt")),ci_lower=getc(c("lower","^ci_l","ci\\.l")),ci_upper=getc(c("upper","^ci_u","ci\\.u")),p_value=get(c("p.*val","^p_")),stringsAsFactors=FALSE)
    if(anyNA(rt$estimate)) .apm_warn("Could not map robust estimates from the {robust$backend} object.")
    tab<-rbind(tab,rt)
  }
  if(!is.null(wild)&&"wild"%in%tolower(methods)) tab<-rbind(tab,data.frame(method="wild",term="joint_test",estimate=NA,se=NA,df=NA,ci_lower=NA,ci_upper=NA,p_value=wild$p_value,stringsAsFactors=FALSE))
  if(transform=="auto") transform<-if((model$measure %||% "")%in%c("lnRR","RR","OR","VR","CVR")) "exp" else "none"
  if(transform=="exp") for(nm in c("estimate","ci_lower","ci_upper")) tab[[nm]]<-exp(tab[[nm]])
  if(transform=="percent") { if(!((model$measure %||% "")%in%c("lnRR","ROM","GEN"))) .apm_warn("Percent transformation assumes a log-ratio estimand."); for(nm in c("estimate","ci_lower","ci_upper")) tab[[nm]]<-100*(exp(tab[[nm]])-1) }
  out<-list(table=tab,transform=transform,model_hash=model$data_hash,measure=model$measure,discrepancy=list(max_se_ratio=if(any(is.finite(tab$se))) max(tab$se,na.rm=TRUE)/min(tab$se[tab$se>0],na.rm=TRUE) else NA_real_))
  class(out)<-"apm_inference_comparison"; out
}
