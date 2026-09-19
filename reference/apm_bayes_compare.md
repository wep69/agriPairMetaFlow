# Compare prespecified Bayesian models

Compare compatible Bayesian models using predictive criteria or inspect
posterior model probabilities from a RoBMA ensemble.

## Usage

``` r
apm_bayes_compare(...)
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
if (FALSE) apm_bayes_compare(b1,b2,criterion="loo")
if (FALSE) apm_bayes_compare(b1,b2,criterion="waic")
if (FALSE) apm_bayes_compare(robma_fit,criterion="model_probability")
```
