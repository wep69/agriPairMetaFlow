# Adjusted marginal effects from agronomic meta-regression

Computes standardized marginal predictions by averaging the fitted
meta-regression design matrix over the observed study distribution while
setting selected moderators to explicit levels or values.

## Usage

``` r
apm_marginal_effects(model, variables = NULL, at = NULL, weights = c("equal", "study"), transform = c("auto", "none", "exp", "percent"), level = 0.95)
```

## Arguments

- model:

  An \`apm_metareg\` model.

- variables:

  Moderator names to summarize. Numeric moderators require explicit
  values in \`at\`.

- at:

  Named list of moderator values at which marginal predictions are
  evaluated.

- weights:

  Marginalization rule: equal effect-level weights or equal study-level
  weights.

- transform:

  Output transformation.

- level:

  Confidence level.

## Value

An \`apm_marginal\` object with adjusted estimates and uncertainty.

## Examples

``` r
# Example 1: crop-adjusted inoculant response.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_m <- apm_metareg(bio_es, ~ crop + site)
apm_marginal_effects(bio_m, variables="crop", transform="percent")
#> <apm_marginal> weights=equal | transform=percent
#>         crop     pred         se   ci_lower ci_upper   pi_lower pi_upper
#>  common_bean 6.523174 0.04309177 -2.6969728 16.61699 -2.6969728 16.61699
#>        maize 8.323358 0.01875818  4.1374156 12.67756  4.1374156 12.67756
#>      soybean 6.499606 0.03227482 -0.4824101 13.97147 -0.4824101 13.97147
#>        wheat 4.453785 0.03682445 -3.3226227 12.85570 -3.3226227 12.85570
# Example 2: irrigation response at three rainfall contexts.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_m <- apm_metareg(irr_es, ~ rainfall * climate_zone)
apm_marginal_effects(irr_m, at=list(rainfall=c(600,900,1200)))
#> <apm_marginal> weights=equal | transform=auto
#>  rainfall     pred         se  ci_lower ci_upper  pi_lower pi_upper
#>       600 1.133878 0.06163476 0.9934720 1.294128 0.9934720 1.294128
#>       900 1.112604 0.04461046 1.0110843 1.224317 1.0110843 1.224317
#>      1200 1.091729 0.07213642 0.9352376 1.274405 0.9352376 1.274405
# Example 3: equal-study weighting with shared-control nitrogen effects.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_m <- apm_metareg(mz_es,~N_rate+soil_texture,V=mz_V,random=~1|study_id/effect_id)
apm_marginal_effects(mz_m,variables="soil_texture",weights="study")
#> <apm_marginal> weights=study | transform=auto
#>  soil_texture     pred         se ci_lower ci_upper pi_lower pi_upper
#>          clay 1.094079 0.03134488 1.024832 1.168005       NA       NA
#>          loam 1.092475 0.02928991 1.027725 1.161304       NA       NA
#>         sandy 1.098368 0.03578598 1.019362 1.183497       NA       NA
```
