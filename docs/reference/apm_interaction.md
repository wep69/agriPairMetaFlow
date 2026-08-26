# Interpret prespecified meta-regression interactions

Converts interaction coefficients into simple slopes or adjusted
contrasts on scientifically interpretable moderator scales.
Simple-effect p-values and joint tests follow the fitted model's t-based
versus normal inference mode.

## Usage

``` r
apm_interaction(model, term, at = NULL, contrast = c("difference", "ratio"), adjust = "none", level = 0.95)
```

## Arguments

- model:

  An \`apm_metareg\` model containing the requested interaction.

- term:

  Interaction term, such as \`"rainfall:climate_zone"\`.

- at:

  Optional named list defining values for continuous moderators.

- contrast:

  \`"difference"\` on the model scale or \`"ratio"\` for log-ratio
  estimands.

- adjust:

  Multiplicity adjustment from \`stats::p.adjust.methods\`.

- level:

  Confidence level.

## Value

An \`apm_interaction\` object with simple effects, contrasts, and an
interaction-specific joint Wald test.

## Examples

``` r
# Example 1: rainfall slope by climate zone.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_i <- apm_metareg(irr_es,~rainfall*climate_zone)
apm_interaction(irr_i,"rainfall:climate_zone",at=list(rainfall=c(600,900)))
#> <apm_interaction> rainfall:climate_zone | contrast=difference
#>                                     label      context      estimate
#>       slope_rainfall | climate_zone=humid rainfall=600 -1.288665e-04
#>       slope_rainfall | climate_zone=humid rainfall=900 -1.288665e-04
#>    slope_rainfall | climate_zone=semiarid rainfall=600  1.238407e-05
#>    slope_rainfall | climate_zone=semiarid rainfall=900  1.238407e-05
#>  slope_rainfall | climate_zone=transition rainfall=600 -6.213622e-05
#>  slope_rainfall | climate_zone=transition rainfall=900 -6.213622e-05
#>            se      ci_lower     ci_upper   statistic df distribution   p_value
#>  0.0002451578 -0.0006546776 0.0003969446 -0.52564722 14            t 0.6073594
#>  0.0002451578 -0.0006546776 0.0003969446 -0.52564722 14            t 0.6073594
#>  0.0003714827 -0.0007843670 0.0008091352  0.03333688 14            t 0.9738766
#>  0.0003714827 -0.0007843670 0.0008091352  0.03333688 14            t 0.9738766
#>  0.0002574490 -0.0006143095 0.0004900370 -0.24135349 14            t 0.8127802
#>  0.0002574490 -0.0006143095 0.0004900370 -0.24135349 14            t 0.8127802
#>  p_adjusted
#>   0.6073594
#>   0.6073594
#>   0.9738766
#>   0.9738766
#>   0.8127802
#>   0.8127802
#> Joint interaction test:
#>   statistic df1 df2 distribution   p_value
#>  0.05299287   2  14            F 0.9485761
# Example 2: crop by site interaction for inoculant response.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_i <- apm_metareg(bio_es,~crop*site)
apm_interaction(bio_i,"crop:site",adjust="holm")
#> <apm_interaction> crop:site | contrast=difference
#>                        label         context     estimate         se   ci_lower
#>    crop=maize vs common_bean      site=Areia  0.029670609 0.08659668 -0.1590073
#>  crop=soybean vs common_bean      site=Areia  0.004038997 0.09985842 -0.2135338
#>    crop=wheat vs common_bean      site=Areia -0.005580770 0.10570655 -0.2358955
#>    crop=maize vs common_bean site=Bananeiras  0.010686439 0.08044875 -0.1645963
#>  crop=soybean vs common_bean site=Bananeiras  0.005674865 0.09288805 -0.1967108
#>    crop=wheat vs common_bean site=Bananeiras -0.030327378 0.09672300 -0.2410687
#>    crop=maize vs common_bean site=Lagoa Seca  0.012011577 0.07773183 -0.1573515
#>  crop=soybean vs common_bean site=Lagoa Seca -0.008615017 0.08797695 -0.2003003
#>    crop=wheat vs common_bean site=Lagoa Seca -0.020755157 0.09315974 -0.2237328
#>   ci_upper   statistic df distribution   p_value p_adjusted
#>  0.2183486  0.34262986 12            t 0.7378038          1
#>  0.2216118  0.04044723 12            t 0.9684017          1
#>  0.2247340 -0.05279493 12            t 0.9587640          1
#>  0.1859692  0.13283538 12            t 0.8965251          1
#>  0.2080605  0.06109360 12            t 0.9522904          1
#>  0.1804139 -0.31354876 12            t 0.7592470          1
#>  0.1813747  0.15452585 12            t 0.8797637          1
#>  0.1830703 -0.09792358 12            t 0.9236096          1
#>  0.1822225 -0.22279106 12            t 0.8274452          1
#> Joint interaction test:
#>   statistic df1 df2 distribution   p_value
#>  0.01625734   6  12            F 0.9999715
# Example 3: nitrogen slope by soil texture with dependent contrasts.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_i <- apm_metareg(mz_es,~N_rate*soil_texture,V=mz_V,random=~1|study_id/effect_id)
apm_interaction(mz_i,"N_rate:soil_texture",contrast="ratio")
#> <apm_interaction> N_rate:soil_texture | contrast=ratio
#>                              label    context estimate           se  ci_lower
#>   slope_N_rate | soil_texture=clay N_rate=100 1.000192 0.0003844366 0.9993841
#>   slope_N_rate | soil_texture=loam N_rate=100 1.000373 0.0003585323 0.9996201
#>  slope_N_rate | soil_texture=sandy N_rate=100 1.000241 0.0004392378 0.9993189
#>  ci_upper statistic df distribution   p_value p_adjusted
#>  1.001000 0.4982738 18            t 0.6243245  0.6243245
#>  1.001127 1.0412052 18            t 0.3115643  0.3115643
#>  1.001165 0.5496538 18            t 0.5893123  0.5893123
#> Joint interaction test:
#>   statistic df1 df2 distribution   p_value
#>  0.06405063   2  18            F 0.9381703
```
