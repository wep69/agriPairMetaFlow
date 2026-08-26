#' Interpret prespecified meta-regression interactions
#'
#' Converts interaction coefficients into simple slopes or adjusted contrasts on
#' scientifically interpretable moderator scales. Simple-effect p-values and
#' joint tests follow the fitted model's t-based versus normal inference mode.
#'
#' @param model An `apm_metareg` model containing the requested interaction.
#' @param term Interaction term, such as `"rainfall:climate_zone"`.
#' @param at Optional named list defining values for continuous moderators.
#' @param contrast `"difference"` on the model scale or `"ratio"` for log-ratio
#'   estimands.
#' @param adjust Multiplicity adjustment from `stats::p.adjust.methods`.
#' @param level Confidence level.
#' @return An `apm_interaction` object with simple effects, contrasts, and an
#'   interaction-specific joint Wald test.
#' @export
#' @examples
#' # Example 1: rainfall slope by climate zone.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irr_i <- apm_metareg(irr_es,~rainfall*climate_zone)
#' apm_interaction(irr_i,"rainfall:climate_zone",at=list(rainfall=c(600,900)))
#' # Example 2: crop by site interaction for inoculant response.
#' bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' bio_i <- apm_metareg(bio_es,~crop*site)
#' apm_interaction(bio_i,"crop:site",adjust="holm")
#' # Example 3: nitrogen slope by soil texture with dependent contrasts.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_V <- apm_vcov(mz_es,cluster=experiment_id)
#' mz_i <- apm_metareg(mz_es,~N_rate*soil_texture,V=mz_V,random=~1|study_id/effect_id)
#' apm_interaction(mz_i,"N_rate:soil_texture",contrast="ratio")
apm_interaction <- function(model, term, at = NULL, contrast = c("difference", "ratio"), adjust = "none", level = 0.95) {
  if (!inherits(model, "apm_metareg")) .apm_abort("{.arg model} must inherit from apm_metareg.")
  contrast <- match.arg(contrast)
  if (!adjust %in% stats::p.adjust.methods) .apm_abort("{.arg adjust} must be one of stats::p.adjust.methods.")
  if (!is.character(term) || length(term) != 1L || !grepl(":", term, fixed=TRUE)) .apm_abort("{.arg term} must identify one fitted interaction, for example 'rainfall:climate_zone'.")
  parts <- strsplit(term, ":", fixed=TRUE)[[1]]
  if (length(parts) != 2L) .apm_abort("Version 0.3.0 interprets two-way interactions only.")
  parts <- trimws(parts)
  f <- model$moderator_info$formula
  tl <- attr(stats::terms(f), "term.labels")
  norm <- function(x) paste(sort(trimws(strsplit(x, ":", fixed=TRUE)[[1]])), collapse=":")
  idx_term <- which(vapply(tl, norm, character(1)) == norm(term))
  if (!length(idx_term)) .apm_abort("Interaction {.val {term}} is not present in the fitted moderator formula.")
  if (contrast == "ratio" && !model$measure %in% .apm_log_measures) .apm_abort("contrast='ratio' requires a log-ratio estimand.")
  if (is.null(at)) at <- list()
  if (!is.list(at)) .apm_abort("{.arg at} must be a named list.")

  source <- model$source_data %||% model$data
  w <- .apm_marginal_weights(source, "equal")
  beta <- as.numeric(stats::coef(model$backend_fit)); Vb <- as.matrix(stats::vcov(model$backend_fit))
  alpha <- 1-level; crit <- .apm_critical_value(model, level)
  xbar <- function(settings=list()) {
    nd <- source
    for (v in names(settings)) nd[[v]] <- settings[[v]]
    X <- .apm_model_matrix_meta(model, nd)$matrix
    z <- as.numeric(colSums(X*w))
    if (length(beta)==length(z)+1L) z <- c(1,z)
    if(length(z)!=length(beta)) .apm_abort("Internal contrast matrix is incompatible with the fitted coefficient vector.")
    z
  }
  lincon <- function(L, label, context="") {
    est <- sum(L*beta); se <- sqrt(drop(t(L)%*%Vb%*%L)); statistic <- est/se
    idf <- .apm_inference_df(model); p <- .apm_two_sided_p(model,statistic)
    lo <- est-crit*se; hi <- est+crit*se
    if(contrast=="ratio") { est<-exp(est); lo<-exp(lo); hi<-exp(hi) }
    data.frame(label=label,context=context,estimate=est,se=se,ci_lower=lo,ci_upper=hi,
      statistic=statistic,df=if(is.finite(idf))idf else NA_real_,distribution=if(is.finite(idf))"t" else "normal",
      p_value=p,stringsAsFactors=FALSE)
  }

  s1 <- model$moderator_info$support[[parts[1]]]; s2 <- model$moderator_info$support[[parts[2]]]
  rows <- list()
  if (identical(s1$type,"numeric") && identical(s2$type,"factor")) {
    num <- parts[1]; fac <- parts[2]
  } else if (identical(s2$type,"numeric") && identical(s1$type,"factor")) {
    num <- parts[2]; fac <- parts[1]
  } else num <- fac <- NULL

  if (!is.null(num)) {
    vals <- at[[num]] %||% mean(c(model$moderator_info$support[[num]]$min, model$moderator_info$support[[num]]$max))
    vals <- as.numeric(vals)
    sup <- model$moderator_info$support[[num]]
    if(any(vals<sup$min|vals>sup$max)) .apm_abort("Requested {.field {num}} values lie outside observed support.")
    h <- max((sup$max-sup$min)*1e-5,1e-8)
    k <- 1L
    for (lev in model$moderator_info$support[[fac]]$levels) for (x0 in vals) {
      hp <- min(h, sup$max-x0); hm <- min(h, x0-sup$min)
      if(hp<=0||hm<=0) .apm_abort("Simple slopes cannot be evaluated exactly at an unsupported boundary; choose an interior value in {.arg at}.")
      L <- (xbar(setNames(list(x0+hp,lev),c(num,fac))) - xbar(setNames(list(x0-hm,lev),c(num,fac))))/(hp+hm)
      rows[[k]] <- lincon(L,paste0("slope_",num," | ",fac,"=",lev),paste0(num,"=",signif(x0,6))); k<-k+1L
    }
  } else if (identical(s1$type,"factor") && identical(s2$type,"factor")) {
    a<-parts[1]; b<-parts[2]; ref<-model$moderator_info$support[[a]]$levels[1]
    k<-1L
    for(bl in model$moderator_info$support[[b]]$levels) for(al in model$moderator_info$support[[a]]$levels[-1]) {
      L<-xbar(setNames(list(al,bl),c(a,b)))-xbar(setNames(list(ref,bl),c(a,b)))
      rows[[k]]<-lincon(L,paste0(a,"=",al," vs ",ref),paste0(b,"=",bl)); k<-k+1L
    }
  } else if (identical(s1$type,"numeric") && identical(s2$type,"numeric")) {
    a<-parts[1]; b<-parts[2]; bsup<-model$moderator_info$support[[b]]; asup<-model$moderator_info$support[[a]]
    bvals<-at[[b]] %||% as.numeric(stats::quantile(source[[b]],c(.25,.5,.75),names=FALSE))
    aval<-at[[a]] %||% mean(c(asup$min,asup$max)); h<-max((asup$max-asup$min)*1e-5,1e-8); k<-1L
    for(b0 in bvals) for(a0 in aval) {
      if(b0<bsup$min||b0>bsup$max||a0<asup$min||a0>asup$max) .apm_abort("Numeric interaction evaluation values must lie within observed support.")
      hp<-min(h,asup$max-a0);hm<-min(h,a0-asup$min)
      if(hp<=0||hm<=0) .apm_abort("Numeric interaction slopes require an interior value for the differentiated moderator.")
      L<-(xbar(setNames(list(a0+hp,b0),c(a,b)))-xbar(setNames(list(a0-hm,b0),c(a,b))))/(hp+hm)
      rows[[k]]<-lincon(L,paste0("slope_",a),paste0(b,"=",signif(b0,6))); k<-k+1L
    }
  } else .apm_abort("Unsupported moderator types for interaction interpretation.")

  tab <- do.call(rbind,rows); tab$p_adjusted <- stats::p.adjust(tab$p_value, method=adjust)
  mm <- stats::model.matrix(f, data=model$data); ass <- attr(mm,"assign"); cols <- which(ass==idx_term)
  if(!length(cols)) joint <- data.frame(statistic=NA_real_,df1=NA_integer_,df2=NA_real_,distribution=NA_character_,p_value=NA_real_)
  else {
    b <- beta[cols]; VV <- Vb[cols,cols,drop=FALSE]
    q <- length(cols); wald <- tryCatch(drop(t(b)%*%solve(VV,b)),error=function(e) NA_real_)
    idf <- .apm_inference_df(model)
    if(is.finite(wald) && is.finite(idf)) {
      stat <- wald/q; pv <- stats::pf(stat,df1=q,df2=idf,lower.tail=FALSE); dist <- "F"
    } else {
      stat <- wald; pv <- if(is.finite(wald))stats::pchisq(wald,df=q,lower.tail=FALSE) else NA_real_; dist <- "chi-square"
    }
    joint <- data.frame(statistic=stat,df1=q,df2=if(is.finite(idf))idf else NA_real_,distribution=dist,p_value=pv)
  }
  out<-list(table=tab,joint_test=joint,term=term,contrast=contrast,adjust=adjust,level=level,model_hash=model$source_data_hash%||%model$data_hash,measure=model$measure)
  class(out)<-"apm_interaction"; out
}
