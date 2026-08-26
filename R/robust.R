#' Cluster-robust inference for meta-analytic models
#'
#' @param model Fitted `apm_model`.
#' @param cluster Independent cluster identifier.
#' @param vcov CR estimator (`CR2` recommended).
#' @param test Small-sample coefficient test.
#' @param constraints Optional coefficient indices, names/regex, or a constraint matrix for a joint test.
#' @return An `apm_robust` object with CR variance, coefficient tests and optional Wald test.
#' @export
#' @examples
#' es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' fit <- apm_fit(es,mods=~rainfall)
#' apm_robust(fit,cluster=study_id)
#' apm_robust(fit,cluster=study_id,vcov="CR1")
#' apm_robust(fit,cluster=study_id,constraints=2)
apm_robust <- function(model, cluster, vcov = c("CR2", "CR1", "CR0"), test = c("Satterthwaite", "saddlepoint"), constraints = NULL) {
  .apm_require("clubSandwich","cluster-robust inference"); vcov<-match.arg(vcov); test<-match.arg(test)
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an agriPairMetaFlow model.")
  dat<-model$data; qc<-rlang::enquo(cluster); cl<-.apm_pull_quo(dat,qc,"cluster",TRUE); if(anyNA(cl)) .apm_abort("{.arg cluster} cannot contain missing values.")
  m<-length(unique(cl)); p<-length(stats::coef(model$backend_fit)); if(m<2L) .apm_abort("At least two independent clusters are required.")
  Vcr<-clubSandwich::vcovCR(model$backend_fit,cluster=cl,type=vcov)
  ct<-clubSandwich::coef_test(model$backend_fit,vcov=Vcr,test=test)
  ctdf<-as.data.frame(ct); ctdf$term<-rownames(ctdf); rownames(ctdf)<-NULL
  ci<-tryCatch(as.data.frame(clubSandwich::conf_int(model$backend_fit,vcov=Vcr,level=model$settings$level %||% .95,test="Satterthwaite")),error=function(e)NULL)
  joint<-NULL
  if(!is.null(constraints)) {
    C<-constraints
    if(is.character(C)) { idx<-grep(paste(C,collapse="|"),names(stats::coef(model$backend_fit))); if(!length(idx)) .apm_abort("No coefficient matched {.arg constraints}."); C<-clubSandwich::constrain_zero(idx) }
    else if(is.numeric(C)) C<-clubSandwich::constrain_zero(C)
    joint<-as.data.frame(clubSandwich::Wald_test(model$backend_fit,constraints=C,vcov=Vcr,test="HTZ"))
  }
  dfcol<-grep("d.f",names(ctdf),value=TRUE,fixed=TRUE); mindf<-if(length(dfcol)) suppressWarnings(min(ctdf[[dfcol[1]]],na.rm=TRUE)) else NA_real_
  out<-list(vcov=as.matrix(Vcr),coefficients=ctdf,confint=ci,joint=joint,n_clusters=m,cluster=.apm_name_quo(qc),type=vcov,test=test,min_df=mindf,low_df=is.finite(mindf)&&mindf<4,model_hash=model$data_hash,model_coef=stats::coef(model$backend_fit),backend="clubSandwich",backend_version=.apm_backend_version("clubSandwich"))
  if(out$low_df) .apm_warn("Some robust denominator degrees of freedom are below 4; inference may be unstable.")
  class(out)<-"apm_robust"; out
}
