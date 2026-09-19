# Fit quantitative moderator curves in meta-regression

Fits linear, hierarchical polynomial, natural-spline, or
restricted-cubic- spline relationships between a treatment-control
effect and a quantitative agronomic moderator. Curves describe
across-study effect modification and are not automatically causal
treatment-dose recommendations.

## Usage

``` r
apm_metareg_curve(effects, x, form = c("linear", "quadratic", "cubic", "ns", "rcs"), df = 3, knots = NULL, V = NULL, random = NULL, method = "REML", level = 0.95, grid = 100)
```

## Arguments

- effects:

  Effect-size data containing \`yi\` and \`vi\`.

- x:

  Quantitative moderator column.

- form:

  Functional form: linear, quadratic, cubic, natural spline (\`ns\`), or
  restricted cubic spline (\`rcs\`).

- df:

  Basis degrees of freedom for spline forms.

- knots:

  Optional internal knots. For \`rcs\`, at least four unique knots are
  required; otherwise deterministic quantile knots are generated.

- V:

  Optional sampling covariance matrix.

- random:

  Optional random-effects formula for dependent effects.

- method:

  Heterogeneity estimator.

- level:

  Confidence level used for the stored prediction grid.

- grid:

  Number of grid points across observed moderator support.

## Value

An \`apm_curve\` object inheriting from \`apm_metareg\` and
\`apm_model\`.

## Examples

``` r
# Example 1: linear rainfall effect modification.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_metareg_curve(irr_es,rainfall,form="linear")
#> <apm_metareg> measure=lnRR | backend=metafor::rma.uni
#>     term      estimate
#>  intrcpt  9.131279e-02
#>  .apm_x1 -8.713912e-05
#> Residual QE: 1.9051  | meta-R2 (%): NA 
# Example 2: quadratic rainfall relationship with hierarchy preserved.
apm_metareg_curve(irr_es,rainfall,form="quadratic")
#> <apm_metareg> measure=lnRR | backend=metafor::rma.uni
#>     term      estimate
#>  intrcpt  9.036486e-02
#>  .apm_x1 -8.761799e-05
#>  .apm_x2  1.442002e-08
#> Residual QE: 1.9013  | meta-R2 (%): NA 
# Example 3: nonlinear N-rate association with shared-control covariance.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
apm_metareg_curve(mz_es,N_rate,form="ns",df=3,V=mz_V,
random=~1|study_id/effect_id)
#> Error in apm_metareg_curve(mz_es, N_rate, form = "ns", df = 3, V = mz_V,     random = ~1 | study_id/effect_id): Insufficient unique moderator values for the requested curve form.
```
