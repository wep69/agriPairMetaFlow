# Predict treatment effects for explicit agronomic contexts

Generates model-based predictions for combinations of quantitative and
qualitative agronomic moderators, labels interpolation versus
extrapolation, and optionally evaluates a practical-effect threshold.
Predictive threshold probabilities are returned only when the relevant
heterogeneity variance is identifiable; the function does not guess a
predictive variance for ambiguous multilevel structures.

## Usage

``` r
apm_predict_context(model, newdata, level = 0.95, prediction = TRUE, threshold = NULL, transform = c("auto", "none", "exp", "percent"))
```

## Arguments

- model:

  An `apm_metareg` or `apm_curve` object.

- newdata:

  Data frame containing moderator contexts.

- level:

  Confidence level.

- prediction:

  Include a prediction interval where supported by the fitted backend.

- threshold:

  Optional practical threshold on the displayed output scale.

- transform:

  Output transformation.

## Value

An `apm_prediction` retaining context columns, support flags, and the
basis used for any threshold probability.

## Examples

``` r
# Example 1: expected irrigation effect at 800 mm rainfall and 24 C.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_m <- apm_metareg(irr_es,~rainfall+mean_temp)
apm_predict_context(irr_m,data.frame(rainfall=800,mean_temp=24))
#> <apm_prediction> transform=auto
#>  rainfall mean_temp       support      pred       se   ci_lower ci_upper
#>       800        24 interpolation 0.7497179 6.332663 1.1814e-06 475771.8
#>    pi_lower pi_upper threshold_relation probability_above_threshold
#>  1.1814e-06 475771.8               <NA>                          NA
#>  probability_basis
#>      not requested
# Example 2: crop/site context for an inoculant.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_m <- apm_metareg(bio_es,~crop+site)
apm_predict_context(bio_m,data.frame(crop="maize",site="Areia"),transform="percent")
#> <apm_prediction> transform=percent
#>   crop  site       support     pred         se ci_lower ci_upper pi_lower
#>  maize Areia interpolation 9.414307 0.02864681 3.023482 16.20157 3.023482
#>  pi_upper threshold_relation probability_above_threshold probability_basis
#>  16.20157               <NA>                          NA     not requested
# Example 3: practical 5 percent threshold along an N-rate curve.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
  m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_curve <- apm_metareg_curve(mz_es,N_rate,"quadratic")
apm_predict_context(mz_curve,data.frame(N_rate=c(60,120)),threshold=5,transform="percent")
#> Warning: Extra argument ('prob') disregarded.
#> <apm_prediction> transform=percent
#>  N_rate       support      pred         se ci_lower ci_upper pi_lower pi_upper
#>      60 interpolation  8.238373 0.01794283 4.273973 12.35350 4.273973 12.35350
#>     120 interpolation 10.072455 0.02013853 5.557779 14.78022 5.557779 14.78022
#>  threshold_relation probability_above_threshold
#>            overlaps                          NA
#>               above                          NA
#>                                               probability_basis
#>  unavailable: backend predictive-probability calculation failed
#>  unavailable: backend predictive-probability calculation failed
```
