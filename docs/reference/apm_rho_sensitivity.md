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
#>   rho estimate se ci_lower ci_upper pi_lower pi_upper tau2    ok
#>  0.25       NA NA       NA       NA       NA       NA   NA FALSE
#>  0.50       NA NA       NA       NA       NA       NA   NA FALSE
#>  0.75       NA NA       NA       NA       NA       NA   NA FALSE
#>                                                          error
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#> failed fits: 3 
apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")
#> <apm_sensitivity>
#>  rho estimate se ci_lower ci_upper pi_lower pi_upper tau2    ok
#>  0.2       NA NA       NA       NA       NA       NA   NA FALSE
#>  0.8       NA NA       NA       NA       NA       NA   NA FALSE
#>                                                          error
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#> failed fits: 2 

apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")
#> <apm_sensitivity>
#>  rho estimate se ci_lower ci_upper pi_lower pi_upper tau2    ok
#>  0.2       NA NA       NA       NA       NA       NA   NA FALSE
#>  0.8       NA NA       NA       NA       NA       NA   NA FALSE
#>                                                          error
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#>  \033[1m\033[22m`subgroup` must evaluate to one value per row.
#> failed fits: 2 
```
