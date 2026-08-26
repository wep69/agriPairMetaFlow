#' Audit non-independence among effect sizes
#'
#' @param effects Effect-size data.
#' @param plan Optional `apm_plan`.
#' @param V Optional sampling covariance matrix.
#' @param cluster Optional independent-cluster identifier.
#' @return An `apm_dependence_audit` object.
#' @export
#' @examples
#' es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_dependence_audit(es, cluster=study_id)
#' es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_dependence_audit(es2, cluster=study_id)
#' apm_dependence_audit(es, V=apm_vcov(es, cluster=experiment_id))
apm_dependence_audit <- function(effects, plan = NULL, V = NULL, cluster = NULL) {
  dat <- .apm_df(effects); qc<-rlang::enquo(cluster); cl<-.apm_pull_quo(dat,qc,"cluster",FALSE)
  repeated_cluster <- if(is.null(cl)) 0L else sum(table(cl)>1L)
  shared <- NULL
  if("control" %in% names(dat) && ("experiment_id" %in% names(dat) || "study_id" %in% names(dat))) {
    if("experiment_id" %in% names(dat)) shared <- apm_shared_control(dat,study=experiment_id,control_id=control,check_values=TRUE)
    else shared <- apm_shared_control(dat,study=study_id,control_id=control,check_values=TRUE)
  }
  n_shared <- if(is.null(shared)) 0L else shared$summary$n_shared_control_groups
  offdiag <- 0L; diag_only <- NA
  if(!is.null(V)) {
    M<-as.matrix(V); if(!all(dim(M)==c(nrow(dat),nrow(dat)))) .apm_abort("{.arg V} has incompatible dimensions.")
    offdiag<-sum(abs(M[row(M)!=col(M)])>1e-12); diag_only<-offdiag==0L
  }
  sources<-data.frame(source=c("repeated_cluster","shared_control","repeated_outcome","repeated_time"),count=c(repeated_cluster,n_shared,if(all(c("study_id","outcome")%in%names(dat))) sum(duplicated(dat[c("study_id","outcome")])) else 0L,if(all(c("study_id","time_month")%in%names(dat))) sum(duplicated(dat[c("study_id","time_month")])) else 0L),stringsAsFactors=FALSE)
  unresolved <- sources$count>0
  if(!is.null(V) && !diag_only) unresolved[sources$source %in% c("shared_control","repeated_outcome","repeated_time")] <- FALSE
  recommendation <- if(any(unresolved)) "Detected dependency should be addressed with an explicit V matrix and/or a hierarchical/cluster-robust model." else "No unresolved dependency was detected by the supplied identifiers and covariance information."
  out<-list(sources=sources,V_supplied=!is.null(V),V_diagonal=diag_only,off_diagonal_nonzero=offdiag,cluster=.apm_name_quo(qc),shared_control=shared,unresolved=sources[unresolved,,drop=FALSE],recommendation=recommendation,data_hash=.apm_hash_data(dat))
  class(out)<-"apm_dependence_audit"; out
}
