# Explain agriPairMetaFlow results with deterministic scientific rules

Development-snapshot manual for apm_explain. The roxygen source in R/ is
authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_explain(...)
```

## Arguments

- ...:

  See the complete roxygen documentation and vignettes for arguments and
  method-specific assumptions.

## Value

An auditable agriPairMetaFlow result or output object as documented in
the function source.

## Examples

``` r
# Example 1: scientific interpretation of pooled yield response.
apm_explain(apm_fit(agri_effects_benchmark), audience="scientific", transform="percent")
#> [1] "The pooled meta-analytic estimate is 9.6% with an approximate 95% interval from 4.1% to 15.3%. This interval describes uncertainty in the estimated mean effect, not the range expected in every future agronomic setting."
#> [2] "The 95% prediction interval for a new true study effect extends from -6.9% to 29.0%. A wide interval indicates that response can differ materially among environments, years, crops, soils, or management contexts."       
#> [3] "Interpretation assumes the effect-size calculation, experimental-unit definition, sampling variances, dependence structure, and fitted heterogeneity model are appropriate for the included evidence."                     
#> [4] "Statistical significance alone is not treated as agronomic importance. Use prediction intervals, practical thresholds, dependence diagnostics, and sensitivity analyses where relevant."                                   
#> attr(,"tags")
#> attr(,"tags")$object_class
#> [1] "apm_model"
#> 
#> attr(,"tags")$audience
#> [1] "scientific"
#> 
#> attr(,"tags")$estimate
#> [1] 0.0914955
#> 
#> attr(,"tags")$ci
#> [1] 0.04035907 0.14263192
#> 
#> attr(,"tags")$prediction_interval
#> [1] -0.0717749  0.2547659
#> 
#> attr(,"tags")$measure
#> [1] "lnRR"
#> 
#> attr(,"class")
#> [1] "apm_explanation" "character"      
# Example 2: teaching interpretation of heterogeneity.
apm_explain(apm_heterogeneity(apm_fit(agri_effects_benchmark)), audience="teaching")
#> [1] "Heterogeneity describes real between-study dispersion beyond sampling error. I-squared is a relative descriptor and should be read together with tau-squared/tau and the prediction interval rather than used as a stand-alone quality score."
#> [2] "The reported heterogeneity table contains 1 summary row(s); inspect uncertainty around heterogeneity when available."                                                                                                                         
#> [3] "High heterogeneity does not by itself invalidate a meta-analysis, and low heterogeneity does not establish interchangeability of agronomic conditions."                                                                                       
#> attr(,"tags")
#> attr(,"tags")$object_class
#> [1] "apm_heterogeneity"
#> 
#> attr(,"tags")$audience
#> [1] "teaching"
#> 
#> attr(,"class")
#> [1] "apm_explanation" "character"      
# Example 3: extension-oriented wording without hiding uncertainty.
apm_explain(apm_fit(agri_effects_benchmark), audience="extension", transform="percent")
#> [1] "Across the available experiments, the average response is estimated at 9.6%. The plausible range for this average is 4.1% to 15.3%, so the result should be used with its uncertainty rather than as a guaranteed field response."
#> [2] "The 95% prediction interval for a new true study effect extends from -6.9% to 29.0%. A wide interval indicates that response can differ materially among environments, years, crops, soils, or management contexts."              
#> [3] "Interpretation assumes the effect-size calculation, experimental-unit definition, sampling variances, dependence structure, and fitted heterogeneity model are appropriate for the included evidence."                            
#> [4] "Statistical significance alone is not treated as agronomic importance. Use prediction intervals, practical thresholds, dependence diagnostics, and sensitivity analyses where relevant."                                          
#> attr(,"tags")
#> attr(,"tags")$object_class
#> [1] "apm_model"
#> 
#> attr(,"tags")$audience
#> [1] "extension"
#> 
#> attr(,"tags")$estimate
#> [1] 0.0914955
#> 
#> attr(,"tags")$ci
#> [1] 0.04035907 0.14263192
#> 
#> attr(,"tags")$prediction_interval
#> [1] -0.0717749  0.2547659
#> 
#> attr(,"tags")$measure
#> [1] "lnRR"
#> 
#> attr(,"class")
#> [1] "apm_explanation" "character"      
```
