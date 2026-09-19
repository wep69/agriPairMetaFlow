# Draw orchard-style summaries of agronomic meta-analysis

Development-snapshot manual for apm_orchard. The roxygen source in R/ is
authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_orchard(...)
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
# Example 1: overall yield response on the percentage scale.
apm_orchard(apm_fit(agri_effects_benchmark), transform="percent")
#> `height` was translated to `width`.
#> `height` was translated to `width`.

# Example 2: raw-effect display can be disabled.
apm_orchard(apm_fit(agri_effects_benchmark), raw_effects=FALSE)
#> `height` was translated to `width`.
#> `height` was translated to `width`.

# Example 3: retain CIs while suppressing prediction intervals.
apm_orchard(apm_fit(agri_effects_benchmark), prediction=FALSE)
#> `height` was translated to `width`.
```
