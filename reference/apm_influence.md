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
#> `plot_type` = "baujat" requires effect-level units; using `unit = "effect"`.
#> <apm_influence> unit=effect | plot=baujat
#>  unit     rstudent       dffits       cook.d     cov.r    tau2.del   QE.del
#>     1  0.938834081  0.199138274 3.981261e-02 1.0491635 0.006320850 35.97212
#>     2  1.249316014  0.254876616 6.347740e-02 1.0155890 0.005864195 35.04740
#>     3  0.809743395  0.156361898 2.471490e-02 1.0508131 0.006462614 36.45936
#>     4 -0.002283177 -0.004581262 2.223689e-05 1.1048511 0.007107127 37.47668
#>     5  0.118814237  0.021539102 4.862293e-04 1.0940261 0.007015988 37.44715
#>     6  1.620459177  0.332937712 1.040780e-01 0.9729631 0.005204638 33.56675
#>     7 -0.328671480 -0.067000502 4.629804e-03 1.0755841 0.006846737 37.32105
#>     8  0.372017073  0.079339594 6.610331e-03 1.0962326 0.006973427 37.19883
#>     9 -0.183285918 -0.042537937 1.895542e-03 1.0935224 0.007008180 37.42583
#>    10 -1.230671943 -0.247437534 6.014430e-02 1.0213836 0.005953906 35.18667
#>         hat   weight inf   tau2_change dfbeta_intrcpt
#>  0.04319625 4.319625      6.221489e-05    0.199148179
#>  0.03944193 3.944193     -3.944398e-04    0.255078961
#>  0.03628803 3.628803      2.039795e-04    0.156227381
#>  0.04774046 4.774046      8.484926e-04   -0.004596583
#>  0.04319625 4.319625      7.573533e-04    0.021551809
#>  0.03944193 3.944193     -1.053997e-03    0.333679735
#>  0.03628803 3.628803      5.881023e-04   -0.066838276
#>  0.04774046 4.774046      7.147927e-04    0.079564816
#>  0.04319625 4.319625      7.495452e-04   -0.042562781
#>  0.03944193 3.944193     -3.047285e-04   -0.247588307
#> No observation is removed automatically by apm_influence(). 
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
#> `plot_type` = "radial" requires effect-level units; using `unit = "effect"`.
#> <apm_influence> unit=effect | plot=radial
#>  unit     rstudent       dffits       cook.d     cov.r    tau2.del   QE.del
#>     1  0.938834081  0.199138274 3.981261e-02 1.0491635 0.006320850 35.97212
#>     2  1.249316014  0.254876616 6.347740e-02 1.0155890 0.005864195 35.04740
#>     3  0.809743395  0.156361898 2.471490e-02 1.0508131 0.006462614 36.45936
#>     4 -0.002283177 -0.004581262 2.223689e-05 1.1048511 0.007107127 37.47668
#>     5  0.118814237  0.021539102 4.862293e-04 1.0940261 0.007015988 37.44715
#>     6  1.620459177  0.332937712 1.040780e-01 0.9729631 0.005204638 33.56675
#>     7 -0.328671480 -0.067000502 4.629804e-03 1.0755841 0.006846737 37.32105
#>     8  0.372017073  0.079339594 6.610331e-03 1.0962326 0.006973427 37.19883
#>     9 -0.183285918 -0.042537937 1.895542e-03 1.0935224 0.007008180 37.42583
#>    10 -1.230671943 -0.247437534 6.014430e-02 1.0213836 0.005953906 35.18667
#>         hat   weight inf dfbeta_intrcpt
#>  0.04319625 4.319625        0.199148179
#>  0.03944193 3.944193        0.255078961
#>  0.03628803 3.628803        0.156227381
#>  0.04774046 4.774046       -0.004596583
#>  0.04319625 4.319625        0.021551809
#>  0.03944193 3.944193        0.333679735
#>  0.03628803 3.628803       -0.066838276
#>  0.04774046 4.774046        0.079564816
#>  0.04319625 4.319625       -0.042562781
#>  0.03944193 3.944193       -0.247588307
#> No observation is removed automatically by apm_influence(). 
```
