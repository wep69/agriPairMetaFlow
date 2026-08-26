# Bayesian diagnostics -----------------------------------------------------

.apm_diag_bind_sections <- function(x, sections) {
  out <- list()
  for (nm in sections) {
    z <- x[[nm]] %||% NULL
    if (is.data.frame(z) && nrow(z)) {
      zz <- as.data.frame(z, stringsAsFactors = FALSE)
      zz$section <- nm
      zz$parameter <- rownames(z) %||% seq_len(nrow(z))
      rownames(zz) <- NULL
      out[[length(out) + 1L]] <- zz
    }
  }
  if (!length(out)) return(data.frame())
  # Summary sections can differ in non-diagnostic columns. Keep a union by
  # filling absent columns with NA before row-binding.
  alln <- unique(unlist(lapply(out, names)))
  out <- lapply(out, function(z) {
    miss <- setdiff(alln, names(z)); for (m in miss) z[[m]] <- NA
    z[alln]
  })
  do.call(rbind, out)
}

.apm_diag_numeric <- function(x, candidates) {
  nm <- intersect(candidates, names(x))
  if (!length(nm)) return(numeric())
  suppressWarnings(as.numeric(x[[nm[[1L]]]]))
}

#' Bayesian convergence and posterior predictive diagnostics
#' @param model An `apm_bayes` model.
#' @param checks Requested diagnostic groups.
#' @param plot Whether diagnostic plots should be produced when supported.
#' @return An `apm_bayes_diagnostics` object.
#' @export
#' @examples
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d1 <- apm_bayes_diagnostics(b) }
#' if (requireNamespace("RoBMA",quietly=TRUE) && requireNamespace("BayesTools",quietly=TRUE)) { es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); b <- apm_bayes(es,mods=~N_rate,backend="RoBMA",seed=1); d2 <- apm_bayes_diagnostics(b,checks=c("convergence","ess","mcse")) }
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d3 <- apm_bayes_diagnostics(b,checks="ppc",plot=TRUE) }
apm_bayes_diagnostics <- function(model, checks = c("convergence", "ess", "mcse", "ppc"), plot = TRUE) {
  if(!inherits(model,"apm_bayes")) .apm_abort("{.arg model} must be an apm_bayes object.")
  allowed<-c("convergence","ess","mcse","ppc"); if(any(!checks%in%allowed)) .apm_abort("Unsupported diagnostic requested.")
  fit<-model$backend_fit; tab<-data.frame(); warnings<-character(); ppc<-NULL; plots<-list(); severe<-FALSE; verified<-FALSE; native<-NULL
  if(model$backend=="bayesmeta") {
    support_n <- if(inherits(fit,"bmr")) length(fit$support$tau %||% numeric()) else nrow(fit$support %||% matrix(nrow=0,ncol=0))
    tab<-data.frame(metric=c("computation","tau_prior_proper","support_points"),value=c("deterministic numerical integration",as.character(fit$tau.prior.proper %||% NA),as.character(support_n)),stringsAsFactors=FALSE)
    if("ppc"%in%checks && requireNamespace("bayesmeta",quietly=TRUE)) ppc<-tryCatch(bayesmeta::pppvalue(fit),error=function(e){warnings<<-c(warnings,paste("PPC unavailable:",conditionMessage(e)));NULL})
    warnings<-c(warnings,"R-hat, ESS, and MCSE are not defined for bayesmeta's deterministic DIRECT integration and are therefore not fabricated.")
    verified <- TRUE
  } else if(model$backend=="RoBMA") {
    sm<-tryCatch(summary(fit,include_mcmc_diagnostics=TRUE),error=function(e)e)
    native <- sm
    if(inherits(sm,"error")) {
      warnings<-c(warnings,conditionMessage(sm)); severe<-TRUE
    } else {
      tab <- .apm_diag_bind_sections(sm, c(
        "estimates","estimates_mods","estimates_scale","estimates_bias",
        "estimates_conditional","estimates_mods_conditional",
        "estimates_scale_conditional","estimates_bias_conditional"
      ))
      rhat <- .apm_diag_numeric(tab, c("R_hat","Rhat","rhat"))
      ess  <- .apm_diag_numeric(tab, c("ESS","ess","n_eff"))
      mce  <- .apm_diag_numeric(tab, c("MCMC_error","MCSE","mcse"))
      verified <- length(rhat) > 0L && length(ess) > 0L && any(is.finite(rhat)) && any(is.finite(ess))
      if (!verified) {
        severe <- TRUE
        warnings <- c(warnings,"RoBMA convergence diagnostics could not be extracted from the backend summary; substantive interpretation and model comparison are blocked until local inspection resolves this.")
      } else {
        if (any(rhat > 1.05, na.rm=TRUE)) { severe<-TRUE; warnings<-c(warnings,"At least one RoBMA R-hat exceeds the backend convergence threshold 1.05.") }
        if (any(ess < 500, na.rm=TRUE)) { severe<-TRUE; warnings<-c(warnings,"At least one RoBMA ESS is below the backend convergence threshold 500.") }
        if (any(rhat > 1.01 & rhat <= 1.05, na.rm=TRUE)) warnings<-c(warnings,"At least one RoBMA R-hat exceeds 1.01 although it remains within the backend default 1.05 threshold; inspect mixing before interpretation.")
        if (length(mce) && any(!is.finite(mce))) warnings<-c(warnings,"Some RoBMA MCMC error entries are non-finite; inspect the native summary.")
      }
    }
    if(isTRUE(plot)) plots$backend <- tryCatch(plot(fit),error=function(e)NULL)
  } else {
    .apm_require("posterior","brms diagnostic extraction")
    dr<-posterior::as_draws_df(fit)
    sm<-posterior::summarise_draws(dr,"rhat","ess_bulk","ess_tail","mcse_mean")
    tab<-as.data.frame(sm)
    verified <- nrow(tab) > 0L && "rhat" %in% names(tab) && any(is.finite(tab$rhat))
    if(!verified) { severe<-TRUE; warnings<-c(warnings,"brms convergence diagnostics could not be extracted; interpretation is blocked.") }
    if("rhat"%in%names(tab) && any(tab$rhat>1.01,na.rm=TRUE)) { warnings<-c(warnings,"At least one R-hat exceeds 1.01.");severe<-TRUE }
    if("ess_bulk"%in%names(tab) && any(tab$ess_bulk<100,na.rm=TRUE)) { warnings<-c(warnings,"At least one bulk ESS is below 100."); severe<-TRUE }
    if("ess_tail"%in%names(tab) && any(tab$ess_tail<100,na.rm=TRUE)) { warnings<-c(warnings,"At least one tail ESS is below 100."); severe<-TRUE }
    np <- tryCatch(brms::nuts_params(fit), error=function(e) NULL)
    if(!is.null(np) && all(c("Parameter","Value") %in% names(np))) {
      ndiv <- sum(np$Parameter == "divergent__" & np$Value > 0, na.rm=TRUE)
      if(ndiv > 0L) { severe<-TRUE; warnings<-c(warnings,paste(ndiv,"divergent transition(s) detected.")) }
      tab <- rbind(tab, data.frame(variable="__sampler_divergences__", rhat=NA_real_, ess_bulk=NA_real_, ess_tail=NA_real_, mcse_mean=ndiv, stringsAsFactors=FALSE))
    }
    if(isTRUE(plot) && requireNamespace("bayesplot",quietly=TRUE)) plots$trace<-tryCatch(bayesplot::mcmc_trace(as.array(fit)),error=function(e)NULL)
  }
  out<-list(backend=model$backend,checks=checks,table=tab,ppc=ppc,warnings=unique(warnings),plots=plots,native=native,
            diagnostics_verified=verified,severe_failure=severe,interpretation_allowed=isTRUE(verified)&&!severe,
            note="Runtime diagnostics are a mandatory local-validation gate for MCMC backends.")
  class(out)<-"apm_bayes_diagnostics";out
}
