# Diagnose small-study effects and publication-bias sensitivity

Development-snapshot manual for apm_bias. The roxygen source in R/ is
authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_bias(...)
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
# Example 1: funnel-asymmetry diagnostics.
apm_bias(apm_fit(agri_effects_benchmark), methods=c("egger","rank"))
#> <apm_bias>
#>  method  estimate   p_value
#>   egger 0.8122011 0.4166762
#>    rank 0.1392507 0.3819083
#>                                                                            note
#>   Regression test for funnel asymmetry; asymmetry has multiple possible causes.
#>  Rank correlation is an asymmetry diagnostic, not a publication-bias diagnosis.
#> Small-study effects and funnel asymmetry have multiple causes. No bias-adjusted result is automatically preferred over the primary model. 
# Example 2: two sensitivity models, without treating either as truth.
apm_bias(apm_fit(agri_effects_benchmark), methods=c("trimfill","selection"))
#> <apm_bias>
#>     method   estimate   p_value
#>   trimfill 0.06018497        NA
#>  selection 0.08385784 0.5517666
#>                                                                                                    note
#>  Trim-and-fill is a sensitivity analysis under a specific missingness mechanism, not a corrected truth.
#>                Step-function selection model; interpret relative to its explicit selection assumptions.
#> Small-study effects and funnel asymmetry have multiple causes. No bias-adjusted result is automatically preferred over the primary model. 
# Example 3: S-value when PublicationBias is installed.
if (requireNamespace("PublicationBias",quietly=TRUE)) apm_bias(apm_fit(agri_effects_benchmark), methods="svalue", q=0, favor="positive")
#> <apm_bias>
#>  method estimate p_value                                  note
#>  svalue       NA      NA there is no package called 'metabias'
#> Small-study effects and funnel asymmetry have multiple causes. No bias-adjusted result is automatically preferred over the primary model. 
```
