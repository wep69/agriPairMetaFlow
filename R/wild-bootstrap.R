#' Cluster wild-bootstrap inference for a meta-analytic model
#'
#' @param model Fitted `apm_model`.
#' @param cluster Independent cluster identifier.
#' @param constraints Optional coefficient indices, names/regex, matrix, or constraint function.
#' @param R Number of bootstrap replications.
#' @param seed Reproducibility seed.
#' @param type Auxiliary weight distribution.
#' @param parallel Logical; reserved for backend-supported parallel execution.
#' @return An `apm_wild` object.
#' @export
#' @examples
#' es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' fit <- apm_fit(es,mods=~rainfall)
#' if (requireNamespace("wildmeta",quietly=TRUE)) apm_wild_bootstrap(fit,cluster=study_id,R=199,seed=42)
#' if (requireNamespace("wildmeta",quietly=TRUE)) apm_wild_bootstrap(fit,cluster=study_id,constraints=2,R=199,seed=42)
#' if (requireNamespace("wildmeta",quietly=TRUE)) apm_wild_bootstrap(fit,cluster=study_id,R=199,seed=7,type="Mammen")
apm_wild_bootstrap <- function(model, cluster, constraints = NULL, R = 9999, seed = NULL, type = c("Rademacher", "Mammen"), parallel = FALSE) {
  .apm_require("wildmeta","cluster wild-bootstrap inference"); .apm_require("clubSandwich","wild-bootstrap constraints"); type<-match.arg(type)
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an agriPairMetaFlow model.")
  if(length(R)!=1L||!is.numeric(R)||!is.finite(R)||R<99||R!=as.integer(R)) .apm_abort("{.arg R} must be an integer of at least 99.")
  dat<-model$data; qc<-rlang::enquo(cluster); cl<-.apm_pull_quo(dat,qc,"cluster",TRUE)
  cf<-stats::coef(model$backend_fit); p<-length(cf)
  C<-constraints
  if(is.null(C)) { idx<-if(p==1L) 1L else seq.int(2L,p); C<-clubSandwich::constrain_zero(idx) }
  else if(is.character(C)) { idx<-grep(paste(C,collapse="|"),names(cf)); if(!length(idx)) .apm_abort("No coefficient matched {.arg constraints}."); C<-clubSandwich::constrain_zero(idx) }
  else if(is.numeric(C)) C<-clubSandwich::constrain_zero(C)
  if(isTRUE(parallel)) .apm_warn("Parallel execution is delegated to wildmeta/future and is not configured automatically in this development snapshot.")
  ans<-wildmeta::Wald_test_cwb(full_model=model$backend_fit,constraints=C,R=as.integer(R),cluster=cl,auxiliary_dist=type,seed=seed)
  tab<-as.data.frame(ans)
  pcol<-grep("p",tolower(names(tab)),value=TRUE); pval<-if(length(pcol)) suppressWarnings(as.numeric(tab[[pcol[length(pcol)]]][1])) else NA_real_
  mcse<-if(is.finite(pval)) sqrt(pval*(1-pval)/R) else NA_real_
  out<-list(test=tab,p_value=pval,mcse=mcse,R=as.integer(R),seed=seed,type=type,n_clusters=length(unique(cl)),cluster=.apm_name_quo(qc),constraints=C,model_hash=model$data_hash,model_coef=cf,backend="wildmeta",backend_version=.apm_backend_version("wildmeta"))
  class(out)<-"apm_wild"; out
}
