#' Fit prespecified subgroup meta-analyses
#'
#' @param effects Effect-size data.
#' @param subgroup Prespecified subgroup column.
#' @param method Heterogeneity estimator.
#' @param test Inference method.
#' @param interaction_test Test the overall between-subgroup moderator effect.
#' @param min_studies Row-count threshold below which a sparsity warning is
#'   issued. All subgroup levels are still fitted; the argument does not drop
#'   levels.
#' @param ... Passed to `apm_fit()`.
#' @return An `apm_subgroup` object.
#' @export
#' @examples
#' # Example 1: inoculant effects by crop.
#' e1 <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_subgroup(e1, crop)
#' # Example 2: irrigation effects by climate zone.
#' e2 <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_subgroup(e2, climate_zone)
#' # Example 3: benchmark effects by soil texture.
#' apm_subgroup(agri_effects_benchmark, soil_texture, interaction_test=TRUE)
apm_subgroup <- function(effects, subgroup, method = "REML", test = "knha", interaction_test = TRUE, min_studies = 2, ...) {
  dat<-.apm_df(effects); q<-rlang::enquo(subgroup); sg<-.apm_pull_quo(dat,q,"subgroup",TRUE); sg<-factor(sg)
  counts<-table(sg); sparse<-names(counts)[counts<min_studies]; if(length(sparse)) .apm_warn("Sparse subgroup level(s): {paste(sparse,collapse=', ')}")
  fits<-lapply(levels(sg),function(g){ idx<-which(sg==g); if(length(idx)<2) return(NULL); e<-dat[idx,,drop=FALSE]; class(e)<-class(effects); attr(e,"measure")<-attr(effects,"measure"); apm_fit(e,yi=yi,vi=vi,method=method,test=test,...) }); names(fits)<-levels(sg)
  rows<-lapply(names(fits),function(g){ f<-fits[[g]]; if(is.null(f)) return(data.frame(subgroup=g,k=counts[[g]],estimate=NA,se=NA,ci_lower=NA,ci_upper=NA,pi_lower=NA,pi_upper=NA)); pr<-stats::predict(f$backend_fit); data.frame(subgroup=g,k=counts[[g]],estimate=as.numeric(pr$pred),se=as.numeric(pr$se),ci_lower=as.numeric(pr$ci.lb),ci_upper=as.numeric(pr$ci.ub),pi_lower=as.numeric(pr$pi.lb %||% NA),pi_upper=as.numeric(pr$pi.ub %||% NA)) }); estimates<-do.call(rbind,rows)
  omnibus<-NULL
  if(interaction_test && nlevels(sg)>1){ tmp<-dat; tmp$.apm_subgroup<-sg; fitall<-metafor::rma.uni(yi=tmp$yi,vi=tmp$vi,mods=~.apm_subgroup,data=tmp,method=method,test=if(test=="knha")"knha" else test); omnibus<-data.frame(QM=fitall$QM,df=fitall$m,QMp=fitall$QMp) }
  out<-list(subgroup_estimates=estimates,models=fits,omnibus_test=omnibus,counts=counts,measure=attr(effects,"measure") %||% "GEN",subgroup_name=.apm_name_quo(q)); class(out)<-"apm_subgroup"; out
}
