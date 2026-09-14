# Run an auditable end-to-end agronomic meta-analysis workflow

Consolidated 1.0 development-snapshot manual. The roxygen source in
R/workflow.R is authoritative and must be regenerated locally with
roxygen2 before formal release.

## Usage

``` r
apm_workflow(data, plan = NULL, measure = "lnRR", dependence = c("auto", "independent", "shared_control", "paired"), model = c("auto", "random", "multilevel"), moderators = NULL, robust = FALSE, bayes = FALSE, threshold = NULL, seed = NULL, ...)
```

## Arguments

- data:

  Treatment-control summaries or an apm_effects object.

- plan:

  Optional explicit apm_plan.

- measure:

  Effect-size measure.

- dependence:

  Dependence routing.

- model:

  Model routing.

- moderators:

  Optional moderator formula.

- robust:

  Request CR2 sensitivity.

- bayes:

  Request Bayesian sensitivity fit.

- threshold:

  Optional agronomic relevance threshold.

- seed:

  Optional reproducibility seed.

- ...:

  Arguments forwarded to the selected frequentist fitting function.

## Value

An apm_workflow retaining every intermediate object and the routing log.

## Examples

``` r
# Example 1: shared zero-N control.
if (requireNamespace("clubSandwich", quietly=TRUE)) apm_workflow(maize_n_shared, measure="lnRR", dependence="shared_control", model="multilevel", robust=TRUE)
#> <apm_workflow> measure=lnRR | dependence=shared_control | model=multilevel
#> effects: 24 | data hash: 7389bb01e2c250f0fcacce43a835ce9d 
#>                 step         decision
#>                 plan        auto plan
#>           dependence   shared_control
#>          effect_size             lnRR
#>  sampling_covariance shared-control V
#>                model       multilevel
#>               robust              CR2
#>                                                                      reason
#>    Conventional role names were inspected; no scientific role was invented.
#>                                                              User override.
#>                   Computed using design independent and backend measure ROM
#>  Reused arms induce covariance among contrasts and are retained explicitly.
#>                                                              User override.
#>   Cluster-robust inference requested; study_id used as independent cluster.
#>   source
#>     auto
#>     user
#>  derived
#>  derived
#>     user
#>     user
# Example 2: climatic moderators.
apm_workflow(irrigation_climate, measure="lnRR", moderators=~rainfall+mean_temp, threshold=5)
#> <apm_workflow> measure=lnRR | dependence=independent | model=random
#> effects: 20 | data hash: beda0c1a9a83833f64c1bbbc63a750b6 
#>         step              decision
#>         plan             auto plan
#>   dependence           independent
#>  effect_size                  lnRR
#>        model                random
#>   moderators ~rainfall + mean_temp
#>    threshold                     5
#>                                                                             reason
#>           Conventional role names were inspected; no scientific role was invented.
#>  No explicit dependence source requiring a sampling covariance model was detected.
#>                          Computed using design independent and backend measure ROM
#>                Random-effects synthesis selected as the default cross-study model.
#>                                             Meta-regression requested by the user.
#>                                    Practical threshold evaluated on percent scale.
#>   source
#>     auto
#>     auto
#>  derived
#>     auto
#>     user
#>     user
# Example 3: genuinely paired wheat summaries.
apm_workflow(wheat_paired_blocks, measure="lnRR", dependence="paired", model="random")
#> <apm_workflow> measure=lnRR | dependence=paired | model=random
#> effects: 12 | data hash: b01e53e9f6ab4e012ff35ff5a0891373 
#>                 step                      decision
#>                 plan                     auto plan
#>           dependence                        paired
#>          effect_size                          lnRR
#>  sampling_covariance paired variance encoded in vi
#>                model                        random
#>                                                                                                                           reason
#>                                                         Conventional role names were inspected; no scientific role was invented.
#>                                                                                                                   User override.
#>                                                                            Computed using design paired and backend measure ROMC
#>  The treatment-control correlation is already used by the paired effect-size variance. No between-effect covariance is invented.
#>                                                                                                                   User override.
#>   source
#>     auto
#>     user
#>  derived
#>  derived
#>     user
```
