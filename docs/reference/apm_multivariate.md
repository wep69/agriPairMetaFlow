# Multivariate treatment-control meta-analysis

Jointly synthesize multiple agronomic outcomes while preserving sampling
covariance and between-outcome heterogeneity.

## Usage

``` r
apm_multivariate(...)
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
V <- diag(soil_management_multiresponse$vi); m1 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V)
m2 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V, mods=~climate_zone)
if (requireNamespace("mixmeta", quietly=TRUE)) m3 <- apm_multivariate(biochar_multiresponse, outcome=outcome, study=study_id, V=diag(biochar_multiresponse$vi), backend="mixmeta")
```
