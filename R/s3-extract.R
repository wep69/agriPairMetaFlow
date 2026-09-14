summary.apm_model <- function(object, ...) {
  out <- list(coefficients=apm_table(object,"model",transform="none"),heterogeneity=apm_heterogeneity(object,ci=FALSE)$table,prediction=apm_prediction(object,transform="none")$raw,settings=object$settings,measure=object$measure)
  class(out)<-"summary.apm_model"; out
}
coef.apm_model <- function(object, ...) stats::coef(object$backend_fit, ...)
vcov.apm_model <- function(object, ...) stats::vcov(object$backend_fit, ...)
confint.apm_model <- function(object, parm = c("coef", "heterogeneity"), level = 0.95, ...) {
  parm <- match.arg(parm)
  if (identical(parm, "heterogeneity")) return(stats::confint(object$backend_fit, ...))
  cf <- stats::coef(object$backend_fit); se <- sqrt(diag(stats::vcov(object$backend_fit)))
  a <- (1 - level) / 2
  lo_nm <- paste0(format(100 * a, digits = 4L), " %"); hi_nm <- paste0(format(100 * (1 - a), digits = 4L), " %")
  crit <- stats::qnorm(1 - a)
  out <- cbind(cf - crit * se, cf + crit * se)
  colnames(out) <- c(lo_nm, hi_nm)
  out
}
predict.apm_model <- function(object, ...) apm_prediction(object, ...)
as.data.frame.apm_effects <- function(x, row.names = NULL, optional = FALSE, ...) { class(x)<-setdiff(class(x),"apm_effects"); as.data.frame(x,row.names=row.names,optional=optional,...) }
as.data.frame.apm_data <- function(x, row.names = NULL, optional = FALSE, ...) { as.data.frame(x$data,row.names=row.names,optional=optional,...) }
autoplot.apm_model <- function(object, type=c("forest","funnel"), ...) { type<-match.arg(type); if(type=="forest") apm_forest(object,...) else apm_funnel(object,...) }


tidy.apm_model <- function(x, ...) {
  tab <- apm_table(x, component = "model", transform = "none", digits = 15)
  tab <- attr(tab, "apm_unrounded") %||% tab
  zv <- tryCatch(as.numeric(x$backend_fit$zval), error = function(e) NULL)
  pv <- tryCatch(as.numeric(x$backend_fit$pval), error = function(e) NULL)
  tab$statistic <- if (!is.null(zv) && length(zv) == nrow(tab)) zv else NA_real_
  tab$p.value <- if (!is.null(pv) && length(pv) == nrow(tab)) pv else NA_real_
  tab
}

glance.apm_model <- function(x, ...) {
  fit <- x$backend_fit
  data.frame(
    k = fit$k %||% nrow(x$data),
    p = fit$p %||% length(stats::coef(fit)),
    tau2 = fit$tau2 %||% NA_real_,
    I2 = fit$I2 %||% NA_real_,
    Q = fit$QE %||% NA_real_,
    Q_p = fit$QEp %||% NA_real_,
    logLik = tryCatch(as.numeric(stats::logLik(fit)), error=function(e) NA_real_),
    AIC = tryCatch(stats::AIC(fit), error=function(e) NA_real_),
    BIC = tryCatch(stats::BIC(fit), error=function(e) NA_real_)
  )
}

augment.apm_model <- function(x, data = x$data, ...) {
  out <- as.data.frame(data)
  fitv <- tryCatch(as.numeric(stats::fitted(x$backend_fit)), error=function(e) rep(NA_real_,nrow(out)))
  resv <- tryCatch(as.numeric(stats::residuals(x$backend_fit)), error=function(e) rep(NA_real_,nrow(out)))
  if(length(fitv)==nrow(out)) out$.fitted <- fitv
  if(length(resv)==nrow(out)) out$.resid <- resv
  out
}

print.summary.apm_model <- function(x, ...) {
  cat("<summary.apm_model> measure=", x$measure, "\n", sep="")
  print(x$coefficients, row.names = FALSE)
  cat("Heterogeneity:\n"); print(x$heterogeneity, row.names = FALSE)
  cat("Prediction:\n"); print(x$prediction, row.names = FALSE)
  invisible(x)
}

predict.apm_metareg <- function(object, newdata = NULL, ...) {
  if(is.null(newdata)) return(apm_prediction(object,...))
  apm_predict_context(object,newdata=newdata,...)
}
coef.apm_dose <- function(object, ...) object$coefficients
vcov.apm_dose <- function(object, ...) object$vcov
summary.apm_dose <- function(object, ...) {
  out<-list(coefficients=data.frame(term=names(object$coefficients),estimate=as.numeric(object$coefficients),se=sqrt(diag(object$vcov))),
    covariance=object$covariance,dose_info=object$dose_info,gof=object$gof,backend=object$settings$backend)
  class(out)<-"summary.apm_dose";out
}
print.summary.apm_dose <- function(x, ...) { cat("<summary.apm_dose> backend=",x$backend,"\n",sep="");print(x$coefficients,row.names=FALSE);cat("Covariance source:",x$covariance$source,"\n");invisible(x) }
predict.apm_dose <- function(object, newdata = NULL, level = 0.95, transform = c("auto","none","exp","percent"), ...) {
  transform<-match.arg(transform)
  if(!is.null(object$dose_info$moderators)) .apm_abort("Generic prediction for dose-response meta-regression requires an explicit moderator-aware prediction route; use the backend object directly.")
  if(is.null(newdata)) {
    raw<-object$prediction_grid
    if(is.null(raw)) .apm_abort("No stored dose-response prediction grid is available.")
    dose<-raw$dose
  } else {
    if(is.numeric(newdata)) dose<-as.numeric(newdata) else {
      if(!is.data.frame(newdata))newdata<-as.data.frame(newdata)
      dn<-object$dose_info$dose_name;if(!dn%in%names(newdata)) .apm_abort("{.arg newdata} must contain dose column {.field {dn}}.")
      dose<-newdata[[dn]]
    }
    B<-.apm_dose_basis(dose,form=object$dose_info$form,df=object$dose_info$df,reference=object$dose_info$reference,meta=object$dose_info$basis)$matrix
    beta<-as.numeric(object$coefficients);Vb<-as.matrix(object$vcov)
    if(length(beta)!=ncol(B)) .apm_abort("Dose-response coefficient dimension is incompatible with one-dimensional prediction.")
    est<-drop(B%*%beta);se<-sqrt(pmax(0,rowSums((B%*%Vb)*B)));crit<-stats::qnorm(1-(1-level)/2)
    psi<-if(object$settings$backend=="dosresmeta")object$backend_fit$Psi%||%NULL else NULL
    pise<-if(!is.null(psi)&&all(dim(psi)==c(ncol(B),ncol(B))))sqrt(pmax(0,rowSums((B%*%(Vb+psi))*B))) else rep(NA_real_,length(dose))
    raw<-data.frame(dose=dose,pred=est,se=se,ci_lower=est-crit*se,ci_upper=est+crit*se,pi_lower=ifelse(is.finite(pise),est-crit*pise,NA_real_),pi_upper=ifelse(is.finite(pise),est+crit*pise,NA_real_))
  }
  tab<-raw;for(nm in intersect(c("pred","ci_lower","ci_upper","pi_lower","pi_upper"),names(tab)))tab[[nm]]<-.apm_transform_vector(tab[[nm]],object$measure,transform)
  out<-list(table=tab,raw=raw,newdata=newdata,method="dose",transform=transform,threshold=NULL,probability_greater=NULL,measure=object$measure,model_hash=object$source_data_hash%||%object$data_hash)
  class(out)<-"apm_prediction";out
}

autoplot.apm_dose <- function(object, ...) apm_dose_plot(object, ...)

coef.apm_multivariate <- function(object, ...) object$coefficients
vcov.apm_multivariate <- function(object, ...) object$vcov
summary.apm_multivariate <- function(object, ...) {
  out <- list(outcomes=object$outcome_estimates, between_cov=object$between_cov,
              between_cor=object$between_cor, backend=object$backend,
              structure=object$settings$structure, measure=object$measure)
  class(out) <- "summary.apm_multivariate"; out
}
print.summary.apm_multivariate <- function(x, ...) {
  cat("<summary.apm_multivariate> backend=", x$backend, " | structure=", x$structure, "\n", sep="")
  print(x$outcomes, row.names=FALSE)
  if (!is.null(x$between_cor)) { cat("Between-outcome correlation:\n"); print(x$between_cor) }
  invisible(x)
}
autoplot.apm_multivariate <- function(object, ...) apm_multivariate_plot(object, ...)

coef.apm_bayes <- function(object, ...) {
  if (nrow(object$posterior_summary)) {
    z <- object$posterior_summary$estimate
    names(z) <- object$posterior_summary$term
    return(z)
  }
  tryCatch(stats::coef(object$backend_fit, ...), error=function(e) numeric())
}
summary.apm_bayes <- function(object, ...) {
  d <- tryCatch(apm_bayes_diagnostics(object, checks="convergence", plot=FALSE), error=function(e) NULL)
  out <- list(posterior=object$posterior_summary, prior=object$prior, backend=object$backend_detail,
              measure=object$measure, diagnostics=d, settings=object$settings)
  class(out) <- "summary.apm_bayes"; out
}
print.summary.apm_bayes <- function(x, ...) {
  cat("<summary.apm_bayes> backend=", x$backend, " | measure=", x$measure, "\n", sep="")
  if (nrow(x$posterior)) print(x$posterior, row.names=FALSE)
  if (!is.null(x$diagnostics)) cat("Severe convergence failure:", x$diagnostics$severe_failure, "\n")
  invisible(x)
}
predict.apm_bayes <- function(object, ...) apm_bayes_predict(object, ...)
