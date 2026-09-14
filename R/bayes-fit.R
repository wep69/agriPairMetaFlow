# Unified Bayesian meta-analysis -------------------------------------------

.apm_bayes_measure <- function(measure) {
  m <- toupper(measure %||% "GEN")
  if (m %in% c("ROM","VR","CVR","MD","MC","ROMC","VRC","CVRC")) return("GEN")
  if (m %in% c("SMD","ZCOR","RR","OR","HR","RD","IRR","GEN")) return(m)
  "GEN"
}

.apm_bayes_default_prior <- function(measure) {
  if (toupper(measure) %in% c("ROM","VR","CVR","RR","OR","IRR","HR"))
    apm_prior(effect=list(dist="normal",mean=0,sd=.5),tau=list(dist="halfnormal",scale=.3), notes="generic weakly informative log-scale default; inspect with apm_prior_check()")
  else apm_prior(effect=list(dist="normal",mean=0,sd=1),tau=list(dist="halfnormal",scale=.5), notes="generic weakly informative model-scale default; inspect with apm_prior_check()")
}

.apm_bayesmeta_beta_prior <- function(prior, X) {
  p <- ncol(X); mn <- rep(0,p); sd <- rep(1,p)
  if (!is.null(prior$effect)) { if(prior$effect$dist!="normal") .apm_abort("bayesmeta requires normal coefficient priors in the current adapter."); mn[1]<-prior$effect$mean; sd[1]<-prior$effect$sd }
  if (p>1 && !is.null(prior$moderators)) {
    for(j in 2:p) {
      nm <- colnames(X)[j]; sp <- prior$moderators[[nm]] %||% prior$moderators[[sub("^.*:","",nm)]] %||% NULL
      if(!is.null(sp)) { if(sp$dist!="normal") .apm_abort("bayesmeta moderator priors must be normal in the current adapter."); mn[j]<-sp$mean; sd[j]<-sp$sd }
    }
  }
  list(mean=mn,sd=sd)
}

.apm_standardize_bayesmeta <- function(fit) {
  sm <- fit$summary
  if (is.null(sm)) return(data.frame())
  pars <- colnames(sm); keep <- setdiff(pars,"tau")
  out <- lapply(keep,function(p) data.frame(term=p, estimate=sm["mean",p], median=sm["median",p], sd=sm["sd",p], lower=sm["95% lower",p], upper=sm["95% upper",p], stringsAsFactors=FALSE))
  if(!length(out)) data.frame() else do.call(rbind,out)
}

.apm_brms_prior <- function(prior, X) {
  .apm_require("brms","brms prior translation")
  e <- prior$effect; t <- prior$tau
  if(e$dist!="normal") .apm_abort("The brms adapter currently translates normal effect priors only.")
  pp <- brms::set_prior(sprintf("normal(%s,%s)",e$mean,e$sd),class="Intercept")
  if (ncol(X) > 1L) {
    specs <- prior$moderators
    if (is.null(specs)) {
      pp <- c(pp, brms::set_prior("normal(0,1)", class="b"))
    } else {
      if (any(vapply(specs, function(z) z$dist != "normal", logical(1))))
        .apm_abort("The brms adapter currently translates normal moderator priors only.")
      sig <- vapply(specs, function(z) paste(z$mean,z$sd,sep="/"), character(1))
      if (length(unique(sig)) != 1L)
        .apm_abort("The brms adapter requires a common normal prior for all moderator coefficients. Use the backend object directly for coefficient-specific brms priors.")
      z <- specs[[1L]]
      pp <- c(pp, brms::set_prior(sprintf("normal(%s,%s)",z$mean,z$sd), class="b"))
    }
  }
  if(t$dist=="halfnormal") pp <- c(pp,brms::set_prior(sprintf("normal(0,%s)",t$scale),class="sd",lb=0))
  else .apm_abort("The brms adapter currently translates half-normal heterogeneity priors only.")
  pp
}

#' Unified Bayesian treatment-versus-control meta-analysis
#' @param effects Effect-size data with `yi` and `vi`.
#' @param mods One-sided moderator formula.
#' @param cluster Optional cluster identifier for multilevel models.
#' @param prior An `apm_prior` specification.
#' @param backend Bayesian backend.
#' @param bias_adjust Whether publication-bias adjustment/model averaging is requested.
#' @param chains Number of MCMC chains where applicable.
#' @param iter Total iterations or approximate total MCMC iterations.
#' @param warmup Warmup/burn-in iterations.
#' @param seed Reproducibility seed.
#' @param ... Additional backend arguments.
#' @return An object of class `apm_bayes`.
#' @export
#' @examples
#' if (requireNamespace("bayesmeta",quietly=TRUE)) b1 <- apm_bayes(agri_effects_benchmark, backend="bayesmeta", prior=apm_prior(effect=list(dist="normal",mean=0,sd=.2)))
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); b2 <- apm_bayes(es,mods=~rainfall,backend="bayesmeta",seed=1) }
#' if (requireNamespace("RoBMA",quietly=TRUE) && requireNamespace("BayesTools",quietly=TRUE)) { es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); b3 <- apm_bayes(es,cluster=study_id,mods=~N_rate,backend="RoBMA",seed=1) }
apm_bayes <- function(effects, mods = ~ 1, cluster = NULL, prior = NULL,
                      backend = c("auto", "bayesmeta", "RoBMA", "brms"), bias_adjust = FALSE,
                      chains = 4, iter = 4000, warmup = 1000, seed = NULL, ...) {
  backend <- match.arg(backend)
  dat <- .apm_df(effects)
  if(!all(c("yi","vi") %in% names(dat))) .apm_abort("Bayesian fitting requires {.field yi} and {.field vi}.")
  if(any(!is.finite(dat$yi))||any(!is.finite(dat$vi))||any(dat$vi<=0)) .apm_abort("{.field yi} must be finite and {.field vi} finite and positive.")
  if(!inherits(mods,"formula")||length(mods)!=2L) .apm_abort("{.arg mods} must be a one-sided formula.")
  qc <- rlang::enquo(cluster); cl <- if(rlang::quo_is_null(qc)) NULL else .apm_pull_quo(dat,qc,"cluster",TRUE)
  measure <- attr(effects,"measure") %||% if("measure"%in%names(dat) && length(unique(dat$measure))==1L) unique(dat$measure) else "GEN"
  prior <- prior %||% .apm_bayes_default_prior(measure)
  if(!inherits(prior,"apm_prior")) .apm_abort("{.arg prior} must be NULL or an apm_prior object.")
  if(prior$scale!="model") .apm_abort("Bayesian backend translation currently requires priors specified on the model scale; use apm_prior_check() to inspect natural-scale implications.")
  if(!is.null(prior$model_probability)) .apm_abort("Prior model probabilities are stored for audit but are not translated automatically by apm_bayes(). Use backend-specific model-probability arguments explicitly through {{...}} after verifying their meaning.")
  if(backend=="auto") {
    if(isTRUE(bias_adjust)||!is.null(cl)) backend <- if(requireNamespace("RoBMA",quietly=TRUE)) "RoBMA" else if(requireNamespace("brms",quietly=TRUE)) "brms" else "bayesmeta"
    else backend <- if(requireNamespace("bayesmeta",quietly=TRUE)) "bayesmeta" else if(requireNamespace("RoBMA",quietly=TRUE)) "RoBMA" else "brms"
  }
  X <- stats::model.matrix(mods,dat)
  posterior_summary <- data.frame(); draws <- NULL; backend_fit <- NULL; backend_detail <- backend

  if(backend=="bayesmeta") {
    .apm_require("bayesmeta","Bayesian normal-normal meta-analysis")
    if(!is.null(cl)) .apm_abort("The bayesmeta backend does not represent multilevel cluster dependence; choose backend='RoBMA' or 'brms'.")
    if(isTRUE(bias_adjust)) .apm_abort("Publication-bias adjustment is not provided by the bayesmeta adapter; choose backend='RoBMA'.")
    tp <- .apm_tau_density(prior$tau); bp <- .apm_bayesmeta_beta_prior(prior,X)
    if(ncol(X)==1L && all(X[,1]==1)) {
      backend_fit <- bayesmeta::bayesmeta(y=dat$yi,sigma=sqrt(dat$vi),mu.prior.mean=bp$mean[1],mu.prior.sd=bp$sd[1],tau.prior=tp,...)
      backend_detail <- "bayesmeta"
    } else {
      backend_fit <- bayesmeta::bmr(y=dat$yi,sigma=sqrt(dat$vi),X=X,beta.prior.mean=bp$mean,beta.prior.sd=bp$sd,tau.prior=tp,...)
      backend_detail <- "bayesmeta-bmr"
    }
    posterior_summary <- .apm_standardize_bayesmeta(backend_fit)
  } else if(backend=="RoBMA") {
    .apm_require("RoBMA","Robust Bayesian meta-analysis"); .apm_require("BayesTools","RoBMA prior translation")
    pe <- .apm_to_bayestools_prior(prior$effect); pt <- .apm_to_bayestools_prior(prior$tau)
    pm <- if(is.null(prior$moderators)) NULL else lapply(prior$moderators,.apm_to_bayestools_prior)
    args <- list(yi=dat$yi,vi=dat$vi,mods=mods,data=dat,measure=.apm_bayes_measure(measure),prior_effect=pe,prior_heterogeneity=pt,standardize_continuous_predictors=FALSE,
                 sample=max(500L,as.integer(iter-warmup)),burnin=as.integer(warmup),chains=as.integer(chains),seed=seed,silent=TRUE)
    if(!is.null(pm)) args$prior_mods <- pm
    if(!is.null(cl)) args$cluster <- cl
    fun <- if(isTRUE(bias_adjust)) RoBMA::RoBMA else RoBMA::brma
    backend_fit <- rlang::exec(fun, !!!args, ...)
    posterior_summary <- tryCatch({ cc<-stats::coef(backend_fit); data.frame(term=names(cc),estimate=as.numeric(cc),median=NA_real_,sd=NA_real_,lower=NA_real_,upper=NA_real_) },error=function(e)data.frame())
    backend_detail <- if(isTRUE(bias_adjust)) "RoBMA-model-averaged" else "RoBMA-brma"
  } else {
    .apm_require("brms","Bayesian multilevel meta-analysis")
    dat$.apm_se <- sqrt(dat$vi); dat$.apm_row <- factor(seq_len(nrow(dat)))
    if(!is.null(cl)) dat$.apm_cluster <- factor(cl)
    rhs <- paste(deparse(mods[[2L]],width.cutoff=500L),collapse=" ")
    random_term <- if(is.null(cl)) "(1 | .apm_row)" else "(1 | .apm_cluster) + (1 | .apm_row)"
    fm <- stats::as.formula(paste("yi | se(.apm_se) ~",rhs,"+",random_term))
    backend_fit <- brms::brm(fm,data=dat,prior=.apm_brms_prior(prior,X),chains=chains,iter=iter,warmup=warmup,seed=seed,...)
    draws <- tryCatch(as.data.frame(backend_fit),error=function(e)NULL)
    if(!is.null(draws)) {
      keep <- grep("^b_",names(draws),value=TRUE)
      posterior_summary <- do.call(rbind,lapply(keep,function(nm){z<-draws[[nm]];data.frame(term=nm,estimate=mean(z),median=stats::median(z),sd=stats::sd(z),lower=stats::quantile(z,.025),upper=stats::quantile(z,.975))}))
    }
    backend_detail <- "brms"
  }

  out <- list(backend_fit=backend_fit,backend=backend,backend_detail=backend_detail,backend_version=.apm_backend_version(if(backend=="RoBMA")"RoBMA" else backend),
              data=dat,mods=mods,X=X,cluster=cl,measure=measure,prior=prior,posterior_summary=posterior_summary,posterior_draws=draws,
              settings=list(bias_adjust=bias_adjust,chains=chains,iter=iter,warmup=warmup,seed=seed),data_hash=.apm_hash_data(dat),call=match.call(),convergence_checked=FALSE)
  class(out) <- "apm_bayes"; out
}
