# Paired/repeated covariance

Builds covariance matrices for genuinely paired, matched, or repeated
effect sizes.

## Usage

``` r
apm_pair_vcov(effects, pair_id, r, structure = c("paired", "compound", "user"), user_V = NULL)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(wheat_paired_blocks,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
apm_pair_vcov(es,pair_id=study_id,r=.6)
#> <apm_vcov> 12 x 12 
#> backend: native  | PSD: TRUE 
apm_pair_vcov(es,pair_id=study_id,r=.4,structure="compound")
#> <apm_vcov> 12 x 12 
#> backend: native  | PSD: TRUE 

apm_pair_vcov(es,pair_id=study_id,r=.8)
#> <apm_vcov> 12 x 12 
#> backend: native  | PSD: TRUE 
```
