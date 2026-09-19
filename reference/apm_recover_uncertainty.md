# Recover standard deviations from reported uncertainty

Recover standard deviations from reported uncertainty. This conservative
manual snapshot is regenerated from the authoritative roxygen source
before release.

## Usage

``` r
apm_recover_uncertainty(data, mean, n, sd = NULL, se = NULL, cv = NULL, mse = NULL, ci_lower = NULL, ci_upper = NULL, level = 0.95, df = NULL, method = c("auto", "sd", "se", "cv", "mse", "ci"), impute = FALSE, group = NULL)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: recover SD from SE.
apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, se=se_yield)
#> <apm_uncertainty>
#> 
#> derived_from_se            <NA> 
#>               4               8 
# Example 2: recover SD from reported CV percent.
apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, cv=cv_percent, method="cv")
#> <apm_uncertainty>
#> 
#> derived_from_cv            <NA> 
#>               4               8 
# Example 3: recover SD from residual MSE.
apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, mse=residual_mse, method="mse")
#> <apm_uncertainty>
#> 
#> derived_from_mse             <NA> 
#>                4                8 
```
