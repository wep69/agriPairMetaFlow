# Bayesian meta-analysis, prediction, and agronomic relevance

## Bayesian synthesis is an estimand choice, not a decoration

The Bayesian workflow in `agriPairMetaFlow` is designed to make priors,
posterior targets, prediction, and computational diagnostics explicit.
It does not define a treatment as useful merely because a posterior
probability crosses a package-defined cutoff.

The 0.4.0 layer supports three complementary backends. `bayesmeta`
provides deterministic numerical integration for normal-normal
meta-analysis and meta-regression. `RoBMA` provides JAGS-based Bayesian
models and model averaging, including publication-bias components.
`brms` provides a flexible Stan-based route for multilevel structures.
Heavy Bayesian packages remain optional dependencies.

## 1. Declare priors before fitting

A prior is an inspectable object.

``` r

p1 <- apm_prior(
  effect = list(dist="normal", mean=0, sd=.20),
  tau = list(dist="halfnormal", scale=.20),
  notes = "Weakly informative prior on the log response-ratio scale"
)
p1
#> <apm_prior> scale=model
#> effect: normal  | tau: halfnormal
```

A moderator prior can be declared separately.

``` r

p2 <- apm_prior(
  effect = list(dist="normal", mean=0, sd=.20),
  tau = list(dist="halfnormal", scale=.15),
  moderators = list(rainfall=list(dist="normal", mean=0, sd=.001))
)
```

Model-probability declarations are stored rather than silently
renormalized.

``` r

p3 <- apm_prior(
  effect=list(dist="normal", mean=0, sd=.30),
  model_probability=list(effect=.5, heterogeneity=.5)
)
```

## 2. Inspect implications before seeing the posterior

For lnRR, a Normal prior centered at zero can be translated to ratio and
percentage scales.

``` r

pc1 <- apm_prior_check(p1, measure="lnRR", thresholds=log(c(.90,1.10)), draws=5000, seed=101)
pc1
#> <apm_prior_check> draws=5000 | measure=lnRR
#>    parameter        mean        sd         q025       median      q975
#>       effect 0.002617327 0.1991453 -0.387067727 -0.002915744 0.3890525
#>          tau 0.158052015 0.1194595  0.005680086  0.134514626 0.4528874
#>  true_effect 0.002321572 0.2799359 -0.537545749 -0.006885088 0.5644096
#> Threshold implications:
#>    threshold prob_greater prob_less prob_predictive_greater
#>  -0.10536052       0.7076    0.2924                  0.6584
#>   0.09531018       0.3180    0.6820                  0.3608
#>  prob_predictive_less
#>                0.3416
#>                0.6392
```

For a quantitative moderator, plausible values can be supplied before
model fitting.

``` r

pc2 <- apm_prior_check(
  p2,
  measure="lnRR",
  x=data.frame(rainfall=c(600,900,1200)),
  draws=5000,
  seed=101,
  plot=FALSE
)
```

The same operation is meaningful for variability ratios.

``` r

pc3 <- apm_prior_check(
  apm_prior(effect=list(dist="normal",mean=0,sd=.20)),
  measure="CVR",
  draws=5000,
  seed=101,
  plot=FALSE
)
```

## 3. Fit the normal-normal model

The examples below use optional Bayesian backends and are intentionally
not evaluated in lightweight vignette builds. They are mandatory during
the package’s local validation protocol.

``` r

b1 <- apm_bayes(
  agri_effects_benchmark,
  prior=p1,
  backend="bayesmeta"
)
b1
```

A Bayesian meta-regression uses
[`bayesmeta::bmr()`](https://rdrr.io/pkg/bayesmeta/man/bmr.html) through
the same API.

``` r

es_irrig <- apm_effect_size(
  irrigation_climate, "lnRR",
  m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c
)
es_irrig$rainfall <- irrigation_climate$rainfall
b2 <- apm_bayes(es_irrig, mods=~rainfall, prior=p2, backend="bayesmeta")
```

A robust/model-averaged backend can be requested explicitly when
installed.

``` r

b3 <- apm_bayes(
  agri_effects_benchmark,
  backend="RoBMA",
  bias_adjust=TRUE,
  seed=2026
)
```

## 4. Distinguish mean effects from prediction

Posterior uncertainty in the pooled mean is not the same as uncertainty
in the true effect of a new study.

``` r

mean_post <- apm_bayes_predict(b1, predictive=FALSE, transform="percent")
new_study <- apm_bayes_predict(b1, predictive=TRUE, transform="percent")
mean_post
new_study
```

For meta-regression, prediction is conditional on a stated agronomic
context.

``` r

pred_rain <- apm_bayes_predict(
  b2,
  newdata=data.frame(rainfall=c(700,900,1100)),
  predictive=TRUE,
  transform="percent"
)
```

For `RoBMA`, the package uses the backend’s `type="estimate"` target for
a latent true-effect prediction. `type="response"` would add the future
sampling error and answers a different question.

## 5. Agronomic relevance thresholds

Suppose a researcher defines a 5% yield increase as the smallest benefit
that merits agronomic attention. The probability is then computed
relative to that declared threshold.

``` r

t1 <- apm_bayes_threshold(b1, threshold=5, scale="percent", direction="greater")
t2 <- apm_bayes_threshold(b1, threshold=5, scale="percent", direction="greater", predictive=TRUE)
t3 <- apm_bayes_threshold(b1, threshold=0, scale="model", rope=c(-.05,.05))
```

`t1` concerns the pooled effect. `t2` concerns a new true study effect
and is normally more diffuse. `t3` illustrates a region of practical
equivalence. None of these operations imposes a universal decision
threshold.

## 6. Diagnostics are backend specific

`bayesmeta` uses deterministic DIRECT integration, so MCMC diagnostics
such as R-hat and effective sample size are not defined and must not be
fabricated.

``` r

d1 <- apm_bayes_diagnostics(b1, plot=FALSE)
d2 <- apm_bayes_diagnostics(b2, checks=c("convergence","ppc"), plot=FALSE)
d3 <- apm_bayes_diagnostics(b3, checks=c("convergence","ess","mcse","ppc"), plot=TRUE)
```

For MCMC backends, convergence is a gate to substantive interpretation.
Local validation must inspect R-hat/ESS/MCSE and backend-specific
warnings before results are reported.

## 7. Model comparison

Predictive criteria and posterior model probabilities are different
quantities. They should not be converted into p-values or used to
automate model selection.

``` r

apm_bayes_compare(brms_linear, brms_quadratic, criterion="loo")
apm_bayes_compare(brms_linear, brms_quadratic, criterion="waic")
apm_bayes_compare(robma_ensemble, criterion="model_probability")
```

## 8. Reporting

A Bayesian agronomic meta-analysis should report the effect measure and
natural-scale interpretation, all prior distributions and their
scientific rationale, prior-predictive checks, posterior pooled effects,
prediction for a new true study effect, heterogeneity, agronomic
threshold probabilities only when the threshold is externally justified,
convergence diagnostics, sensitivity to reasonable prior alternatives,
backend/version/seed, and any publication-bias model as a sensitivity
analysis rather than proof that bias exists.
