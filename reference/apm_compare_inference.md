# Compare inferential approaches

Aligns conventional, robust, and wild-bootstrap results without
automatically selecting the most favorable inference.

## Usage

``` r
apm_compare_inference(model, robust = NULL, wild = NULL, methods = c("model", "CR2", "wild"), transform = c("auto", "none", "exp", "percent"))
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
fit <- apm_fit(es,mods=~rainfall)
apm_compare_inference(fit,methods="model")
#> <apm_inference_comparison> transform=exp
#>  method     term  estimate           se df  ci_lower ci_upper     p_value
#>   model  intrcpt 1.1873200 5.440005e-02 NA 1.0672406 1.320910 0.001598273
#>   model rainfall 0.9999129 5.435964e-05 NA 0.9998063 1.000019 0.108932159
apm_compare_inference(apm_fit(es),methods="model",transform="percent")
#> <apm_inference_comparison> transform=percent
#>  method    term estimate        se df ci_lower ci_upper     p_value
#>   model intrcpt  9.13125 0.0138803 NA 6.202367 12.14091 3.06743e-10

apm_compare_inference(fit,methods="model",transform="exp")
#> <apm_inference_comparison> transform=exp
#>  method     term  estimate           se df  ci_lower ci_upper     p_value
#>   model  intrcpt 1.1873200 5.440005e-02 NA 1.0672406 1.320910 0.001598273
#>   model rainfall 0.9999129 5.435964e-05 NA 0.9998063 1.000019 0.108932159
```
