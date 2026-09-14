# Prior predictive inspection ----------------------------------------------

#' Inspect Bayesian prior implications before model fitting
#' @param prior An `apm_prior` object.
#' @param measure Effect measure.
#' @param x Optional data frame of moderator values.
#' @param thresholds Optional thresholds on the model scale.
#' @param draws Number of prior draws.
#' @param seed Optional random seed.
#' @param plot Whether to create a ggplot object.
#' @return An `apm_prior_check` object.
#' @export
#' @examples
#' pc1 <- apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)), measure="lnRR", thresholds=log(c(.8,1.2)), seed=1)
#' irrig_prior <- apm_prior(effect=list(dist="normal",mean=0,sd=.2), moderators=list(rainfall=list(dist="normal",mean=0,sd=.0002)))
#' pc2 <- apm_prior_check(irrig_prior, measure="lnRR", x=data.frame(rainfall=c(600,1200)), seed=1)
#' pc3 <- apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)), measure="CVR", seed=1)
apm_prior_check <- function(prior, measure, x = NULL, thresholds = NULL, draws = 5000, seed = NULL, plot = TRUE) {
  if (!inherits(prior,"apm_prior")) .apm_abort("{.arg prior} must be created by apm_prior().")
  if (length(measure)!=1L || !is.character(measure)) .apm_abort("{.arg measure} must be one effect-measure label.")
  if (!is.numeric(draws) || length(draws)!=1L || draws < 100) .apm_abort("{.arg draws} must be at least 100.")
  draws <- as.integer(draws)
  gen <- .apm_seeded(seed, function() {
    mu <- .apm_draw_prior_component(prior$effect, draws)
    tau <- .apm_draw_prior_component(prior$tau, draws)
    theta <- stats::rnorm(draws, mean = mu, sd = tau)
    context <- NULL
    context_predictive <- NULL
    if (!is.null(prior$moderators)) {
      if (is.null(x)) .apm_warn("Moderator priors were specified but {.arg x} is NULL; summaries refer to the intercept prior only.")
      else {
        if (!is.data.frame(x)) x <- as.data.frame(x)
        miss <- setdiff(names(prior$moderators), names(x)); if(length(miss)) .apm_abort("{.arg x} is missing moderator columns: {paste(miss,collapse=', ')}")
        context <- vector("list", nrow(x))
        context_predictive <- vector("list", nrow(x))
        beta_draws <- lapply(prior$moderators, .apm_draw_prior_component, n=draws)
        for(i in seq_len(nrow(x))) {
          eta <- mu
          for(nm in names(beta_draws)) {
            if(!is.numeric(x[[nm]])) .apm_abort("Prior checking currently requires numeric moderator values in {.arg x}.")
            eta <- eta + beta_draws[[nm]] * x[[nm]][i]
          }
          context[[i]] <- eta
          context_predictive[[i]] <- stats::rnorm(draws, mean = eta, sd = tau)
        }
      }
    }
    list(mu = mu, tau = tau, theta = theta, context = context, context_predictive = context_predictive)
  })
  mu <- gen$mu; tau <- gen$tau; theta <- gen$theta
  context <- gen$context; context_predictive <- gen$context_predictive
  transformed <- if (measure %in% c("lnRR","ROM","VR","CVR","RR","OR")) {
    data.frame(
      model = mu, ratio = exp(mu), percent = 100*(exp(mu)-1),
      predictive_model = theta, predictive_ratio = exp(theta),
      predictive_percent = 100*(exp(theta)-1)
    )
  } else data.frame(model=mu, predictive_model=theta)
  q_mu <- stats::quantile(mu,c(.025,.5,.975),names=FALSE)
  q_tau <- stats::quantile(tau,c(.025,.5,.975),names=FALSE)
  q_theta <- stats::quantile(theta,c(.025,.5,.975),names=FALSE)
  summary <- data.frame(
    parameter=c("effect","tau","true_effect"),
    mean=c(mean(mu),mean(tau),mean(theta)),
    sd=c(stats::sd(mu),stats::sd(tau),stats::sd(theta)),
    q025=c(q_mu[1],q_tau[1],q_theta[1]),
    median=c(q_mu[2],q_tau[2],q_theta[2]),
    q975=c(q_mu[3],q_tau[3],q_theta[3]),
    row.names=NULL
  )
  tails <- if (is.null(thresholds)) NULL else data.frame(
    threshold=thresholds,
    prob_greater=vapply(thresholds,function(z)mean(mu>z),numeric(1)),
    prob_less=vapply(thresholds,function(z)mean(mu<z),numeric(1)),
    prob_predictive_greater=vapply(thresholds,function(z)mean(theta>z),numeric(1)),
    prob_predictive_less=vapply(thresholds,function(z)mean(theta<z),numeric(1))
  )
  g <- NULL
  if (isTRUE(plot)) {
    dd <- data.frame(value=mu)
    g <- ggplot2::ggplot(dd, ggplot2::aes(x=.data$value)) + ggplot2::geom_density() + ggplot2::labs(x="Prior effect (model scale)", y="Density", title="Prior implication for pooled effect")
  }
  out <- list(
    prior=prior, measure=measure, draws=data.frame(effect=mu,tau=tau,true_effect=theta),
    transformed=transformed, context_draws=context, context_predictive_draws=context_predictive,
    summary=summary, thresholds=tails, seed=seed, plot=g
  )
  class(out) <- "apm_prior_check"; out
}
