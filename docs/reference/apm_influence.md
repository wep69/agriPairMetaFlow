# Diagnose influential effects or studies

Development-snapshot manual for apm_influence. The roxygen source in R/
is authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_influence(...)
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
# Example 1: Baujat diagnostic for independent agronomic studies.
apm_influence(apm_fit(agri_effects_benchmark), plot_type="baujat")
#> Error in apm_influence(apm_fit(agri_effects_benchmark), plot_type = "baujat"): Baujat plotting currently requires an rma.uni-backed effect-level model.
# Example 2: classical influence diagnostics.
apm_influence(apm_fit(agri_effects_benchmark), plot_type="influence")
#> <apm_influence> unit=study | plot=influence
#>  unit   cook_proxy   tau2_change   leverage
#>  BM01 3.981261e-02  6.221489e-05 0.04319625
#>  BM02 6.347740e-02 -3.944398e-04 0.03944193
#>  BM03 2.471490e-02  2.039795e-04 0.03628803
#>  BM04 2.223689e-05  8.484926e-04 0.04774046
#>  BM05 4.862293e-04  7.573533e-04 0.04319625
#>  BM06 1.040780e-01 -1.053997e-03 0.03944193
#>  BM07 4.629804e-03  5.881023e-04 0.03628803
#>  BM08 6.610331e-03  7.147927e-04 0.04774046
#>  BM09 1.895542e-03  7.495452e-04 0.04319625
#>  BM10 6.014430e-02 -3.047285e-04 0.03944193
#> No observation is removed automatically by apm_influence(). 
# Example 3: radial diagnostic for the same fitted evidence base.
apm_influence(apm_fit(agri_effects_benchmark), metrics=c("cook","leverage"), plot_type="radial")
#> Error in apm_influence(apm_fit(agri_effects_benchmark), metrics = c("cook",     "leverage"), plot_type = "radial"): Radial plotting currently requires an rma.uni-backed effect-level model.
```
