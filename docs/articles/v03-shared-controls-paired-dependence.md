# Shared controls, paired designs, and dependence

## Why dependence matters

Agronomic experiments commonly compare several fertilizer rates,
irrigation regimes, or management treatments with the same untreated
control. The resulting effect sizes reuse information from the control
arm and therefore do not have independent sampling errors. Treating them
as independent artificially increases the apparent amount of
information.

## Detect shared controls before fitting a model

``` r

sc <- apm_shared_control(
  maize_n_shared,
  study = experiment_id,
  control_id = control,
  treatment_id = treatment
)
sc
#> <apm_shared_control>
#>  n_rows n_studies n_control_groups n_shared_control_groups
#>      24         8                8                       8
#>  n_rows_in_shared_groups max_multiplicity n_conflicts
#>                       24                3           0
#> Construct a sampling covariance matrix before synthesis; do not treat these contrasts as independent.
```

The audit is intentionally separated from model fitting. Conflicting
duplicated control means, standard deviations, or sample sizes are
flagged rather than silently reconciled.

## Build effect sizes and the sampling covariance matrix

``` r

es <- apm_effect_size(
  maize_n_shared, "lnRR",
  m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c
)
V <- apm_vcov(es, cluster=experiment_id, shared_control=TRUE)
V[1:6,1:6]
#> <apm_vcov> 6 x 6
```

[`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md)
delegates the general covariance construction to
[`metafor::vcalc()`](https://wviechtb.github.io/metafor/reference/vcalc.html).
When treatment and control identifiers are available, they are passed as
the two contrast groups; arm sample sizes are supplied as weights when
possible. The object records the assumptions used and checks symmetry,
the diagonal, and positive semidefiniteness.

## Paired does not merely mean treatment versus control

A genuine paired design uses matched or repeated experimental units. The
`wheat_paired_blocks` data contain an explicit treatment-control
correlation used when computing paired effect sizes.

``` r

pes <- apm_effect_size(
  wheat_paired_blocks, "lnRR", design="paired",
  m_t=mean_t, sd_t=sd_t, n_t=n_pairs,
  m_c=mean_c, sd_c=sd_c, n_c=n_pairs,
  r=r_tc
)
```

When several effects belong to the same dependency block,
[`apm_pair_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_pair_vcov.md)
can represent a compound correlation assumption. Unknown correlations
should be examined by sensitivity analysis rather than chosen to obtain
a preferred result.

## Sensitivity to an unknown correlation

``` r

sm <- apm_effect_size(
  soil_management_multiresponse, "lnRR",
  m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c
)
rho_check <- apm_rho_sensitivity(
  sm,
  rho=c(.25,.50,.75),
  build_vcov=list(cluster="study_id", type="outcome")
)
rho_check
#> <apm_sensitivity>
#>   rho  estimate         se   ci_lower  ci_upper pi_lower pi_upper tau2   ok
#>  0.25 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.50 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  0.75 0.1253056 0.01375874 0.09833901 0.1522723 1.103337 1.164477    0 TRUE
#>  error
#>   <NA>
#>   <NA>
#>   <NA>
```

A stable conclusion should not depend critically on an arbitrary, weakly
justified within-study correlation. The complete grid is retained,
including failed fits.
