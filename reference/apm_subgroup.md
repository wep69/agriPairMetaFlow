# Fit prespecified subgroup meta-analyses

Fit prespecified subgroup meta-analyses. This conservative manual
snapshot is regenerated from the authoritative roxygen source before
release.

## Usage

``` r
apm_subgroup(effects, subgroup, method = "REML", test = "knha", interaction_test = TRUE, min_studies = 2, ...)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: inoculant effects by crop.
e1 <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_subgroup(e1, crop)
#> <apm_subgroup>
#>     subgroup k   estimate          se   ci_lower   ci_upper   pi_lower
#>  common_bean 6 0.06238819 0.005111549 0.04924854 0.07552785 0.04924854
#>        maize 6 0.07918778 0.005193704 0.06583694 0.09253862 0.06583694
#>      soybean 6 0.06167568 0.006198046 0.04574309 0.07760826 0.04574309
#>        wheat 6 0.04249046 0.005255583 0.02898055 0.05600037 0.02898055
#>    pi_upper
#>  0.07552785
#>  0.09253862
#>  0.07760826
#>  0.05600037
#> Omnibus subgroup test:
#>       QM df         QMp
#>  7.99768  3 0.001068256
# Example 2: irrigation effects by climate zone.
e2 <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_subgroup(e2, climate_zone)
#> <apm_subgroup>
#>    subgroup k   estimate          se   ci_lower   ci_upper   pi_lower
#>       humid 7 0.06778687 0.008008635 0.04819044 0.08738329 0.04819044
#>    semiarid 6 0.12403155 0.008161153 0.10305264 0.14501046 0.10305264
#>  transition 7 0.08597761 0.008382675 0.06546595 0.10648928 0.06546595
#>    pi_upper
#>  0.08738329
#>  0.14501046
#>  0.10648928
#> Omnibus subgroup test:
#>       QM df         QMp
#>  10.5109  2 0.001067918
# Example 3: benchmark effects by soil texture.
apm_subgroup(agri_effects_benchmark, soil_texture, interaction_test=TRUE)
#> <apm_subgroup>
#>  subgroup k   estimate         se     ci_lower  ci_upper     pi_lower  pi_upper
#>      clay 8 0.10958704 0.05216559 -0.013764971 0.2329391 -0.178484453 0.3976585
#>      loam 8 0.08415367 0.03384675  0.004118819 0.1641885  0.004118819 0.1641885
#>     sandy 8 0.08643770 0.05277962 -0.038366262 0.2112417 -0.199888653 0.3727640
#> Omnibus subgroup test:
#>         QM df       QMp
#>  0.0975632  2 0.9074537
```
