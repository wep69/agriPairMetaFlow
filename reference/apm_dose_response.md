# Fit correlated agronomic dose-response meta-analysis

Fits a true multi-dose treatment-control synthesis while respecting
within-study covariance created by doses sharing a common reference.
Random coefficient dose-response models use the optional `dosresmeta`
backend. If it is unavailable, only the fixed-effect generalized
least-squares route is provided through `metafor`; a random-intercept
model is deliberately not presented as an equivalent substitute for
random dose-response curves.

## Usage

``` r
apm_dose_response(data, effect, dose, study, V = NULL, form = c("linear", "quadratic", "ns"), df = 3, method = "reml", covariance = c("auto", "user"), reference = 0, moderators = NULL, ...)
```

## Arguments

- data:

  Data frame or `apm_effects` containing effect sizes.

- effect:

  Effect-size column, typically `yi` or `lnRR`.

- dose:

  Quantitative dose column.

- study:

  Study identifier.

- V:

  Optional sampling covariance matrix corresponding to all input rows,
  all complete rows, or retained non-reference rows.

- form:

  Dose-response form: linear, quadratic, or natural spline.

- df:

  Natural-spline degrees of freedom.

- method:

  `"reml"`, `"ml"`, or `"fixed"`.

- covariance:

  `"auto"` reconstructs covariance from shared-arm metadata; `"user"`
  requires `V`.

- reference:

  Reference dose, usually zero.

- moderators:

  Optional study-level meta-regression formula for the `dosresmeta`
  backend.

- ...:

  Additional arguments passed to the selected backend.

## Value

An `apm_dose` object with covariance provenance, dose basis, original
reference/analysis row indices, predictions, diagnostics, and backend
object.

## Examples

``` r
# Example 1: random-effects linear nitrogen curve when dosresmeta is available.
if (requireNamespace("dosresmeta", quietly=TRUE))
  apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
    study=study_id,form="linear")
#> <apm_dose> form=linear | backend=dosresmeta | covariance=apm_vcov(shared-control metadata)
#>         term     estimate
#>  (Intercept) 0.0004821551
# Example 2: fixed quadratic GLS preserving shared-control covariance.
apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
  study=study_id,form="quadratic",method="fixed")
#> <apm_dose> form=quadratic | backend=dosresmeta | covariance=apm_vcov(shared-control metadata)
#>     term      estimate
#>  .apm_d1  8.807223e-04
#>  .apm_d2 -2.505704e-06
# Example 3: flexible curve with a study-level moderator.
if (requireNamespace("dosresmeta", quietly=TRUE))
  apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
    study=study_id,form="ns",df=3,moderators=~soil_texture)
#> <apm_dose> form=ns | backend=dosresmeta | covariance=apm_vcov(shared-control metadata)
#>                       term      estimate
#>        .apm_d1.(Intercept)  5.487413e-02
#>        .apm_d2.(Intercept)  1.200030e-01
#>        .apm_d3.(Intercept)  4.641828e-02
#>   .apm_d1.soil_textureloam -1.284997e-05
#>   .apm_d2.soil_textureloam -5.332290e-05
#>   .apm_d3.soil_textureloam  2.630030e-05
#>  .apm_d1.soil_texturesandy  2.052580e-05
#>  .apm_d2.soil_texturesandy -1.283274e-04
#>  .apm_d3.soil_texturesandy  4.687136e-05
```
