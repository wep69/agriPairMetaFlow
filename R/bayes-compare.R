# Bayesian model comparison ------------------------------------------------

.apm_bayes_predictive_criterion <- function(model, criterion) {
  if (model$backend == "brms") {
    return(if (criterion == "loo") loo::loo(model$backend_fit) else loo::waic(model$backend_fit))
  }
  if (model$backend == "RoBMA") {
    .apm_require("RoBMA", "RoBMA predictive model comparison")
    fit <- model$backend_fit
    if (criterion == "loo") {
      fit <- RoBMA::add_loo(fit)
      return(loo::loo(fit))
    }
    fit <- RoBMA::add_waic(fit)
    return(loo::waic(fit))
  }
  .apm_abort("LOO/WAIC comparison is available for brms and RoBMA backends; bayesmeta does not expose the required pointwise predictive log-likelihood through this adapter.")
}

#' Compare prespecified Bayesian meta-analytic models
#' @param ... Two or more `apm_bayes` models, or one RoBMA model for model-probability summaries.
#' @param criterion LOO, WAIC, or posterior model probability.
#' @param weights Whether predictive stacking weights should be returned for LOO, or native posterior model probabilities retained for a RoBMA ensemble.
#' @return An `apm_bayes_comparison` object.
#' @export
#' @examples
#' if (requireNamespace("brms",quietly=TRUE)) { # apm_bayes_compare(b1,b2,criterion="loo")
#' }
#' if (requireNamespace("RoBMA",quietly=TRUE)) { # apm_bayes_compare(r1,r2,criterion="waic")
#' }
#' if (requireNamespace("RoBMA",quietly=TRUE)) { # apm_bayes_compare(robma_yield,criterion="model_probability")
#' }
apm_bayes_compare <- function(..., criterion = c("loo", "waic", "model_probability"), weights = TRUE) {
  models<-list(...); criterion<-match.arg(criterion)
  if(!length(models)||any(!vapply(models,inherits,logical(1),what="apm_bayes"))) .apm_abort("All supplied objects must inherit from apm_bayes.")
  measures<-unique(vapply(models,function(x)x$measure,character(1))); if(length(measures)>1L) .apm_abort("Bayesian model comparison requires a common effect measure.")
  hashes<-unique(vapply(models,function(x)x$data_hash,character(1))); if(length(hashes)>1L) .apm_abort("Bayesian model comparison requires models fitted to the same analysis dataset.")
  diag_ok<-vapply(models,function(x){
    d<-tryCatch(apm_bayes_diagnostics(x,checks="convergence",plot=FALSE),error=function(e)NULL)
    !is.null(d) && isTRUE(d$diagnostics_verified) && isTRUE(d$interpretation_allowed)
  },logical(1))
  if(any(!diag_ok)) .apm_abort("At least one model has failed or unverified convergence diagnostics; comparison is blocked until the local diagnostic gate is resolved.")
  nm<-names(models);if(is.null(nm)||any(!nzchar(nm)))nm<-paste0("model",seq_along(models))
  tab<-NULL;native<-NULL;weight_values<-NULL;weight_type<-NULL
  if(criterion%in%c("loo","waic")) {
    .apm_require("loo","Bayesian predictive model comparison")
    if(length(models)<2L) .apm_abort("LOO/WAIC comparison requires at least two prespecified models.")
    backends <- unique(vapply(models,function(x)x$backend,character(1)))
    if(length(backends)!=1L || !backends %in% c("brms","RoBMA"))
      .apm_abort("LOO/WAIC comparison requires models from the same supported backend (brms or RoBMA). Cross-backend predictive criteria are intentionally not combined.")
    objs<-setNames(lapply(models,.apm_bayes_predictive_criterion,criterion=criterion),nm)
    if(criterion=="loo") {
      cmp<-do.call(loo::loo_compare,objs)
      tab<-data.frame(model=rownames(cmp),cmp,row.names=NULL,check.names=FALSE)
      if(isTRUE(weights)) {
        weight_values <- loo::loo_model_weights(objs, method="stacking")
        weight_type <- "LOO stacking weights"
        tab$stacking_weight <- as.numeric(weight_values[match(tab$model,names(weight_values))])
      }
    } else {
      tab<-data.frame(
        model=nm,
        elpd_waic=vapply(objs,function(z)z$estimates["elpd_waic","Estimate"],numeric(1)),
        se=vapply(objs,function(z)z$estimates["elpd_waic","SE"],numeric(1)),
        p_waic=vapply(objs,function(z)z$estimates["p_waic","Estimate"],numeric(1)),
        stringsAsFactors=FALSE
      )
      if(isTRUE(weights)) weight_type <- "not computed for WAIC; use criterion='loo' for predictive stacking weights"
    }
    native<-objs
  } else {
    if(length(models)!=1L || models[[1]]$backend!="RoBMA") .apm_abort("criterion='model_probability' expects one RoBMA model-averaging object.")
    .apm_require("RoBMA","posterior model probabilities")
    sm<-tryCatch(RoBMA::summary_models(models[[1]]$backend_fit,type="individual",include_mcmc_diagnostics=TRUE),error=function(e)e)
    if(inherits(sm,"error")) .apm_abort("Could not obtain RoBMA model probabilities: {conditionMessage(sm)}")
    native<-sm
    tab <- if(is.data.frame(sm$individual %||% NULL)) as.data.frame(sm$individual) else data.frame(model="RoBMA ensemble",criterion="posterior model probabilities",value=NA_real_)
    weight_type <- "RoBMA posterior model probabilities"
  }
  out<-list(
    criterion=criterion,table=tab,native=native,weights_requested=weights,
    weights=weight_values,weight_type=weight_type,models=nm,measure=measures[[1]],data_hash=hashes[[1]],
    caution="Posterior model probabilities, LOO stacking weights, LOO differences, and WAIC answer different questions. They are reported separately and are not interpreted as p-values."
  )
  class(out)<-"apm_bayes_comparison";out
}
