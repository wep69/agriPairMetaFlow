# Bayesian pairwise meta-analysis

Fit Bayesian normal-normal, meta-regression, robust model-averaged, or
multilevel models through registered backends.

## Usage

``` r
apm_bayes(...)
```

## Arguments

- ...:

  Arguments documented in the function source. Regenerate this manual
  with roxygen2 during local validation.

## Value

An auditable agriPairMetaFlow result object; see the corresponding class
documentation and vignettes.

## Examples

``` r
if (requireNamespace("bayesmeta",quietly=TRUE)) b1 <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
if (requireNamespace("bayesmeta",quietly=TRUE)) { es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); es$rainfall <- irrigation_climate$rainfall; b2 <- apm_bayes(es,mods=~rainfall,backend="bayesmeta") }
if (requireNamespace("RoBMA",quietly=TRUE) && requireNamespace("BayesTools",quietly=TRUE)) b3 <- apm_bayes(agri_effects_benchmark,backend="RoBMA",seed=1)
#> Loading required namespace: runjags
#> Error: Sample size 'ni' or unit information sd 'unit_information_sd' must be specified to set-up prior distributions without known UISD.
```
