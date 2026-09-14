# Multilevel and robust inference for dependent agronomic evidence

## Hierarchical evidence structures

A paper may contain experiments, sites, years, outcomes, and several
treatment-control contrasts.
[`apm_multilevel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multilevel.md)
exposes this hierarchy through an agronomic interface and fits the
corresponding model with
[`metafor::rma.mv()`](https://wviechtb.github.io/metafor/reference/rma.mv.html).

``` r

es <- apm_effect_size(
  maize_n_shared, "lnRR",
  m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c
)
V <- apm_vcov(es, cluster=experiment_id)
ml <- apm_multilevel(
  es,
  random=~1|study_id/effect_id,
  V=V,
  test="z"
)
ml
#> <apm_multilevel> measure=lnRR
#>     term   estimate
#>  intrcpt 0.08951268
#> sigma2: 5.239e-13, 7.373e-13
```

## Where does heterogeneity occur?

``` r

apm_variance_components(ml)
#> <apm_variance_components>
#>  component     variance           sd proportion percent
#>   sigma2_1 5.239470e-13 7.238418e-07   0.415412 41.5412
#>   sigma2_2 7.373237e-13 8.586756e-07   0.584588 58.4588
#>     tau2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
#>   gamma2_1 0.000000e+00 0.000000e+00   0.000000  0.0000
```

The reported percentages describe allocation of the modeled
heterogeneity components. They are not percentages of total observed
variance and should not be interpreted as such.

## Cluster-robust inference

For meta-regression or dependent effect structures, model-based standard
errors can be complemented by cluster-robust inference. The package
defaults to CR2 because the bias-reduced adjustment is designed for
improved small-sample performance.

``` r

irr <- apm_effect_size(
  irrigation_climate, "lnRR",
  m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c
)
fit <- apm_fit(irr, mods=~rainfall)
cr2 <- apm_robust(fit, cluster=study_id)
cr2
#> <apm_robust> CR2 clusters= 20 
#>      Coef          beta           SE null_value     tstat  df_Satt       p_Satt
#>   intrcpt  1.716986e-01 0.0160913694          0 10.670231 9.700281 1.127858e-06
#>  rainfall -8.713912e-05 0.0000155366          0 -5.608636 9.998807 2.250742e-04
#>      term
#>   intrcpt
#>  rainfall
apm_compare_inference(fit, robust=cr2)
#> <apm_inference_comparison> transform=exp
#>  method     term  estimate           se       df  ci_lower  ci_upper
#>   model  intrcpt 1.1873200 5.440005e-02       NA 1.0672406 1.3209098
#>   model rainfall 0.9999129 5.435964e-05       NA 0.9998063 1.0000194
#>     CR2  intrcpt 1.1873200 1.609137e-02 9.700281 1.1453315 1.2308478
#>     CR2 rainfall 0.9999129 1.553660e-05 9.998807 0.9998783 0.9999475
#>       p_value
#>  1.598273e-03
#>  1.089322e-01
#>  1.127858e-06
#>  2.250742e-04
```

Low denominator degrees of freedom are reported because a nominally
large number of effect sizes does not guarantee precise robust inference
when the number or leverage distribution of independent clusters is
unfavorable.

## Cluster wild bootstrap

The wild-bootstrap layer is optional and intentionally does not run
heavy resampling during ordinary installation.

``` r

wb <- apm_wild_bootstrap(
  fit,
  cluster=study_id,
  constraints=2,
  R=9999,
  seed=20260826
)
apm_compare_inference(fit, robust=cr2, wild=wb)
```

The result stores the bootstrap distribution settings, seed, number of
independent clusters, p-value, and Monte Carlo standard error.
Conventional, CR2, and bootstrap inference are displayed together; the
package does not choose whichever method gives the smallest p-value.
