# Audit agronomic meta-analysis data and design semantics

Audit agronomic meta-analysis data and design semantics. This
conservative manual snapshot is regenerated from the authoritative
roxygen source before release.

## Usage

``` r
apm_audit(data, plan = NULL, level = c("basic", "full"), repair = FALSE)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: detect shared controls in nitrogen experiments.
apm_audit(maize_n_shared, level = "full")
#> <apm_audit>
#>  severity           code
#>   warning shared_control
#>                                                                            message
#>  8 study/experiment control arm(s) are reused across multiple treatment contrasts.
#>  rows
#>  <NA>
#>                                                                                     action
#>  Model sampling dependence with apm_vcov() or use one independent contrast per experiment.
# Example 2: identify heterogeneous uncertainty reporting.
apm_audit(agri_uncertainty_mixed, level = "full")
#> <apm_audit>
#> No audit issues detected.
# Example 3: audit multiresponse soil-management summaries.
apm_audit(soil_management_multiresponse, level = "basic")
#> <apm_audit>
#> No audit issues detected.
```
