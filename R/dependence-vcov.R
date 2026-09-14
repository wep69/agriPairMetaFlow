#' Construct a sampling variance-covariance matrix for dependent effects
#'
#' @param effects `apm_effects` or data frame containing `vi`.
#' @param cluster Clustering variable defining independent studies/experiments.
#' @param subgroup,obs,type,time1,time2 Optional dependency descriptors passed to `metafor::vcalc()`.
#' @param rho Within-cluster correlation or correlation matrix for constructs/scales.
#' @param phi Autocorrelation parameter for repeated time points.
#' @param shared_control Detect and model shared treatment/control arms using `treatment` and `control` columns when available.
#' @param near_pd Opt-in nearest positive-definite correction in `metafor::vcalc()`.
#' @param sparse Return a sparse matrix when supported.
#' @return An `apm_vcov` matrix with dependency metadata and diagnostics.
#' @export
#' @examples
#' es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_vcov(es, cluster=experiment_id, shared_control=TRUE)
#' es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_vcov(es2, cluster=study_id, type=outcome, rho=.5, shared_control=FALSE)
#' apm_vcov(es, cluster=study_id, rho=.4, shared_control=FALSE)
apm_vcov <- function(effects, cluster, subgroup = NULL, obs = NULL, type = NULL, time1 = NULL, time2 = NULL, rho = NULL, phi = NULL, shared_control = TRUE, near_pd = FALSE, sparse = FALSE) {
  .apm_require("metafor", "dependent-effect covariance construction")
  dat <- .apm_df(effects)
  if (!"vi" %in% names(dat)) .apm_abort("{.arg effects} must contain a {.field vi} column.")
  vi <- dat$vi; .apm_check_numeric(vi,"vi")
  if (any(vi <= 0, na.rm=TRUE)) .apm_abort("Sampling variances must be positive.")
  pull <- function(q,nm) .apm_pull_quo(dat,q,nm,FALSE)
  qc <- rlang::enquo(cluster); qs <- rlang::enquo(subgroup); qo <- rlang::enquo(obs); qty <- rlang::enquo(type); qt1 <- rlang::enquo(time1); qt2 <- rlang::enquo(time2)
  cl <- .apm_pull_quo(dat,qc,"cluster",TRUE)
  sg <- pull(qs,"subgroup"); ob <- pull(qo,"obs"); ty <- pull(qty,"type"); t1 <- pull(qt1,"time1"); t2 <- pull(qt2,"time2")
  if (anyNA(cl)) .apm_abort("{.arg cluster} cannot contain missing values.")
  use_shared <- isTRUE(shared_control) && all(c("treatment","control") %in% names(dat))
  args <- list(vi=vi, cluster=cl, checkpd=TRUE, nearpd=near_pd, sparse=sparse)
  if (!is.null(sg)) args$subgroup <- sg
  if (!is.null(ob)) args$obs <- ob
  if (!is.null(ty)) args$type <- ty
  if (!is.null(t1)) args$time1 <- t1
  if (!is.null(t2)) args$time2 <- t2
  if (!is.null(rho)) args$rho <- rho
  if (!is.null(phi)) args$phi <- phi
  if (use_shared) {
    args$grp1 <- if("treatment_id" %in% names(dat)) dat$treatment_id else dat$treatment
    args$grp2 <- if("control_id" %in% names(dat)) dat$control_id else dat$control
    if (all(c("n_t","n_c") %in% names(dat))) { args$w1 <- dat$n_t; args$w2 <- dat$n_c }
  }
  V <- do.call(metafor::vcalc, args)
  M <- as.matrix(V)
  if (nrow(M)!=nrow(dat) || ncol(M)!=nrow(dat)) .apm_abort("Backend returned a covariance matrix with incompatible dimensions.")
  if (max(abs(diag(M)-vi),na.rm=TRUE) > 1e-8) .apm_abort("The covariance-matrix diagonal does not reproduce {.field vi} within tolerance.")
  if (max(abs(M-t(M)),na.rm=TRUE) > 1e-10) .apm_abort("The constructed covariance matrix is not symmetric.")
  ev <- tryCatch(eigen(M,symmetric=TRUE,only.values=TRUE)$values,error=function(e) NA_real_)
  meta <- list(cluster=.apm_name_quo(qc),subgroup=.apm_name_quo(qs),obs=.apm_name_quo(qo),type=.apm_name_quo(qty),time1=.apm_name_quo(qt1),time2=.apm_name_quo(qt2),rho=rho,phi=phi,shared_control=use_shared,near_pd=near_pd,sparse=sparse,min_eigen=min(ev,na.rm=TRUE),positive_semidefinite=all(ev >= -1e-8,na.rm=TRUE),backend="metafor::vcalc",backend_version=.apm_backend_version("metafor"),data_hash=.apm_hash_data(dat))
  if (isS4(V)) {
    attr(V,"apm_meta") <- meta
    V
  } else {
    attr(V,"apm_meta") <- meta
    class(V) <- unique(c("apm_vcov", class(V)))
    V
  }
}
