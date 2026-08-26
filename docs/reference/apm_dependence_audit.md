# Audit effect-size dependence

Summarizes repeated clusters, shared controls, repeated outcomes/times,
and whether supplied covariance information addresses sampling
dependence.

## Usage

``` r
apm_dependence_audit(effects, plan = NULL, V = NULL, cluster = NULL)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_dependence_audit(es,cluster=study_id)
#> <apm_dependence_audit>
#>            source count
#>  repeated_cluster     8
#>    shared_control     8
#>  repeated_outcome     0
#>     repeated_time     0
#> V supplied: FALSE  | unresolved sources: 2 
#> Detected dependency should be addressed with an explicit V matrix and/or a hierarchical/cluster-robust model. 
V <- apm_vcov(es,cluster=experiment_id)
apm_dependence_audit(es,V=V,cluster=study_id)
#> <apm_dependence_audit>
#>            source count
#>  repeated_cluster     8
#>    shared_control     8
#>  repeated_outcome     0
#>     repeated_time     0
#> V supplied: TRUE  | unresolved sources: 1 
#> Detected dependency should be addressed with an explicit V matrix and/or a hierarchical/cluster-robust model. 

apm_dependence_audit(es)
#> <apm_dependence_audit>
#>            source count
#>  repeated_cluster     0
#>    shared_control     8
#>  repeated_outcome     0
#>     repeated_time     0
#> V supplied: FALSE  | unresolved sources: 1 
#> Detected dependency should be addressed with an explicit V matrix and/or a hierarchical/cluster-robust model. 
```
