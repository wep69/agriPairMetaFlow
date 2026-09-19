# Influence, Leave-One-Out Sensitivity, and GOSH Diagnostics

## Why diagnostics matter

A pooled agronomic response can be scientifically misleading when it
depends disproportionately on one experiment, one environment, or one
unusually precise contrast. Diagnostics should therefore ask how the
fitted synthesis changes when evidence is perturbed, without
automatically deleting observations. `agriPairMetaFlow` keeps that
distinction explicit: diagnosis is not exclusion.

``` r

fit <- apm_fit(agri_effects_benchmark)
inf1 <- apm_influence(fit, unit="study", plot=FALSE)
inf2 <- apm_influence(fit, unit="effect", plot_type="baujat", plot=FALSE)
inf3 <- apm_influence(fit, unit="effect", plot_type="radial", plot=FALSE)
```

Study-level deletion is the preferred diagnostic when several effects
belong to the same independent study. Effect-level deletion remains
useful for locating individual contrasts, but it should not be
interpreted as if dependent contrasts were independent studies.

``` r

loo1 <- apm_leave_one_out(fit, unit="study")
loo2 <- apm_leave_one_out(fit, unit="effect")
loo3 <- apm_leave_one_out(fit, unit="study", transform="percent")
```

The important quantities are not only changes in the pooled estimate.
Changes in heterogeneity, interval width, prediction, and convergence
can reveal whether a study controls the substantive conclusion.

## GOSH as a structure-finding diagnostic

GOSH explores many subsets rather than deleting one study at a time. It
is especially useful for identifying clusters of subsets that imply
different pooled effects or heterogeneity levels. A large analysis is
computationally expensive, so package documentation uses small
demonstrations and reserves large runs for developer-side
precomputation.

``` r

g1 <- apm_gosh(fit, subsets=80, seed=2026, plot=FALSE)
g2 <- apm_gosh(fit, subsets=100, seed=2027, plot=FALSE)
g3 <- apm_gosh(fit, subsets=120, seed=2028, plot=FALSE)
```

No GOSH cluster is automatically labeled an outlier mechanism. It is a
prompt to examine study design, crop, environment, measurement and
intervention differences.
