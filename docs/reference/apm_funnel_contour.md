# Draw a contour-enhanced funnel plot

Development-snapshot manual for apm_funnel_contour. The roxygen source
in R/ is authoritative; regenerate with roxygen2 during local
validation.

## Usage

``` r
apm_funnel_contour(...)
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
# Example 1: conventional 90/95/99 percent contours.
apm_funnel_contour(apm_fit(agri_effects_benchmark))

# Example 2: focus on the 95 percent reference contour.
apm_funnel_contour(apm_fit(agri_effects_benchmark), levels=.95)

# Example 3: label studies for a diagnostic review.
apm_funnel_contour(apm_fit(agri_effects_benchmark), label=TRUE)
```
