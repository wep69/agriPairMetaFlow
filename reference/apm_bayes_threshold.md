# Bayesian agronomic relevance probability

Calculate posterior or predictive probability relative to a user-defined
agronomic threshold without automatic decisions.

## Usage

``` r
apm_bayes_threshold(...)
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
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t1<-apm_bayes_threshold(b,5,scale="percent") }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t2<-apm_bayes_threshold(b,10,scale="percent",predictive=TRUE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t3<-apm_bayes_threshold(b,0,rope=c(-.05,.05)) }
```
