# Bayesian computational diagnostics

Expose backend-appropriate convergence, effective-sample-size, Monte
Carlo, and posterior predictive diagnostics.

## Usage

``` r
apm_bayes_diagnostics(...)
```

## Arguments

- ...:

  Arguments documented in the function source. Regenerate this manual
  with roxygen2 during local validation.

## Value

An auditable agriPairMetaFlow result object; see the corresponding class
documentation and vignettes.

## Examples

``` r
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d1<-apm_bayes_diagnostics(b,plot=FALSE) }
#>   Generating n=10 Monte Carlo samples.
#>   /!\  Caution: a sample size of  n >> 100  will usually be appropriate.
#>   Sampling progress (using 7 parallel processes):
#>   |                                                                              |                                                                      |   0%  |                                                                              |=================================================                     |  70%  |                                                                              |======================================================================| 100%
#>   (computation time: 48.0 seconds = 0.8 minutes.)
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d2<-apm_bayes_diagnostics(b,checks="convergence",plot=FALSE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d3<-apm_bayes_diagnostics(b,checks="ppc",plot=TRUE) }
#>   Generating n=10 Monte Carlo samples.
#>   /!\  Caution: a sample size of  n >> 100  will usually be appropriate.
#>   Sampling progress (using 7 parallel processes):
#>   |                                                                              |                                                                      |   0%  |                                                                              |=================================================                     |  70%  |                                                                              |======================================================================| 100%
#>   (computation time: 44.5 seconds = 0.7 minutes.)
```
