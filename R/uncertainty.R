#' Recover standard deviations from reported uncertainty
#'
#' @param data Data frame.
#' @param mean,n Required mean and sample-size columns.
#' @param sd,se,cv,mse,ci_lower,ci_upper Optional uncertainty columns.
#' @param level Confidence level for CI inversion.
#' @param df Optional degrees of freedom.
#' @param method Recovery route; `"auto"` uses available information row by row.
#' @param impute If `TRUE`, explicitly impute remaining SDs using the median SD within `group`.
#' @param group Optional grouping column for explicit imputation.
#' @return An `apm_uncertainty` object.
#' @export
#' @examples
#' # Example 1: recover SD from SE.
#' apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, se=se_yield)
#' # Example 2: recover SD from reported CV percent.
#' apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, cv=cv_percent, method="cv")
#' # Example 3: recover SD from residual MSE.
#' apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, mse=residual_mse, method="mse")
apm_recover_uncertainty <- function(data, mean, n, sd = NULL, se = NULL, cv = NULL, mse = NULL, ci_lower = NULL, ci_upper = NULL, level = 0.95, df = NULL, method = c("auto", "sd", "se", "cv", "mse", "ci"), impute = FALSE, group = NULL) {
  method <- match.arg(method); dat <- .apm_df(data)
  qmean<-rlang::enquo(mean); qn<-rlang::enquo(n); qsd<-rlang::enquo(sd); qse<-rlang::enquo(se); qcv<-rlang::enquo(cv); qmse<-rlang::enquo(mse); qlo<-rlang::enquo(ci_lower); qhi<-rlang::enquo(ci_upper); qdf<-rlang::enquo(df); qgrp<-rlang::enquo(group)
  mu <- .apm_pull_quo(dat,qmean,"mean",TRUE); nn <- .apm_pull_quo(dat,qn,"n",TRUE); .apm_check_numeric(mu,"mean"); .apm_check_numeric(nn,"n")
  if (any(nn <= 0,na.rm=TRUE)) .apm_abort("Sample sizes must be positive.")
  vals <- list(sd=.apm_pull_quo(dat,qsd,"sd"),se=.apm_pull_quo(dat,qse,"se"),cv=.apm_pull_quo(dat,qcv,"cv"),mse=.apm_pull_quo(dat,qmse,"mse"),lo=.apm_pull_quo(dat,qlo,"ci_lower"),hi=.apm_pull_quo(dat,qhi,"ci_upper"),df=.apm_pull_quo(dat,qdf,"df"))
  outsd <- rep(NA_real_,nrow(dat)); outse <- rep(NA_real_,nrow(dat)); deriv <- rep(NA_character_,nrow(dat)); assumptions <- rep(NA_character_,nrow(dat))
  use <- function(idx, s, lab, ass=NA_character_) { outsd[idx] <<- s[idx]; outse[idx] <<- s[idx]/sqrt(nn[idx]); deriv[idx] <<- lab; assumptions[idx] <<- ass }
  allowed <- if (method=="auto") c("sd","se","cv","mse","ci") else method
  for (m in allowed) {
    idx <- which(is.na(outsd))
    if (!length(idx)) break
    if (m=="sd" && !is.null(vals$sd)) { ok<-idx[!is.na(vals$sd[idx]) & vals$sd[idx]>=0]; if(length(ok)) use(ok,vals$sd,"reported_sd") }
    if (m=="se" && !is.null(vals$se)) { ok<-idx[!is.na(vals$se[idx]) & vals$se[idx]>=0]; s<-rep(NA_real_,nrow(dat)); s[ok]<-vals$se[ok]*sqrt(nn[ok]); if(length(ok)) use(ok,s,"derived_from_se") }
    if (m=="cv" && !is.null(vals$cv)) { ok<-idx[!is.na(vals$cv[idx]) & !is.na(mu[idx]) & mu[idx]!=0]; cvv<-vals$cv; percent<-abs(cvv)>1 & !is.na(cvv); cvv[percent]<-cvv[percent]/100; s<-abs(cvv*mu); if(length(ok)) use(ok,s,"derived_from_cv", "CV values with absolute value > 1 were interpreted as percent.") }
    if (m=="mse" && !is.null(vals$mse)) { ok<-idx[!is.na(vals$mse[idx]) & vals$mse[idx]>=0]; s<-sqrt(vals$mse); if(length(ok)) use(ok,s,"derived_from_mse","Residual MSE is assumed to estimate the within-arm residual variance on the response scale.") }
    if (m=="ci" && !is.null(vals$lo) && !is.null(vals$hi)) { ok<-idx[!is.na(vals$lo[idx]) & !is.na(vals$hi[idx]) & vals$hi[idx]>vals$lo[idx]]; if(length(ok)) { dff<-vals$df; crit<-if(is.null(dff)) rep(stats::qnorm(1-(1-level)/2),nrow(dat)) else ifelse(is.na(dff),stats::qnorm(1-(1-level)/2),stats::qt(1-(1-level)/2,dff)); se0<-(vals$hi-vals$lo)/(2*crit); s<-se0*sqrt(nn); use(ok,s,"derived_from_ci",if(is.null(dff)) "Normal critical value used because df was not supplied." else "t critical value used where df was available; otherwise normal approximation.") } }
  }
  if (impute && anyNA(outsd)) {
    grp <- .apm_pull_quo(dat,qgrp,"group") %||% rep("all",nrow(dat)); missing <- which(is.na(outsd));
    for (g in unique(grp[missing])) { idx<-which(grp==g & is.na(outsd)); ref<-outsd[grp==g & !is.na(outsd)]; if(length(ref)) { outsd[idx]<-median(ref); outse[idx]<-outsd[idx]/sqrt(nn[idx]); deriv[idx]<-"imputed_group_median_sd"; assumptions[idx]<-"Explicit imputation requested by user; sensitivity analysis is recommended." } }
  }
  ans <- dat; ans$.apm_sd <- outsd; ans$.apm_se <- outse; ans$.apm_uncertainty_method <- deriv; ans$.apm_uncertainty_assumption <- assumptions
  obj <- list(data=ans, derivations=data.frame(row=seq_len(nrow(dat)), method=deriv, assumption=assumptions, stringsAsFactors=FALSE), assumptions=unique(na.omit(assumptions)), provenance=list(level=level,method=method,impute=impute))
  class(obj)<-"apm_uncertainty"; obj
}
