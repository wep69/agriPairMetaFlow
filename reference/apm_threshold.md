# Evaluate a user-defined agronomic relevance threshold

Evaluate a user-defined agronomic relevance threshold. This conservative
manual snapshot is regenerated from the authoritative roxygen source
before release.

## Usage

``` r
apm_threshold(model, threshold, scale = c("model", "ratio", "percent", "absolute"), direction = c("greater", "less", "two-sided"), prediction = TRUE)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: at least five percent improvement.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=5, scale="percent")
#> <apm_threshold>
#> threshold: 5 [ percent ]
#> CI: crosses threshold 
#> PI: crosses threshold 
#> probability: 0.696 
# Example 2: ratio of means at least 1.10.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=1.10, scale="ratio", direction="greater")
#> <apm_threshold>
#> threshold: 1.1 [ ratio ]
#> CI: crosses threshold 
#> PI: crosses threshold 
#> probability: 0.482 
# Example 3: a model-scale threshold in the adverse direction.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=0, scale="model", direction="less")
#> <apm_threshold>
#> threshold: 0 [ model ]
#> CI: entirely above threshold 
#> PI: crosses threshold 
#> probability: 0.136 
```
