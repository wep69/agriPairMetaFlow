# Cluster-robust inference

Applies cluster-robust covariance estimation and small-sample inference
with clubSandwich.

## Usage

``` r
apm_robust(model, cluster, vcov = c("CR2", "CR1", "CR0"), test = c("Satterthwaite", "saddlepoint"), constraints = NULL)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
if (FALSE) { # \dontrun{
es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
fit <- apm_fit(es,mods=~rainfall)
apm_robust(fit,cluster=study_id)
apm_robust(fit,cluster=study_id,constraints=2)
} # }

apm_robust(fit,cluster=study_id,vcov="CR1")
#> Error: object 'fit' not found
```
