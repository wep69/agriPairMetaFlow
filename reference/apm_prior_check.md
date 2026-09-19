# Inspect prior implications

Draw from declared priors and inspect their implications on model and
agronomic scales before fitting.

## Usage

``` r
apm_prior_check(...)
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
pc1 <- apm_prior_check(apm_prior(), "lnRR", draws=500, seed=1, plot=FALSE)
pc2 <- apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)), "lnRR", thresholds=log(c(.9,1.1)), draws=500, seed=1)
pc3 <- apm_prior_check(apm_prior(moderators=list(rainfall=list(dist="normal",mean=0,sd=.001))), "lnRR", x=data.frame(rainfall=c(600,1200)), draws=500, seed=1, plot=FALSE)
```
