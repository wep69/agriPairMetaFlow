# Create standardized analysis tables

Create standardized analysis tables. This conservative manual snapshot
is regenerated from the authoritative roxygen source before release.

## Usage

``` r
apm_table(x, component = c("auto", "effects", "model", "heterogeneity", "metareg", "robust", "bayes", "sensitivity"), transform = c("auto", "none", "exp", "percent"), digits = 3, format = c("data.frame", "gt", "flextable"), ...)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: effect-size table.
ee <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_table(ee, component="effects")
#>    study_id experiment_id  crop treatment control    yi    vi   sei
#> 1      MZ01        MZ01E1 maize       N50      N0 1.055 0.003 0.058
#> 2      MZ01        MZ01E1 maize      N100      N0 1.097 0.003 0.059
#> 3      MZ01        MZ01E1 maize      N150      N0 1.113 0.004 0.060
#> 4      MZ02        MZ02E1 maize       N50      N0 1.056 0.004 0.066
#> 5      MZ02        MZ02E1 maize      N100      N0 1.099 0.004 0.066
#> 6      MZ02        MZ02E1 maize      N150      N0 1.110 0.005 0.068
#> 7      MZ03        MZ03E1 maize       N50      N0 1.081 0.003 0.058
#> 8      MZ03        MZ03E1 maize      N100      N0 1.097 0.003 0.059
#> 9      MZ03        MZ03E1 maize      N150      N0 1.128 0.004 0.060
#> 10     MZ04        MZ04E1 maize       N50      N0 1.097 0.005 0.068
#> 11     MZ04        MZ04E1 maize      N100      N0 1.095 0.005 0.070
#> 12     MZ04        MZ04E1 maize      N150      N0 1.108 0.005 0.072
#> 13     MZ05        MZ05E1 maize       N50      N0 1.092 0.004 0.065
#> 14     MZ05        MZ05E1 maize      N100      N0 1.096 0.004 0.067
#> 15     MZ05        MZ05E1 maize      N150      N0 1.102 0.005 0.068
#> 16     MZ06        MZ06E1 maize       N50      N0 1.084 0.004 0.064
#> 17     MZ06        MZ06E1 maize      N100      N0 1.110 0.004 0.065
#> 18     MZ06        MZ06E1 maize      N150      N0 1.084 0.005 0.068
#> 19     MZ07        MZ07E1 maize       N50      N0 1.079 0.003 0.058
#> 20     MZ07        MZ07E1 maize      N100      N0 1.074 0.004 0.060
#> 21     MZ07        MZ07E1 maize      N150      N0 1.124 0.004 0.060
#> 22     MZ08        MZ08E1 maize       N50      N0 1.097 0.004 0.065
#> 23     MZ08        MZ08E1 maize      N100      N0 1.094 0.004 0.066
#> 24     MZ08        MZ08E1 maize      N150      N0 1.096 0.005 0.068
# Example 2: pooled model table as percent change.
apm_table(apm_fit(agri_effects_benchmark), component="model", transform="percent")
#>            term estimate    se ci_lower ci_upper
#> intrcpt intrcpt    9.581 0.026    4.118   15.331
# Example 3: heterogeneity table, optionally formatted with gt.
hh <- apm_heterogeneity(apm_fit(agri_effects_benchmark))
if (requireNamespace("gt", quietly=TRUE)) apm_table(hh, format="gt")


  

k
```
