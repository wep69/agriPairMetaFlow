#' Fit a common-, random-, or mixed-effects meta-analysis
#'
#' @param effects `apm_effects` or a data frame containing effect sizes.
#' @param yi,vi Effect and sampling-variance columns.
#' @param V Optional full sampling covariance matrix.
#' @param mods Moderator formula; `~ 1` fits the pooled mean.
#' @param model `"random"`, `"common"`, or `"mixed"`.
#' @param method Heterogeneity estimator, default REML.
#' @param test Inference method supported by the backend.
#' @param level Confidence level.
#' @param weights Optional user weights.
#' @param backend Backend selector; currently `metafor`.
#' @param ... Additional backend arguments.
#' @return An `apm_model` retaining the backend fit and analytical provenance.
#' @export
#' @examples
#' # Example 1: random-effects lnRR synthesis.
#' maize_100 <- maize_n_shared[maize_n_shared$N_rate == 100, ]
#' es1 <- apm_effect_size(maize_100, "lnRR", m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_fit(es1)
#' # Example 2: variability-ratio synthesis with Knapp-Hartung inference.
#' es2 <- apm_effect_size(covercrop_variability, "VR", m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_fit(es2, test="knha")
#' # Example 3: common-effect benchmark.
#' apm_fit(agri_effects_benchmark, yi=yi, vi=vi, model="common")
apm_fit <- function(effects, yi = yi, vi = vi, V = NULL, mods = ~ 1, model = c("random", "common", "mixed"), method = "REML", test = c("z", "t", "knha"), level = 0.95, weights = NULL, backend = c("auto", "metafor"), ...) {
  .apm_require("metafor","model fitting"); model<-match.arg(model); test<-match.arg(test); backend<-match.arg(backend); dat<-.apm_df(effects)
  qyi<-rlang::enquo(yi); qvi<-rlang::enquo(vi); yy<-.apm_pull_quo(dat,qyi,"yi",TRUE); vv<-.apm_pull_quo(dat,qvi,"vi",required=is.null(V)); .apm_check_numeric(yy,"yi")
  if (is.null(V)) { .apm_check_numeric(vv,"vi"); if(any(vv<=0,na.rm=TRUE)) .apm_abort("Sampling variances must be positive.") }
  keep <- is.finite(yy) & if(is.null(V)) is.finite(vv) & vv>0 else TRUE
  if (!all(keep)) .apm_warn("{sum(!keep)} row(s) with non-finite effect information were omitted and recorded.")
  dfit <- dat[keep,,drop=FALSE]; yy<-yy[keep]; if(!is.null(vv)) vv<-vv[keep]
  if (!inherits(mods,"formula")) .apm_abort("{.arg mods} must be a formula.")
  method_use <- if(model=="common") "FE" else method
  test_use <- if(test=="knha") "knha" else test
  extra <- list(...)
  if (is.null(V)) {
    uni_args <- c(list(yi=yy,vi=vv,mods=mods,data=dfit,method=method_use,test=test_use,level=level*100),extra)
    if (!is.null(weights)) uni_args$weights <- weights
    fit <- do.call("rma.uni", uni_args, envir=asNamespace("metafor"))
    fit$call <- as.call(c(list(quote(metafor::rma.uni)),uni_args))
  } else {
    if(!is.matrix(V)) V<-as.matrix(V); if(nrow(V)!=nrow(dat)||ncol(V)!=nrow(dat)) .apm_abort("{.arg V} must be square with one row/column per input effect.")
    if(max(abs(V-t(V)),na.rm=TRUE)>1e-10) .apm_abort("{.arg V} must be symmetric.")
    Vfit<-V[keep,keep,drop=FALSE]
    if(test=="knha") .apm_abort("Knapp-Hartung routing with a full V matrix is not enabled; use test='z' or 't'.")
    mv_args <- c(list(yi=yy,V=Vfit,mods=mods,data=dfit,method=method_use,test=test_use,level=level*100),extra)
    fit <- do.call("rma.mv", mv_args, envir=asNamespace("metafor"))
    fit$call <- as.call(c(list(quote(metafor::rma.mv)),mv_args))
  }
  cf<-stats::coef(fit); cv<-stats::vcov(fit)
  out<-list(backend_fit=fit,coefficients=cf,vcov=cv,V=if(is.null(V)) NULL else Vfit,heterogeneity=list(tau2=fit$tau2 %||% NA_real_,I2=fit$I2 %||% NA_real_,H2=fit$H2 %||% NA_real_,Q=fit$QE %||% NA_real_,Q_p=fit$QEp %||% NA_real_),model_matrix=fit$X %||% NULL,data=dfit,omitted=which(!keep),settings=list(model=model,method=method_use,test=test,level=level,mods=mods,backend="metafor"),measure=attr(effects,"measure") %||% if("measure"%in%names(dat)) as.character(dat$measure[1]) else "GEN",data_hash=.apm_hash_data(dfit),backend_version=.apm_backend_version("metafor"))
  class(out)<-"apm_model"; out
}
