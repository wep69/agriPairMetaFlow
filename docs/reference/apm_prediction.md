# Obtain confidence and prediction intervals

Obtain confidence and prediction intervals. This conservative manual
snapshot is regenerated from the authoritative roxygen source before
release.

## Usage

``` r
apm_prediction(model, newdata = NULL, level = 0.95, method = c("model", "HTS", "HK", "KR", "NNF"), transform = c("auto", "none", "exp", "percent"), threshold = NULL, ...)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: pooled prediction expressed as percent change.
apm_prediction(apm_fit(agri_effects_benchmark), transform="percent")
#> <apm_prediction> transform=percent
#>      pred         se ci_lower ci_upper  pi_lower pi_upper
#>  9.581184 0.02609049 4.118456 15.33052 -6.925962 29.01595
# Example 2: rainfall-specific predictions.
fm <- apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed")
apm_prediction(fm, newdata=data.frame(rainfall=c(600,900,1200)))
#> <apm_prediction> transform=auto
#>      pred         se  ci_lower ci_upper  pi_lower pi_upper
#>  1.190957 0.04039360 1.1003043 1.289077 1.0389293 1.365230
#>  1.105846 0.02380854 1.0554280 1.158672 0.9801455 1.247666
#>  1.026817 0.03453616 0.9596124 1.098728 0.9014206 1.169657
# Example 3: ratio-scale prediction.
apm_prediction(apm_fit(agri_effects_benchmark), transform="exp")
#> <apm_prediction> transform=exp
#>      pred         se ci_lower ci_upper  pi_lower pi_upper
#>  1.095812 0.02609049 1.041185 1.153305 0.9307404  1.29016
```
