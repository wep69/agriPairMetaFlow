# Export tables, models, figures, and reproducible objects

Development-snapshot manual for apm_export. The roxygen source in R/ is
authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_export(...)
```

## Arguments

- ...:

  See the complete roxygen documentation and vignettes for arguments and
  method-specific assumptions.

## Value

An auditable agriPairMetaFlow result or output object as documented in
the function source.

## Examples

``` r
# Example 1: reproducible model object.
apm_export(apm_fit(agri_effects_benchmark), tempfile(fileext=".rds"), format="rds", overwrite=TRUE)
# Example 2: numeric-preserving CSV table.
apm_export(apm_table(apm_fit(agri_effects_benchmark)), tempfile(fileext=".csv"), format="csv", overwrite=TRUE)
# Example 3: publication-resolution forest figure.
apm_export(apm_forest(apm_fit(agri_effects_benchmark)), tempfile(fileext=".tiff"), format="tiff", dpi=600, overwrite=TRUE)
```
