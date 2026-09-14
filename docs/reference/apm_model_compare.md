# Compare prespecified meta-regression models

Compares compatible candidate models without automatic stepwise
selection. When fixed-effect design matrices differ, likelihood criteria
are calculated from ML refits by default. Nesting is assessed from
fixed-effect column spaces rather than coefficient labels, protecting
comparisons of spline bases with similar names but different knots.

## Usage

``` r
apm_model_compare(..., criterion = c("AICc", "AIC", "BIC", "LRT"), refit_ml = TRUE, weights = TRUE)
```

## Arguments

- ...:

  Two or more `apm_model` objects fitted to the same effects.

- criterion:

  `"AICc"`, `"AIC"`, `"BIC"`, or `"LRT"`.

- refit_ml:

  Refit REML candidate models by maximum likelihood when fixed-effect
  design matrices differ.

- weights:

  Calculate normalized information-criterion weights.

## Value

An `apm_model_comparison` with criteria, deltas, weights, fixed-design
hashes, column-space nesting information, and provenance.

## Examples

``` r
# Example 1: linear versus quadratic rainfall association.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irrig_lin <- apm_metareg_curve(irr_es,rainfall,"linear")
irrig_quad <- apm_metareg_curve(irr_es,rainfall,"quadratic")
apm_model_compare(irrig_lin,irrig_quad,criterion="AICc")
#> <apm_model_comparison> criterion=AICc
#>   model  k p   logLik       AIC      AICc       BIC    delta   weight
#>  model1 20 3 36.04221 -66.08443 -64.58443 -63.09723 0.000000 0.829409
#>  model2 20 4 36.04410 -64.08821 -61.42154 -60.10528 3.162889 0.170591
# Example 2: linear versus spline N-rate relationship.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
  m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_lin <- apm_metareg_curve(mz_es,N_rate,"linear",V=mz_V,random=~1|study_id/effect_id)
mz_ns <- apm_metareg_curve(mz_es,N_rate,"ns",df=3,V=mz_V,random=~1|study_id/effect_id)
#> Error in apm_metareg_curve(mz_es, N_rate, "ns", df = 3, V = mz_V, random = ~1 |     study_id/effect_id): Insufficient unique moderator values for the requested curve form.
apm_model_compare(mz_lin,mz_ns,criterion="AIC")
#> Error: object 'mz_ns' not found
# Example 3: main effects versus a prespecified crop-by-site interaction.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_main <- apm_metareg(bio_es,~crop+site)
bio_int <- apm_metareg(bio_es,~crop*site)
apm_model_compare(bio_main,bio_int,criterion="LRT")
#> <apm_model_comparison> criterion=LRT
#>   model  k  p   logLik       AIC      AICc       BIC        LRT LRT_df
#>  model1 24  7 39.41109 -64.82219 -57.82219 -56.57581 0.00000000      0
#>  model2 24 13 39.45987 -52.91973 -16.51973 -37.60503 0.09754407      6
#>      LRT_p delta weight
#>         NA    NA     NA
#>  0.9999814    NA     NA
```
