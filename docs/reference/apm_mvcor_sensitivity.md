# Sensitivity to unknown outcome correlations

Refit multivariate models over a prespecified grid of within-study
outcome correlations.

## Usage

``` r
apm_mvcor_sensitivity(...)
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
s1 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(0,.5))
s2 <- apm_mvcor_sensitivity(biochar_multiresponse, outcome=outcome, study=study_id, rho=c(.25,.5,.75))
s3 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(0,.3), fit_args=list(mods=~climate_zone))
```
