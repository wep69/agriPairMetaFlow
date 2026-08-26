# Validate study summaries, binary data, or precomputed effects

Validate study summaries, binary data, or precomputed effects. This
conservative manual snapshot is regenerated from the authoritative
roxygen source before release.

## Usage

``` r
apm_validate(data, schema = c("summary", "binary", "effect"), roles = NULL, strict = TRUE)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: continuous treatment-control summaries.
apm_validate(maize_n_shared, schema = "summary", strict = FALSE)
#> <apm_validation> PASS 
# Example 2: binary pest-suppression data.
apm_validate(pest_suppression_binary, schema = "binary", strict = FALSE)
#> <apm_validation> PASS 
# Example 3: precomputed effect sizes.
apm_validate(agri_effects_benchmark, schema = "effect", strict = FALSE)
#> <apm_validation> PASS 
```
