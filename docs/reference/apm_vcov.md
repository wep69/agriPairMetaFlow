# Construct sampling covariance

Constructs a variance-covariance matrix for dependent effect sizes using
explicit dependency descriptors and metafor::vcalc().

## Usage

``` r
apm_vcov(effects, cluster, subgroup = NULL, obs = NULL, type = NULL, time1 = NULL, time2 = NULL, rho = NULL, phi = NULL, shared_control = TRUE, near_pd = FALSE, sparse = FALSE)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_vcov(es, cluster=experiment_id)
#> <apm_vcov> 24 x 24 
#> backend: metafor::vcalc  | PSD: TRUE 
es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_vcov(es2,cluster=study_id,type=outcome,rho=.5,shared_control=FALSE)
#> <apm_vcov> 18 x 18 
#> backend: metafor::vcalc  | PSD: TRUE 

apm_vcov(es, cluster=study_id, rho=.3, shared_control=FALSE)
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ01.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ02.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ03.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ04.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ05.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ06.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ07.
#> Warning: The var-cov matrix appears to be not positive definite in cluster MZ08.
#> <apm_vcov> 24 x 24 
#> backend: metafor::vcalc  | PSD: TRUE 
```
