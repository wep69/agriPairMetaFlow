# Backend-neutral Bayesian prior specification

Create an auditable prior specification that can be translated to
supported Bayesian backends.

## Usage

``` r
apm_prior(...)
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
p1 <- apm_prior(effect=list(dist="normal",mean=0,sd=.2))
p2 <- apm_prior(tau=list(dist="halfnormal",scale=.2))
p3 <- apm_prior(moderators=list(rainfall=list(dist="normal",mean=0,sd=.001)))
```
