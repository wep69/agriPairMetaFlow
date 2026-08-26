# Bayesian agronomic relevance thresholds --------------------------------

.apm_prob_from_draws <- function(z, threshold, direction, rope=NULL) {
  p <- if(direction=="greater") mean(z>threshold) else if(direction=="less") mean(z<threshold) else mean(abs(z)>abs(threshold))
  pr <- if(is.null(rope)) NA_real_ else mean(z>=min(rope)&z<=max(rope))
  c(probability=p,rope_probability=pr)
}

#' Bayesian probability relative to an agronomic relevance threshold
#' @param model An `apm_bayes` model.
#' @param threshold User-defined threshold.
#' @param scale Threshold scale.
#' @param direction Probability direction.
#' @param predictive Use a predictive rather than pooled-effect distribution.
#' @param rope Optional two-element region of practical equivalence on the same declared scale.
#' @return An `apm_bayes_threshold` object. No automatic accept/reject rule is applied.
#' @export
#' @examples
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t1 <- apm_bayes_threshold(b,threshold=5,scale="percent") }
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t2 <- apm_bayes_threshold(b,threshold=10,scale="percent",predictive=TRUE) }
#' if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t3 <- apm_bayes_threshold(b,threshold=0,scale="model",direction="less",rope=c(-.05,.05)) }
apm_bayes_threshold <- function(model, threshold, scale = c("model", "ratio", "percent", "absolute"),
                                direction = c("greater", "less", "two-sided"), predictive = FALSE, rope = NULL) {
  if(!inherits(model,"apm_bayes")) .apm_abort("{.arg model} must be an apm_bayes object.")
  scale<-match.arg(scale);direction<-match.arg(direction)
  if(!is.numeric(threshold)||length(threshold)!=1L||!is.finite(threshold)) .apm_abort("{.arg threshold} must be one finite numeric value.")
  thr <- .apm_threshold_to_model(threshold,model$measure,scale)
  rope_m <- if(is.null(rope))NULL else { if(!is.numeric(rope)||length(rope)!=2L||any(!is.finite(rope))) .apm_abort("{.arg rope} must contain two finite values."); sort(.apm_threshold_to_model(rope,model$measure,scale)) }
  fit<-model$backend_fit; p<-NA_real_; pr<-NA_real_; basis<-NULL
  if(model$backend=="bayesmeta" && !inherits(fit,"bmr")) {
    cdf <- tryCatch(if(predictive) fit$pposterior(theta=thr,predict=TRUE) else fit$pposterior(mu=thr),error=function(e)NA_real_)
    if(is.finite(cdf)) {
      if(direction=="greater") p <- 1-cdf
      else if(direction=="less") p <- cdf
      else {
        a <- abs(thr)
        plo <- tryCatch(if(predictive) fit$pposterior(theta=-a,predict=TRUE) else fit$pposterior(mu=-a),error=function(e)NA_real_)
        phi <- tryCatch(if(predictive) fit$pposterior(theta=a,predict=TRUE) else fit$pposterior(mu=a),error=function(e)NA_real_)
        if(all(is.finite(c(plo,phi)))) p <- plo + (1-phi)
      }
    }
    if(!is.null(rope_m)) { a<-tryCatch(if(predictive)fit$pposterior(theta=rope_m[1],predict=TRUE) else fit$pposterior(mu=rope_m[1]),error=function(e)NA_real_); b<-tryCatch(if(predictive)fit$pposterior(theta=rope_m[2],predict=TRUE) else fit$pposterior(mu=rope_m[2]),error=function(e)NA_real_); if(all(is.finite(c(a,b))))pr<-b-a }
    basis <- "bayesmeta analytic posterior CDF"
  } else if(model$backend=="bayesmeta" && inherits(fit,"bmr")) {
    xbar <- matrix(colMeans(model$X),nrow=1); cdf<-tryCatch(fit$ppredict(thr,x=xbar,mean=!predictive),error=function(e)NA_real_)
    if(is.finite(cdf)) {
      if(direction=="greater") p<-1-cdf
      else if(direction=="less") p<-cdf
      else {
        a0 <- abs(thr)
        plo <- tryCatch(fit$ppredict(-a0,x=xbar,mean=!predictive),error=function(e)NA_real_)
        phi <- tryCatch(fit$ppredict(a0,x=xbar,mean=!predictive),error=function(e)NA_real_)
        if(all(is.finite(c(plo,phi)))) p <- plo + (1-phi)
      }
    }
    if(!is.null(rope_m)){a<-fit$ppredict(rope_m[1],x=xbar,mean=!predictive);b<-fit$ppredict(rope_m[2],x=xbar,mean=!predictive);pr<-b-a}
    basis <- "bayesmeta bmr distribution at mean observed moderator context"
  } else {
    pred <- apm_bayes_predict(model,predictive=predictive,transform="none")
    z <- if(!is.null(pred$draws)) as.numeric(pred$draws) else numeric()
    if(!length(z)) .apm_abort("Posterior draws are required for this backend threshold calculation.")
    pp <- .apm_prob_from_draws(z,thr,direction,rope_m);p<-pp[[1]];pr<-pp[[2]];basis<-pred$target
  }
  out<-list(threshold=threshold,threshold_model=thr,scale=scale,direction=direction,predictive=predictive,probability=p,rope=rope,rope_model=rope_m,rope_probability=pr,basis=basis,
            interpretation="Probability is reported descriptively relative to a user-defined agronomic threshold; agriPairMetaFlow does not convert it into an automatic accept/reject decision.")
  class(out)<-"apm_bayes_threshold";out
}
