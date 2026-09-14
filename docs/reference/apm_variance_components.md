# Extract variance components

Extracts multilevel heterogeneity components and optionally expresses
them as proportions of modeled heterogeneity.

## Usage

``` r
apm_variance_components(model, level = 0.95, proportion = TRUE)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
ml <- apm_multilevel(es,random=~1|study_id/effect_id,V=apm_vcov(es,cluster=experiment_id),test="z")
apm_variance_components(ml)
#> <apm_variance_components>
#>  component     variance           sd proportion percent
#>   sigma2_1 5.239470e-13 7.238418e-07   0.415412 41.5412
#>   sigma2_2 7.373237e-13 8.586756e-07   0.584588 58.4588
#>     tau2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
#>   gamma2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
apm_variance_components(ml,proportion=FALSE)
#> <apm_variance_components>
#>  component     variance           sd proportion percent
#>   sigma2_1 5.239470e-13 7.238418e-07         NA      NA
#>   sigma2_2 7.373237e-13 8.586756e-07         NA      NA
#>     tau2_1 0.000000e+00 0.000000e+00         NA      NA
#>   gamma2_1 0.000000e+00 0.000000e+00         NA      NA

apm_variance_components(ml,level=.90)
#> <apm_variance_components>
#>  component     variance           sd proportion percent
#>   sigma2_1 5.239470e-13 7.238418e-07   0.415412 41.5412
#>   sigma2_2 7.373237e-13 8.586756e-07   0.584588 58.4588
#>     tau2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
#>   gamma2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
```
