# Compute treatment-control effect sizes and sampling variances

Compute treatment-control effect sizes and sampling variances. This
conservative manual snapshot is regenerated from the authoritative
roxygen source before release.

## Usage

``` r
apm_effect_size(data, measure = c("lnRR", "MD", "SMD", "VR", "CVR", "RR", "OR", "RD", "ZCOR", "GEN"), design = c("auto", "independent", "paired"), m_t = NULL, sd_t = NULL, n_t = NULL, m_c = NULL, sd_c = NULL, n_c = NULL, event_t = NULL, event_c = NULL, r = NULL, yi = NULL, vi = NULL, correct = TRUE, vtype = "LS", paired_standardization = c("change", "raw"), append = TRUE)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: log response ratio for maize nitrogen treatments.
apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c)
#> <apm_effects>24 effects; measure=lnRR; design=independent
#>          yi          vi        sei
#>  0.05337901 0.003394295 0.05826058
#>  0.09225169 0.003441219 0.05866190
#>  0.10661951 0.003567283 0.05972674
#>  0.05470974 0.004332933 0.06582502
#>  0.09452515 0.004391432 0.06626788
#>  0.10473358 0.004560640 0.06753251
# Example 2: coefficient-of-variation ratio for cover crops.
apm_effect_size(covercrop_variability, "CVR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c)
#> <apm_effects>18 effects; measure=CVR; design=independent
#>          yi        vi       sei
#>  -0.1894556 0.2562621 0.5062233
#>  -0.1537453 0.2053017 0.4531023
#>  -0.1198456 0.3383295 0.5816610
#>  -0.2651810 0.2571429 0.5070925
#>  -0.1798309 0.2061729 0.4540627
#>  -0.1441691 0.3390738 0.5823004
# Example 3: paired log response ratio for matched wheat blocks.
apm_effect_size(wheat_paired_blocks, "lnRR", design="paired", m_t=mean_t,
  sd_t=sd_t, n_t=n_pairs, m_c=mean_c, sd_c=sd_c, n_c=n_pairs, r=r_tc)
#> <apm_effects>12 effects; measure=lnRR; design=paired
#>          yi           vi        sei
#>  0.07819826 0.0008616811 0.02935441
#>  0.07897984 0.0007691771 0.02773404
#>  0.07131601 0.0004910021 0.02215857
#>  0.06238004 0.0008622225 0.02936362
#>  0.06025196 0.0010458746 0.03233998
#>  0.06722873 0.0006533247 0.02556022
```
