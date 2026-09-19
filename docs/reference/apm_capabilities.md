# Report agriPairMetaFlow capabilities and optional backends

Reports the stable feature registry, backend policy, installation state,
and validation tier without installing software.

## Usage

``` r
apm_capabilities(feature = NULL, installed = TRUE, detail = c("summary", "full"))
```

## Arguments

- feature:

  Optional exact feature filter.

- installed:

  Inspect local installation state.

- detail:

  Summary or full registry.

## Value

An apm_capabilities data frame.

## Examples

``` r
# Example 1: complete registry.
apm_capabilities()
#> <apm_capabilities>
#>           feature                  backend  core installed version    status
#>              core         agriPairMetaFlow  TRUE      TRUE   1.0.2 AVAILABLE
#>      effect-sizes                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>    random-effects                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>    shared-control                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>        multilevel                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>            robust             clubSandwich FALSE      TRUE   0.7.0 AVAILABLE
#>    wild-bootstrap                 wildmeta FALSE      TRUE   0.3.2 AVAILABLE
#>   meta-regression                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>     dose-response               dosresmeta FALSE      TRUE   2.2.0 AVAILABLE
#>      multivariate                  mixmeta FALSE      TRUE   1.2.2 AVAILABLE
#>          bayesian                bayesmeta FALSE      TRUE     3.5 AVAILABLE
#>          bayesian                    RoBMA FALSE      TRUE   4.0.0 AVAILABLE
#>          bayesian                     brms FALSE      TRUE  2.23.0 AVAILABLE
#>  publication-bias                  metafor  TRUE      TRUE   5.2.1 AVAILABLE
#>  publication-bias PublicationBias/metasens FALSE      TRUE   2.4.0 AVAILABLE
#>  moderator-screen               metaforest FALSE      TRUE   0.1.5 AVAILABLE
#>       interactive       plotly/htmlwidgets FALSE      TRUE  4.12.1 AVAILABLE
#>           reports          rmarkdown/knitr FALSE      TRUE    2.32 AVAILABLE
#>       xlsx-export                openxlsx2 FALSE      TRUE    1.29 AVAILABLE
#>           cmdstan                 cmdstanr FALSE      TRUE   0.9.0 AVAILABLE
#>                             validation_status
#>  core-runtime-validation-required-for-release
#>  core-runtime-validation-required-for-release
#>  core-runtime-validation-required-for-release
#>  core-runtime-validation-required-for-release
#>  core-runtime-validation-required-for-release
#>              tier-2-local-validation-required
#>              tier-3-local-validation-required
#>  core-runtime-validation-required-for-release
#>              tier-2-local-validation-required
#>              tier-2-local-validation-required
#>              tier-3-local-validation-required
#>              tier-3-local-validation-required
#>              tier-3-local-validation-required
#>  core-runtime-validation-required-for-release
#>              tier-2-local-validation-required
#>              tier-3-local-validation-required
#>               smoke-local-validation-required
#>              render-local-validation-required
#>          round-trip-local-validation-required
#>              system-local-validation-required
# Example 2: Bayesian capability routes.
apm_capabilities("bayesian", detail="full")
#> <apm_capabilities>
#>   feature                           capability   backend   package
#>  bayesian normal-normal Bayesian meta-analysis bayesmeta bayesmeta
#>  bayesian      robust Bayesian model averaging     RoBMA     RoBMA
#>  bayesian   general Bayesian multilevel models      brms      brms
#>  minimum_version  core validation_tier installed version version_ok
#>              3.5 FALSE          tier-3      TRUE     3.5       TRUE
#>            4.0.0 FALSE          tier-3      TRUE   4.0.0       TRUE
#>             <NA> FALSE          tier-3      TRUE  2.23.0       TRUE
#>  system_ready    status                validation_status
#>          TRUE AVAILABLE tier-3-local-validation-required
#>          TRUE AVAILABLE tier-3-local-validation-required
#>          TRUE AVAILABLE tier-3-local-validation-required
#>                                                          notes
#>  Optional capability; absence must not break the core package.
#>  Optional capability; absence must not break the core package.
#>  Optional capability; absence must not break the core package.
# Example 3: dose-response backend state.
apm_capabilities("dose-response", installed=TRUE)
#> <apm_capabilities>
#>        feature    backend  core installed version    status
#>  dose-response dosresmeta FALSE      TRUE   2.2.0 AVAILABLE
#>                 validation_status
#>  tier-2-local-validation-required
```
