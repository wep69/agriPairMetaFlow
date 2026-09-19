# Summarize heterogeneity and its uncertainty

Summarize heterogeneity and its uncertainty. This conservative manual
snapshot is regenerated from the authoritative roxygen source before
release.

## Usage

``` r
apm_heterogeneity(model, ci = TRUE, level = 0.95, method_ci = c("auto", "profile", "QP"))
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: heterogeneity of benchmark lnRR effects.
apm_heterogeneity(apm_fit(agri_effects_benchmark))
#> <apm_heterogeneity>
#>   k        Q Q_df        Q_p        tau2        tau       I2       H2
#>  24 37.47688   23 0.02896215 0.006258635 0.07911153 38.53446 1.626928
# Example 2: heterogeneity of CVR effects.
ev <- apm_effect_size(covercrop_variability,"CVR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_heterogeneity(apm_fit(ev))
#> <apm_heterogeneity>
#>   k         Q Q_df Q_p tau2 tau I2 H2
#>  18 0.1905884   17   1    0   0  0  1
# Example 3: heterogeneity after a rainfall moderator.
apm_heterogeneity(apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed"))
#> <apm_heterogeneity>
#>   k        Q Q_df       Q_p        tau2        tau       I2      H2
#>  24 28.97262   22 0.1456442 0.003223363 0.05677467 24.38049 1.32241
```
