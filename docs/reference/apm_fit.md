# Fit a common-, random-, or mixed-effects meta-analysis

Fit a common-, random-, or mixed-effects meta-analysis. This
conservative manual snapshot is regenerated from the authoritative
roxygen source before release.

## Usage

``` r
apm_fit(effects, yi = yi, vi = vi, V = NULL, mods = ~ 1, model = c("random", "common", "mixed"), method = "REML", test = c("z", "t", "knha"), level = 0.95, weights = NULL, backend = c("auto", "metafor"), ...)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: random-effects lnRR synthesis.
maize_100 <- maize_n_shared[maize_n_shared$N_rate == 100, ]
es1 <- apm_effect_size(maize_100, "lnRR", m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_fit(es1)
#> <apm_model> measure=lnRR, model=random, method=REML
#>    intrcpt 
#> 0.09053437 
# Example 2: variability-ratio synthesis with Knapp-Hartung inference.
es2 <- apm_effect_size(covercrop_variability, "VR", m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_fit(es2, test="knha")
#> <apm_model> measure=VR, model=random, method=REML
#>    intrcpt 
#> -0.1302477 
# Example 3: common-effect benchmark.
apm_fit(agri_effects_benchmark, yi=yi, vi=vi, model="common")
#> <apm_model> measure=lnRR, model=common, method=FE
#>    intrcpt 
#> 0.09009397 
```
