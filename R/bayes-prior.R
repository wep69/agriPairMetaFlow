# Backend-neutral Bayesian priors ------------------------------------------

.apm_prior_validate_component <- function(x, role) {
  if (is.null(x)) return(NULL)
  if (!is.list(x) || is.null(x$dist) || length(x$dist) != 1L) .apm_abort("Prior component {.val {role}} must be a list containing {.field dist}.")
  d <- tolower(x$dist)
  allowed <- if (role == "tau") c("halfnormal","halft","halfcauchy","exponential","uniform") else c("normal","student_t","cauchy")
  if (!d %in% allowed) .apm_abort("Unsupported {role} prior distribution: {.val {d}}.")
  if (d == "normal" && (!is.finite(x$mean %||% NA_real_) || !is.finite(x$sd %||% NA_real_) || x$sd <= 0)) .apm_abort("Normal priors require finite mean and positive sd.")
  if (d %in% c("student_t","cauchy") && (!is.finite(x$location %||% x$mean %||% 0) || !is.finite(x$scale %||% NA_real_) || x$scale <= 0)) .apm_abort("Student-t/Cauchy priors require a positive scale.")
  if (d == "student_t" && (!is.finite(x$df %||% NA_real_) || x$df <= 0)) .apm_abort("Student-t priors require df > 0.")
  if (d %in% c("halfnormal","halft","halfcauchy") && (!is.finite(x$scale %||% NA_real_) || x$scale <= 0)) .apm_abort("Half-distribution priors require a positive scale.")
  if (d == "halft" && (!is.finite(x$df %||% NA_real_) || x$df <= 0)) .apm_abort("Half-t priors require df > 0.")
  if (d == "exponential" && (!is.finite(x$rate %||% NA_real_) || x$rate <= 0)) .apm_abort("Exponential priors require rate > 0.")
  if (d == "uniform" && (!is.finite(x$min %||% NA_real_) || !is.finite(x$max %||% NA_real_) || x$min < 0 || x$max <= x$min)) .apm_abort("Uniform tau priors require 0 <= min < max.")
  x$dist <- d; x
}

#' Create an inspectable Bayesian prior specification
#' @param effect Prior for the pooled/intercept effect.
#' @param tau Prior for heterogeneity.
#' @param moderators Named list of priors for moderator coefficients.
#' @param model_probability Optional prior model probabilities for model averaging.
#' @param scale Prior scale, either model or natural.
#' @param family Optional response family metadata.
#' @param notes Free-text scientific rationale.
#' @return An object of class `apm_prior`.
#' @export
#' @examples
#' p1 <- apm_prior(effect=list(dist="normal", mean=0, sd=.2), tau=list(dist="halfnormal", scale=.2))
#' p2 <- apm_prior(effect=list(dist="normal", mean=0, sd=.1), moderators=list(rainfall=list(dist="normal", mean=0, sd=.05)))
#' p3 <- apm_prior(effect=list(dist="normal", mean=0, sd=.3), model_probability=list(effect=.5, heterogeneity=.5), notes="weakly informative lnRR prior")
apm_prior <- function(effect = NULL, tau = NULL, moderators = NULL, model_probability = NULL,
                      scale = c("model", "natural"), family = NULL, notes = NULL) {
  scale <- match.arg(scale)
  effect <- effect %||% list(dist="normal", mean=0, sd=1)
  tau <- tau %||% list(dist="halfnormal", scale=.5)
  effect <- .apm_prior_validate_component(effect, "effect")
  tau <- .apm_prior_validate_component(tau, "tau")
  if (!is.null(moderators)) {
    if (!is.list(moderators) || is.null(names(moderators)) || any(!nzchar(names(moderators)))) .apm_abort("{.arg moderators} must be a named list of prior components.")
    moderators <- lapply(moderators, .apm_prior_validate_component, role="moderator")
  }
  if (!is.null(model_probability)) {
    vals <- unlist(model_probability, use.names=TRUE)
    if (!is.numeric(vals) || any(!is.finite(vals)) || any(vals < 0 | vals > 1)) .apm_abort("Model probabilities must be finite values in [0,1].")
  }
  out <- list(effect=effect, tau=tau, moderators=moderators, model_probability=model_probability,
              scale=scale, family=family, notes=notes,
              rationale=list(default_effect=is.null(match.call()$effect), default_tau=is.null(match.call()$tau)))
  class(out) <- "apm_prior"
  out
}

.apm_draw_prior_component <- function(spec, n) {
  d <- spec$dist
  if (d == "normal") return(stats::rnorm(n, spec$mean, spec$sd))
  if (d == "student_t") return((spec$location %||% spec$mean %||% 0) + spec$scale * stats::rt(n, spec$df))
  if (d == "cauchy") return(stats::rcauchy(n, spec$location %||% spec$mean %||% 0, spec$scale))
  if (d == "halfnormal") return(abs(stats::rnorm(n, 0, spec$scale)))
  if (d == "halft") return(abs(spec$scale * stats::rt(n, spec$df)))
  if (d == "halfcauchy") return(abs(stats::rcauchy(n, 0, spec$scale)))
  if (d == "exponential") return(stats::rexp(n, spec$rate))
  if (d == "uniform") return(stats::runif(n, spec$min, spec$max))
  .apm_abort("Unsupported prior distribution {.val {d}}.")
}

.apm_tau_density <- function(spec) {
  force(spec)
  function(x) {
    d <- spec$dist
    ifelse(x < 0, 0,
      if (d == "halfnormal") 2*stats::dnorm(x, 0, spec$scale) else
      if (d == "halft") 2*stats::dt(x/spec$scale, df=spec$df)/spec$scale else
      if (d == "halfcauchy") 2*stats::dcauchy(x,0,spec$scale) else
      if (d == "exponential") stats::dexp(x,spec$rate) else
      if (d == "uniform") stats::dunif(x,spec$min,spec$max) else NA_real_)
  }
}

.apm_to_bayestools_prior <- function(spec, truncate_positive = FALSE) {
  .apm_require("BayesTools", "RoBMA prior translation")
  d <- spec$dist
  if (d == "normal") return(BayesTools::prior("normal", parameters=list(mean=spec$mean, sd=spec$sd)))
  if (d == "student_t") return(BayesTools::prior("t", parameters=list(location=spec$location %||% spec$mean %||% 0, scale=spec$scale, df=spec$df)))
  if (d == "cauchy") return(BayesTools::prior("cauchy", parameters=list(location=spec$location %||% spec$mean %||% 0, scale=spec$scale)))
  trunc <- list(lower=0, upper=Inf)
  if (d == "halfnormal") return(BayesTools::prior("normal", parameters=list(mean=0,sd=spec$scale), truncation=trunc))
  if (d == "halft") return(BayesTools::prior("t", parameters=list(location=0,scale=spec$scale,df=spec$df), truncation=trunc))
  if (d == "halfcauchy") return(BayesTools::prior("cauchy", parameters=list(location=0,scale=spec$scale), truncation=trunc))
  if (d == "exponential") return(BayesTools::prior("exp", parameters=list(rate=spec$rate), truncation=trunc))
  if (d == "uniform") return(BayesTools::prior("uniform", parameters=list(a=spec$min,b=spec$max), truncation=list(lower=spec$min,upper=spec$max)))
  .apm_abort("Prior distribution {.val {d}} cannot be translated to BayesTools by the current adapter.")
}
