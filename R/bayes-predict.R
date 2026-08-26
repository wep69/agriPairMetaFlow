# Bayesian prediction ------------------------------------------------------

.apm_bayes_transform <- function(x, measure, transform) {
  if(transform=="auto") transform <- if(toupper(measure)%in%c("ROM","VR","CVR","RR","OR","HR","IRR")) "exp" else "none"
  .apm_transform_vector(x, measure, transform)
}

#' Posterior and predictive distributions from Bayesian meta-analysis
#' @param model An `apm_bayes` model.
#' @param newdata Optional moderator context.
#' @param probs Posterior probabilities defining reported quantiles.
#' @param predictive If `TRUE`, target a new-study/observation predictive distribution where the backend supports it.
#' @param transform Output transformation.
#' @return An `apm_bayes_prediction` object.
#' @export
#' @examples
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); p1 <- apm_bayes_predict(b,transform="percent") }
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); b <- apm_bayes(es,mods=~rainfall,backend="bayesmeta"); p2 <- apm_bayes_predict(b,newdata=data.frame(rainfall=c(700,1000)),transform="percent") }
#' if (requireNamespace("RoBMA",quietly=TRUE) && requireNamespace("BayesTools",quietly=TRUE)) { es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); b <- apm_bayes(es,mods=~N_rate,backend="RoBMA",seed=1); p3 <- apm_bayes_predict(b,newdata=data.frame(N_rate=120),predictive=TRUE) }
apm_bayes_predict <- function(model, newdata = NULL, probs = c(0.025, 0.5, 0.975), predictive = TRUE,
                              transform = c("auto", "none", "exp", "percent")) {
  if(!inherits(model,"apm_bayes")) .apm_abort("{.arg model} must be an apm_bayes object.")
  transform <- match.arg(transform)
  if(!is.numeric(probs)||any(probs<=0|probs>=1)||is.unsorted(probs)) .apm_abort("{.arg probs} must be increasing probabilities strictly inside (0,1).")
  fit <- model$backend_fit; raw <- NULL; draws <- NULL; target <- if(predictive)"predictive" else "mean-effect"
  if(model$backend=="bayesmeta") {
    if(inherits(fit,"bmr")) {
      nd <- if(is.null(newdata)) model$data else as.data.frame(newdata)
      Xn <- stats::model.matrix(model$mods,nd)
      if(ncol(Xn)!=ncol(model$X)) .apm_abort("{.arg newdata} produces a model matrix incompatible with the fitted Bayesian meta-regression.")
      qmat <- sapply(probs,function(p) fit$qpredict(p, x = Xn, mean = !predictive))
      if(is.null(dim(qmat))) qmat <- matrix(qmat,nrow=nrow(Xn))
      raw <- data.frame(context=seq_len(nrow(Xn)),qmat,check.names=FALSE); names(raw)[-1] <- paste0("q",probs)
    } else {
      if(!is.null(newdata)) .apm_abort("{.arg newdata} is not applicable to an intercept-only bayesmeta model.")
      vals <- vapply(probs,function(p) tryCatch(if(predictive) fit$qposterior(theta.p = p, predict = TRUE) else fit$qposterior(mu.p = p),error=function(e)NA_real_),numeric(1))
      if(any(!is.finite(vals))) {
        col <- if(predictive) "theta" else "mu"; sm<-fit$summary
        vals <- c(sm["95% lower",col],sm["median",col],sm["95% upper",col])[seq_along(probs)]
      }
      raw <- data.frame(context=1,t(vals),check.names=FALSE); names(raw)[-1] <- paste0("q",probs)
    }
  } else if(model$backend=="RoBMA") {
    # RoBMA >= 4.0.0 distinguishes fixed-effect means (terms), latent true
    # effects for new data (estimate), and observed future effect estimates
    # including sampling error (response). agriPairMetaFlow uses estimate for
    # a new-study predictive distribution, matching the meta-analytic PI target.
    ptype <- if (isTRUE(predictive)) "estimate" else "terms"
    nd <- if (is.null(newdata)) TRUE else newdata
    pr <- stats::predict(
      fit, newdata = nd, type = ptype, probs = range(probs),
      bias_adjusted = isTRUE(model$settings$bias_adjust), quiet = TRUE
    )
    draws <- tryCatch(as.matrix(pr),error=function(e)NULL)
    if(is.null(draws)) .apm_abort("Could not extract posterior samples from the RoBMA prediction object; inspect the backend object during local validation.")
    qq <- apply(draws,2,stats::quantile,probs=probs)
    if(is.vector(qq)) qq <- matrix(qq,ncol=1)
    raw <- data.frame(context=seq_len(ncol(qq)),t(qq),check.names=FALSE); names(raw)[-1] <- paste0("q",probs)
    target <- if(predictive) "RoBMA latent true-effect prediction for a new estimate" else "RoBMA mean-effect terms"
  } else {
    # Keep the Bayesian estimand aligned across backends. In a meta-analysis,
    # predictive=TRUE targets the latent true effect for a new study/context,
    # not a future noisy observed estimate. For brms this is obtained from
    # posterior_epred() while sampling genuinely new random-effect levels.
    nd <- if(is.null(newdata)) model$data else as.data.frame(newdata)
    if(!".apm_se" %in% names(nd)) nd$.apm_se <- stats::median(model$data$.apm_se, na.rm = TRUE)
    if (isTRUE(predictive)) {
      nnd <- nrow(nd)
      row_new <- paste0(".apm_new_row_", seq_len(nnd))
      nd$.apm_row <- factor(row_new, levels = c(levels(model$data$.apm_row), row_new))
      if(!is.null(model$cluster)) {
        cl_new <- paste0(".apm_new_cluster_", seq_len(nnd))
        nd$.apm_cluster <- factor(cl_new, levels = c(levels(model$data$.apm_cluster), cl_new))
      }
      draws <- brms::posterior_epred(
        fit, newdata = nd, re_formula = NULL,
        allow_new_levels = TRUE, sample_new_levels = "gaussian"
      )
      target <- "brms latent true-effect prediction for a new study/context"
    } else {
      draws <- brms::posterior_epred(
        fit, newdata = nd, re_formula = NA,
        allow_new_levels = TRUE
      )
      target <- "brms population-level mean effect"
    }
    qq <- apply(draws,2,stats::quantile,probs=probs)
    raw <- data.frame(context=seq_len(ncol(qq)),t(qq),check.names=FALSE); names(raw)[-1] <- paste0("q",probs)
  }
  tab <- raw
  for(nm in names(tab)[-1]) tab[[nm]] <- .apm_bayes_transform(tab[[nm]],model$measure,transform)
  out <- list(table=tab,raw=raw,draws=draws,newdata=newdata,probs=probs,predictive=predictive,target=target,transform=transform,measure=model$measure,model_hash=model$data_hash)
  class(out) <- "apm_bayes_prediction"; out
}
