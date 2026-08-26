# Fit agronomic meta-regression models

Fits mixed-effects meta-regression while retaining moderator support,
centering/scaling constants, factor reference levels, residual
heterogeneity, and a transparent meta-analytic R-squared descriptor.
Continuous moderators are centered by default so the intercept is
evaluated at their observed mean.

## Usage

``` r
apm_metareg(effects, moderators, V = NULL, random = NULL, method = "REML", test = "t", center = TRUE, scale = FALSE, interactions = NULL, ...)
```

## Arguments

- effects:

  \`apm_effects\` or a data frame containing \`yi\` and \`vi\`.

- moderators:

  One-sided moderator formula, for example \`~ rainfall + crop\`.

- V:

  Optional sampling variance-covariance matrix.

- random:

  Optional random-effects formula. Supplying \`V\` or \`random\` routes
  the fit through \`metafor::rma.mv()\`.

- method:

  Heterogeneity estimator, default \`"REML"\`.

- test:

  Inference method supported by the selected \`metafor\` backend.

- center:

  Center numeric moderators before fitting.

- scale:

  Scale numeric moderators by their SD after centering.

- interactions:

  Optional character vector of prespecified interaction terms to add to
  \`moderators\`.

- ...:

  Additional arguments passed to \`metafor::rma.uni()\` or
  \`metafor::rma.mv()\`.

## Value

An \`apm_metareg\` object inheriting from \`apm_model\`.

## Examples

``` r
# Example 1: rainfall and temperature as quantitative moderators.
irrig_es <- apm_effect_size(irrigation_climate, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_metareg(irrig_es, ~ rainfall + mean_temp)
#> <apm_metareg> measure=lnRR | backend=metafor::rma.uni
#>       term    estimate
#>    intrcpt 0.091321634
#>   rainfall 0.001234469
#>  mean_temp 0.264530461
#> Residual QE: 1.9013  | meta-R2 (%): NA 
# Example 2: adjusted crop differences for an inoculant treatment.
bio_es <- apm_effect_size(bioinoculant_multicrop, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_metareg(bio_es, ~ crop + site)
#> <apm_metareg> measure=lnRR | backend=metafor::rma.uni
#>            term      estimate
#>         intrcpt  0.0732132222
#>       cropmaize  0.0167582468
#>     cropsoybean -0.0002212779
#>       cropwheat -0.0196178373
#>  siteBananeiras -0.0064304384
#>  siteLagoa Seca -0.0236321088
#> Residual QE: 0.22554  | meta-R2 (%): NA 
# Example 3: dependence-aware nitrogen meta-regression.
maize_es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
maize_V <- apm_vcov(maize_es, cluster=experiment_id)
apm_metareg(maize_es, ~ N_rate + soil_texture, V=maize_V,
random=~1|study_id/effect_id)
#> <apm_metareg> measure=lnRR | backend=metafor::rma.mv
#>               term      estimate
#>            intrcpt  0.0899124889
#>             N_rate  0.0002763246
#>   soil_textureloam -0.0014668685
#>  soil_texturesandy  0.0039126420
#> Residual QE: 1.5159  | meta-R2 (%): -55.818 
```
