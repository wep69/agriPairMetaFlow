# Data, Uncertainty, Effect Sizes, and True Pairing

## Data import and validation

``` r

f <- system.file("extdata","agri_uncertainty_mixed.csv",package="agriPairMetaFlow")
x <- apm_read(f)
apm_validate(x, "summary", strict=FALSE)
#> <apm_validation> PASS
apm_audit(x,"full")
#> <apm_audit>
#> No audit issues detected.
```

## Recovering reported uncertainty

``` r

u1 <- apm_recover_uncertainty(agri_uncertainty_mixed,mean=mean_yield,n=n,se=se_yield,method="se")
u2 <- apm_recover_uncertainty(agri_uncertainty_mixed,mean=mean_yield,n=n,cv=cv_percent,method="cv")
u3 <- apm_recover_uncertainty(agri_uncertainty_mixed,mean=mean_yield,n=n,mse=residual_mse,method="mse")
```

The provenance column distinguishes reported values from algebraically
reconstructed values. Missing uncertainty is never silently guessed.

## Independent and paired effects

``` r

p1 <- apm_plan(wheat_paired_blocks,study=study_id,treatment=treatment,control=control,response=mean_t,block=block_id,design="paired")
e1 <- apm_effect_size(wheat_paired_blocks,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
e2 <- apm_effect_size(pest_suppression_binary,"RR",event_t=event_t,event_c=event_c,n_t=n_t,n_c=n_c)
e3 <- apm_effect_size(covercrop_variability,"CVR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
```

Pairing is a property of the primary design, not of the existence of a
treatment and a control. The paired route therefore requires an explicit
correlation for continuous summary effects.

## Tables

``` r

apm_table(e1,"effects")
#>    study_id      treatment   control    yi    vi   sei
#> 1      WP01 seed_treatment untreated 1.081 0.001 0.029
#> 2      WP02 seed_treatment untreated 1.082 0.001 0.028
#> 3      WP03 seed_treatment untreated 1.074 0.000 0.022
#> 4      WP04 seed_treatment untreated 1.064 0.001 0.029
#> 5      WP05 seed_treatment untreated 1.062 0.001 0.032
#> 6      WP06 seed_treatment untreated 1.070 0.001 0.026
#> 7      WP07 seed_treatment untreated 1.080 0.001 0.024
#> 8      WP08 seed_treatment untreated 1.083 0.001 0.032
#> 9      WP09 seed_treatment untreated 1.077 0.001 0.025
#> 10     WP10 seed_treatment untreated 1.067 0.001 0.028
#> 11     WP11 seed_treatment untreated 1.062 0.001 0.027
#> 12     WP12 seed_treatment untreated 1.067 0.001 0.029
apm_table(e2,"effects")
#>    study_id    crop treatment  control    yi    vi   sei
#> 1      PS01   maize       IPM standard 0.720 0.107 0.327
#> 2      PS02 soybean       IPM standard 0.697 0.094 0.307
#> 3      PS03  cotton       IPM standard 0.614 0.116 0.341
#> 4      PS04   maize       IPM standard 0.711 0.095 0.308
#> 5      PS05 soybean       IPM standard 0.712 0.102 0.319
#> 6      PS06  cotton       IPM standard 0.685 0.117 0.342
#> 7      PS07   maize       IPM standard 0.667 0.103 0.321
#> 8      PS08 soybean       IPM standard 0.742 0.094 0.306
#> 9      PS09  cotton       IPM standard 0.733 0.106 0.326
#> 10     PS10   maize       IPM standard 0.676 0.112 0.335
#> 11     PS11 soybean       IPM standard 0.662 0.099 0.314
#> 12     PS12  cotton       IPM standard 0.700 0.111 0.333
#> 13     PS13   maize       IPM standard 0.717 0.101 0.318
#> 14     PS14 soybean       IPM standard 0.692 0.090 0.300
#> 15     PS15  cotton       IPM standard 0.635 0.124 0.352
#> 16     PS16   maize       IPM standard 0.688 0.106 0.325
apm_table(e3,"effects")
#>    study_id    crop  treatment control    yi    vi   sei
#> 1      CV01 soybean cover_crop  fallow 0.827 0.256 0.506
#> 2      CV02  cotton cover_crop  fallow 0.857 0.205 0.453
#> 3      CV03   maize cover_crop  fallow 0.887 0.338 0.582
#> 4      CV04 soybean cover_crop  fallow 0.767 0.257 0.507
#> 5      CV05  cotton cover_crop  fallow 0.835 0.206 0.454
#> 6      CV06   maize cover_crop  fallow 0.866 0.339 0.582
#> 7      CV07 soybean cover_crop  fallow 0.895 0.255 0.505
#> 8      CV08  cotton cover_crop  fallow 0.774 0.207 0.455
#> 9      CV09   maize cover_crop  fallow 0.804 0.340 0.583
#> 10     CV10 soybean cover_crop  fallow 0.874 0.256 0.505
#> 11     CV11  cotton cover_crop  fallow 0.904 0.205 0.452
#> 12     CV12   maize cover_crop  fallow 0.782 0.341 0.584
#> 13     CV13 soybean cover_crop  fallow 0.812 0.256 0.506
#> 14     CV14  cotton cover_crop  fallow 0.841 0.205 0.453
#> 15     CV15   maize cover_crop  fallow 0.913 0.338 0.582
#> 16     CV16 soybean cover_crop  fallow 0.789 0.257 0.507
#> 17     CV17  cotton cover_crop  fallow 0.820 0.206 0.454
#> 18     CV18   maize cover_crop  fallow 0.849 0.339 0.582
```
