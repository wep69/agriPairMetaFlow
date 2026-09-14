# Correlation sensitivity analysis

Refits covariance and synthesis across a transparent grid of plausible
correlations without selecting a preferred value.

## Usage

``` r
apm_rho_sensitivity(effects, rho = seq(0, 0.9, 0.1), build_vcov, fit = NULL, metric = c("estimate", "se", "ci", "pi", "tau2"), ...)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_rho_sensitivity(es,rho=c(.25,.5,.75),build_vcov=list(cluster="study_id",type="outcome"))
#> <apm_sensitivity>
#>   rho  estimate         se   ci_lower  ci_upper pi_lower pi_upper tau2   ok
#>  0.25 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.50 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.75 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  error
#>   <NA>
#>   <NA>
#>   <NA>
apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")
#> <apm_sensitivity>
#>  rho  estimate         se   ci_lower  ci_upper pi_lower pi_upper tau2   ok
#>  0.2 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.8 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  error
#>   <NA>
#>   <NA>

apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")
#> <apm_sensitivity>
#>  rho  estimate         se   ci_lower  ci_upper pi_lower pi_upper tau2   ok
#>  0.2 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.8 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  error
#>   <NA>
#>   <NA>
```
