# Small-Study Effects, Bias Sensitivity, and Advanced Visualization

## Funnel asymmetry is not a diagnosis

Selective publication is one possible explanation for small-study
effects, but agronomic heterogeneity, differences in experimental
precision, dose, crop, climate, and study quality can generate similar
patterns. The package therefore keeps diagnostics and sensitivity models
separate.

``` r

b1 <- apm_bias(fit, methods=c("egger","rank"))
b2 <- apm_bias(fit, methods=c("trimfill","selection"))
if (requireNamespace("PublicationBias", quietly=TRUE)) b3 <- apm_bias(fit, methods="svalue", q=0)
#> Warning in FUN(X[[i]], ...): NAs introduced by coercion
```

The primary model is not silently replaced by a bias-adjusted estimate.
Each sensitivity result retains its backend and assumptions.

## Contour-enhanced funnel plots

``` r

f1 <- apm_funnel_contour(fit)
f2 <- apm_funnel_contour(fit, levels=.95)
f3 <- apm_funnel_contour(fit, label=TRUE)
```

Reference contours help distinguish regions defined by sampling
uncertainty, but they do not prove a selection process.

## Orchard-style synthesis

Orchard-style displays place observed effects, pooled estimates,
confidence intervals and, when identifiable, prediction intervals in one
graphic.

``` r

o1 <- apm_orchard(fit, transform="percent")
o2 <- apm_orchard(fit, raw_effects=FALSE)
o3 <- apm_orchard(fit, prediction=FALSE)
```

For categorical moderators already present in a fitted meta-regression,
the same function can show group-specific estimates. Numeric moderators
should instead be represented by the meta-regression curve tools
introduced in version 0.3.0.
