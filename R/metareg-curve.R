#' Fit quantitative moderator curves in meta-regression
#'
#' Fits linear, hierarchical polynomial, natural-spline, or restricted-cubic-
#' spline relationships between a treatment-control effect and a quantitative
#' agronomic moderator. Curves describe across-study effect modification and
#' are not automatically causal treatment-dose recommendations.
#'
#' @param effects Effect-size data containing `yi` and `vi`.
#' @param x Quantitative moderator column.
#' @param form Functional form: linear, quadratic, cubic, natural spline (`ns`),
#'   or restricted cubic spline (`rcs`).
#' @param df Basis degrees of freedom for spline forms.
#' @param knots Optional internal knots. For `rcs`, at least four unique knots
#'   are required; otherwise deterministic quantile knots are generated.
#' @param V Optional sampling covariance matrix.
#' @param random Optional random-effects formula for dependent effects.
#' @param method Heterogeneity estimator.
#' @param level Confidence level used for the stored prediction grid.
#' @param grid Number of grid points across observed moderator support.
#' @return An `apm_curve` object inheriting from `apm_metareg` and `apm_model`.
#' @export
#' @examples
#' # Example 1: linear rainfall effect modification.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_metareg_curve(irr_es,rainfall,form="linear")
#' # Example 2: quadratic rainfall relationship with hierarchy preserved.
#' apm_metareg_curve(irr_es,rainfall,form="quadratic")
#' # Example 3: nonlinear N-rate association with shared-control covariance.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_V <- apm_vcov(mz_es,cluster=experiment_id)
#' apm_metareg_curve(mz_es,N_rate,form="ns",df=3,V=mz_V,
#'   random=~1|study_id/effect_id)
apm_metareg_curve <- function(effects, x, form = c("linear", "quadratic", "cubic", "ns", "rcs"), df = 3, knots = NULL, V = NULL, random = NULL, method = "REML", level = 0.95, grid = 100) {
  .apm_require("metafor","quantitative moderator meta-regression")
  form <- match.arg(form)
  dat0 <- .apm_df(effects); qx <- rlang::enquo(x); xv <- .apm_pull_quo(dat0,qx,"x",TRUE); xname <- .apm_name_quo(qx)
  .apm_check_numeric(xv,"x")
  if(!all(c("yi","vi")%in%names(dat0))) .apm_abort("{.arg effects} must contain {.field yi} and {.field vi}.")
  if(!is.numeric(grid)||length(grid)!=1L||grid<25||grid>5000) .apm_abort("{.arg grid} must be between 25 and 5000.")
  if(!is.numeric(level)||level<=0||level>=1) .apm_abort("{.arg level} must lie between 0 and 1.")
  keep <- is.finite(dat0$yi)&is.finite(dat0$vi)&dat0$vi>0&is.finite(xv)
  if(!all(keep)) .apm_warn("{sum(!keep)} incomplete effect/moderator row(s) were omitted and recorded.")
  dat_source<-dat0[keep,,drop=FALSE]; xv<-xv[keep]
  if(length(unique(xv)) < if(form %in% c("cubic","ns","rcs")) 5L else 3L) .apm_abort("Insufficient unique moderator values for the requested curve form.")
  boundary<-range(xv); center<-mean(xv)
  basis<-.apm_curve_basis(xv,form=form,df=df,knots=knots,boundary=boundary,center=center)
  dat<-dat_source
  for(j in seq_len(ncol(basis$matrix))) dat[[colnames(basis$matrix)[j]]]<-basis$matrix[,j]
  mods<-stats::as.formula(paste("~",paste(colnames(basis$matrix),collapse=" + ")))
  Vfit<-NULL
  if(!is.null(V)) { V<-as.matrix(V); if(!all(dim(V)==c(nrow(dat0),nrow(dat0)))) .apm_abort("{.arg V} must be square with one row and column per input effect."); if(max(abs(V-t(V)),na.rm=TRUE)>1e-10) .apm_abort("{.arg V} must be symmetric."); Vfit<-V[keep,keep,drop=FALSE] }
  use_mv<-!is.null(Vfit)||!is.null(random)
  if(!is.null(random)&&!inherits(random,"formula")) .apm_abort("{.arg random} must be a formula.")
  if(use_mv) {
    if(is.null(Vfit)) Vfit<-diag(dat$vi)
    fit<-metafor::rma.mv(yi=dat$yi,V=Vfit,mods=mods,random=random,data=dat,method=method,test="t")
    null_fit<-tryCatch(metafor::rma.mv(yi=dat$yi,V=Vfit,mods=~1,random=random,data=dat,method=method,test="t"),error=function(e)NULL)
  } else {
    fit<-metafor::rma.uni(yi=dat$yi,vi=dat$vi,mods=mods,data=dat,method=method,test="t")
    null_fit<-tryCatch(metafor::rma.uni(yi=dat$yi,vi=dat$vi,mods=~1,data=dat,method=method,test="t"),error=function(e)NULL)
  }
  info<-list(variables=xname,centers=setNames(center,xname),scales=setNames(1,xname),factor_levels=list(),
    support=setNames(list(list(type="numeric",min=boundary[1],max=boundary[2],unique=length(unique(xv)))),xname),
    formula=mods,model_matrix_colnames=colnames(stats::model.matrix(mods,data=dat)))
  out<-list(backend_fit=fit,null_backend_fit=null_fit,coefficients=stats::coef(fit),vcov=stats::vcov(fit),
    heterogeneity=list(tau2=fit$tau2%||%NA_real_,sigma2=fit$sigma2%||%numeric(),gamma2=fit$gamma2%||%numeric(),QE=fit$QE%||%NA_real_,QEp=fit$QEp%||%NA_real_,meta_R2_percent=if(is.null(null_fit))NA_real_ else .apm_meta_r2(fit,null_fit)),
    joint_test=data.frame(QM=fit$QM%||%NA_real_,df=fit$m%||%ncol(basis$matrix),p_value=fit$QMp%||%NA_real_),
    model_matrix=fit$X%||%NULL,data=dat,source_data=dat_source,V=Vfit,omitted=which(!keep),moderator_info=info,
    settings=list(mods=mods,original_mods=NULL,random=random,method=method,test="t",center=FALSE,scale=FALSE,backend=if(use_mv)"metafor::rma.mv" else "metafor::rma.uni"),
    measure=attr(effects,"measure")%||%if("measure"%in%names(dat0))as.character(dat0$measure[1]) else "GEN",
    data_hash=.apm_hash_data(dat_source),source_data_hash=.apm_hash_data(dat_source),backend_version=.apm_backend_version("metafor"),
    curve_info=list(x_name=xname,form=form,df=df,knots=basis$knots,boundary=boundary,center=center,basis_names=colnames(basis$matrix),level=level))
  class(out)<-c("apm_curve","apm_metareg","apm_model")
  gx<-seq(boundary[1],boundary[2],length.out=as.integer(grid)); raw<-.apm_curve_predict_raw(out,gx,level=level,prediction=TRUE)
  out$prediction_grid<-cbind(setNames(data.frame(gx),xname),raw,support="interpolation")
  out
}
