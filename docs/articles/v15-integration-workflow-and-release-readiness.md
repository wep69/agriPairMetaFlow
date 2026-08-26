# agriPairMetaFlow 1.0: Integrated Workflow, Capabilities, and Release Readiness

## 1. Why version 1.0 adds integration rather than another estimator

The stable 1.0 layer does not introduce a new meta-analytic estimator.
Earlier releases already cover effect sizes, dependence, multilevel and
robust inference, quantitative moderators, dose-response, multivariate
outcomes, Bayesian sensitivity, diagnostic analysis, publication-bias
sensitivity, visualization, reporting, and export. Version 1.0 connects
those capabilities without concealing scientific decisions.

[`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md)
therefore retains every intermediate object. Its `routing_log` states
whether a decision was supplied by the analyst, inferred from explicit
design information, or derived from another package object. Automatic
routing is a convenience, not a substitute for understanding the
experimental design.

## 2. Three agronomic integrated workflows

A maize nitrogen synthesis with several doses sharing the same zero-N
control must not treat the contrasts as independent. The optional CR2
step is executed only when its backend is installed.

``` r

w_maize <- apm_workflow(
  maize_n_shared,
  measure="lnRR",
  dependence="shared_control",
  model="multilevel",
  robust=TRUE
)
#> Warning: Model does not contain an '~ inner | outer' term, so 'struct' argument
#> is disregaded.
w_maize$routing_log
#>                  step         decision
#> 1                plan        auto plan
#> 2          dependence   shared_control
#> 3         effect_size             lnRR
#> 4 sampling_covariance shared-control V
#> 5               model       multilevel
#> 6              robust              CR2
#>                                                                       reason
#> 1   Conventional role names were inspected; no scientific role was invented.
#> 2                                                             User override.
#> 3                  Computed using design independent and backend measure ROM
#> 4 Reused arms induce covariance among contrasts and are retained explicitly.
#> 5                                                             User override.
#> 6  Cluster-robust inference requested; study_id used as independent cluster.
#>    source
#> 1    auto
#> 2    user
#> 3 derived
#> 4 derived
#> 5    user
#> 6    user
```

A climatic moderator analysis illustrates automatic random-effects
routing and a five-percent agronomic relevance threshold.

``` r

w_irrig <- apm_workflow(
  irrigation_climate,
  measure="lnRR",
  moderators=~rainfall+mean_temp,
  threshold=5
)
w_irrig$routing_log
#>          step              decision
#> 1        plan             auto plan
#> 2  dependence           independent
#> 3 effect_size                  lnRR
#> 4       model                random
#> 5  moderators ~rainfall + mean_temp
#> 6   threshold                     5
#>                                                                              reason
#> 1          Conventional role names were inspected; no scientific role was invented.
#> 2 No explicit dependence source requiring a sampling covariance model was detected.
#> 3                         Computed using design independent and backend measure ROM
#> 4               Random-effects synthesis selected as the default cross-study model.
#> 5                                            Meta-regression requested by the user.
#> 6                                   Practical threshold evaluated on percent scale.
#>    source
#> 1    auto
#> 2    auto
#> 3 derived
#> 4    auto
#> 5    user
#> 6    user
```

Paired analysis is only selected when paired sample-size/correlation
information is explicit.

``` r

w_pair <- apm_workflow(
  wheat_paired_blocks,
  measure="lnRR",
  dependence="paired",
  model="random"
)
w_pair$routing_log
#>                  step                      decision
#> 1                plan                     auto plan
#> 2          dependence                        paired
#> 3         effect_size                          lnRR
#> 4 sampling_covariance paired variance encoded in vi
#> 5               model                        random
#>                                                                                                                            reason
#> 1                                                        Conventional role names were inspected; no scientific role was invented.
#> 2                                                                                                                  User override.
#> 3                                                                           Computed using design paired and backend measure ROMC
#> 4 The treatment-control correlation is already used by the paired effect-size variance. No between-effect covariance is invented.
#> 5                                                                                                                  User override.
#>    source
#> 1    auto
#> 2    user
#> 3 derived
#> 4 derived
#> 5    user
```

## 3. Capability registry

The registry separates the stable public feature from the package that
happens to implement a specialized calculation. This allows an optional
backend to be updated or replaced without changing the scientific
meaning of the user-facing workflow.

``` r

apm_capabilities()
#> Loading required namespace: runjags
#> <apm_capabilities>
#> <apm_capabilities>
#>           feature                  backend  core installed version    status
#>              core         agriPairMetaFlow  TRUE      TRUE   1.0.0 AVAILABLE
#>      effect-sizes                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>    random-effects                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>    shared-control                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>        multilevel                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>            robust             clubSandwich FALSE      TRUE   0.7.0 AVAILABLE
#>    wild-bootstrap                 wildmeta FALSE      TRUE   0.3.2 AVAILABLE
#>   meta-regression                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>     dose-response               dosresmeta FALSE      TRUE   2.2.0 AVAILABLE
#>      multivariate                  mixmeta FALSE      TRUE   1.2.2 AVAILABLE
#>          bayesian                bayesmeta FALSE      TRUE     3.5 AVAILABLE
#>          bayesian                    RoBMA FALSE      TRUE   4.0.0 AVAILABLE
#>          bayesian                     brms FALSE      TRUE  2.23.0 AVAILABLE
#>  publication-bias                  metafor  TRUE      TRUE   5.0.1 AVAILABLE
#>  publication-bias PublicationBias/metasens FALSE      TRUE   2.4.0 AVAILABLE
#>  moderator-screen               metaforest FALSE      TRUE   0.1.5 AVAILABLE
#>       interactive       plotly/htmlwidgets FALSE      TRUE  4.12.1 AVAILABLE
#>           reports          rmarkdown/knitr FALSE      TRUE    2.31 AVAILABLE
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
```

``` r

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
```

``` r

apm_capabilities("dose-response", installed=TRUE)
#> <apm_capabilities>
#> <apm_capabilities>
#>        feature    backend  core installed version    status
#>  dose-response dosresmeta FALSE      TRUE   2.2.0 AVAILABLE
#>                 validation_status
#>  tier-2-local-validation-required
```

An unavailable optional backend is not a failure of the core package. It
means that the corresponding optional capability cannot be validated or
used until the dependency is installed.

## 4. Non-mutating installation doctor

The doctor does not install R packages, JAGS, CmdStan, Pandoc, Quarto,
or system libraries. It only reports what is present and how the result
should be interpreted.

``` r

apm_doctor()
#> <apm_doctor> CORE PASS 
#>                              check  status            scope
#>                          R version    PASS             core
#>                                cli    PASS     core-backend
#>                           generics    PASS     core-backend
#>                            ggplot2    PASS     core-backend
#>                            metafor    PASS     core-backend
#>                              rlang    PASS     core-backend
#>                            splines    PASS     core-backend
#>                              stats    PASS     core-backend
#>                             tibble    PASS     core-backend
#>                              utils    PASS     core-backend
#>                              vctrs    PASS     core-backend
#>                  teaching datasets    PASS             core
#>                1.0 integration API    PASS             core
#>              backend: clubSandwich    PASS optional-backend
#>                  backend: wildmeta    PASS optional-backend
#>                backend: dosresmeta    PASS optional-backend
#>                   backend: mixmeta    PASS optional-backend
#>                 backend: bayesmeta    PASS optional-backend
#>                     backend: RoBMA    PASS optional-backend
#>                      backend: brms    PASS optional-backend
#>  backend: PublicationBias/metasens    PASS optional-backend
#>                backend: metaforest    PASS optional-backend
#>        backend: plotly/htmlwidgets    PASS optional-backend
#>           backend: rmarkdown/knitr    PASS optional-backend
#>                 backend: openxlsx2    PASS optional-backend
#>                  backend: cmdstanr    PASS optional-backend
#>                    rendering stack NOT RUN           render
#>                core smoke examples NOT RUN            smoke
#>                                                                  detail
#>                                                                 R 4.6.0
#>                                                           version 3.6.6
#>                                                           version 0.1.4
#>                                                           version 4.0.3
#>                                                           version 5.0.1
#>                                                           version 1.3.0
#>                                                           version 4.6.0
#>                                                           version 4.6.0
#>                                                           version 3.3.1
#>                                                           version 4.6.0
#>                                                           version 0.7.3
#>                  11 frozen teaching datasets are present and non-empty.
#>     apm_workflow(), apm_capabilities(), and apm_doctor() are available.
#>                                               AVAILABLE ; version 0.7.0
#>                                               AVAILABLE ; version 0.3.2
#>                                               AVAILABLE ; version 2.2.0
#>                                               AVAILABLE ; version 1.2.2
#>                                                 AVAILABLE ; version 3.5
#>                                               AVAILABLE ; version 4.0.0
#>                                              AVAILABLE ; version 2.23.0
#>                                               AVAILABLE ; version 2.4.0
#>                                               AVAILABLE ; version 0.1.5
#>                                              AVAILABLE ; version 4.12.1
#>                                                AVAILABLE ; version 2.31
#>                                                AVAILABLE ; version 1.29
#>                                               AVAILABLE ; version 0.9.0
#>                                                      check_render=FALSE
#>  check_examples=FALSE; formal testthat remains a separate release gate.
#>  remediation
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#> Environment mutated: FALSE
```

``` r

apm_doctor(full=TRUE, check_backends=TRUE)
#> <apm_doctor> CORE PASS 
#>                              check  status            scope
#>                          R version    PASS             core
#>                                cli    PASS     core-backend
#>                           generics    PASS     core-backend
#>                            ggplot2    PASS     core-backend
#>                            metafor    PASS     core-backend
#>                              rlang    PASS     core-backend
#>                            splines    PASS     core-backend
#>                              stats    PASS     core-backend
#>                             tibble    PASS     core-backend
#>                              utils    PASS     core-backend
#>                              vctrs    PASS     core-backend
#>                  teaching datasets    PASS             core
#>                1.0 integration API    PASS             core
#>              backend: clubSandwich    PASS optional-backend
#>                  backend: wildmeta    PASS optional-backend
#>                backend: dosresmeta    PASS optional-backend
#>                   backend: mixmeta    PASS optional-backend
#>                 backend: bayesmeta    PASS optional-backend
#>                     backend: RoBMA    PASS optional-backend
#>                      backend: brms    PASS optional-backend
#>  backend: PublicationBias/metasens    PASS optional-backend
#>                backend: metaforest    PASS optional-backend
#>        backend: plotly/htmlwidgets    PASS optional-backend
#>           backend: rmarkdown/knitr    PASS optional-backend
#>                 backend: openxlsx2    PASS optional-backend
#>                  backend: cmdstanr    PASS optional-backend
#>                    rendering stack NOT RUN           render
#>                core smoke examples NOT RUN            smoke
#>                             locale    PASS  reproducibility
#>                           platform    PASS  reproducibility
#>                temporary directory    PASS  reproducibility
#>                                                                                                                                            detail
#>                                                                                                                                           R 4.6.0
#>                                                                                                                                     version 3.6.6
#>                                                                                                                                     version 0.1.4
#>                                                                                                                                     version 4.0.3
#>                                                                                                                                     version 5.0.1
#>                                                                                                                                     version 1.3.0
#>                                                                                                                                     version 4.6.0
#>                                                                                                                                     version 4.6.0
#>                                                                                                                                     version 3.3.1
#>                                                                                                                                     version 4.6.0
#>                                                                                                                                     version 0.7.3
#>                                                                                            11 frozen teaching datasets are present and non-empty.
#>                                                                               apm_workflow(), apm_capabilities(), and apm_doctor() are available.
#>                                                                                                                         AVAILABLE ; version 0.7.0
#>                                                                                                                         AVAILABLE ; version 0.3.2
#>                                                                                                                         AVAILABLE ; version 2.2.0
#>                                                                                                                         AVAILABLE ; version 1.2.2
#>                                                                                                                           AVAILABLE ; version 3.5
#>                                                                                                                         AVAILABLE ; version 4.0.0
#>                                                                                                                        AVAILABLE ; version 2.23.0
#>                                                                                                                         AVAILABLE ; version 2.4.0
#>                                                                                                                         AVAILABLE ; version 0.1.5
#>                                                                                                                        AVAILABLE ; version 4.12.1
#>                                                                                                                          AVAILABLE ; version 2.31
#>                                                                                                                          AVAILABLE ; version 1.29
#>                                                                                                                         AVAILABLE ; version 0.9.0
#>                                                                                                                                check_render=FALSE
#>                                                                            check_examples=FALSE; formal testthat remains a separate release gate.
#>  LC_COLLATE=Portuguese_Brazil.utf8;LC_CTYPE=Portuguese_Brazil.utf8;LC_MONETARY=Portuguese_Brazil.utf8;LC_NUMERIC=C;LC_TIME=Portuguese_Brazil.utf8
#>                                                                                                                                x86_64-w64-mingw32
#>                                                                                                C:\\Users\\wep69\\AppData\\Local\\Temp\\RtmpS64K5D
#>  remediation
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#>         <NA>
#> Environment mutated: FALSE
```

The deepest check is appropriate on the release-validation computer. It
remains a diagnostic convenience and is not a substitute for `testthat`,
numerical golden tests, vignette rendering, `R CMD build`, or
`R CMD check --as-cran`.

``` r

apm_doctor(full=TRUE, check_render=TRUE, check_examples=TRUE)
```

## 5. Reading the routing log

For every integrated analysis inspect at least:

1.  the detected or declared dependence structure;
2.  the effect-size design and backend measure;
3.  whether a full sampling covariance matrix was created;
4.  the selected model family;
5.  moderator and relevance-threshold decisions;
6.  any robust or Bayesian sensitivity route.

The workflow is intentionally reversible. Every component can be
recomputed manually using the lower-level function recorded by the
route. During local validation, the manual and orchestrated results must
agree numerically within the tolerance appropriate to the deterministic
backend.

## 6. Release principle

Static source auditing is useful for catching missing files,
documentation coverage, obvious source inconsistencies, and packaging
divergence. It is not runtime validation. The formal 1.0 release exists
only after local R validation has regenerated documentation, executed
tests and examples, rendered normal vignettes, built a source tarball,
frozen that tarball, and run `R CMD check --as-cran` on that exact
immutable artifact.
