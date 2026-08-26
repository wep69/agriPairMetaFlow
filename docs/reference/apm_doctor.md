# Diagnose the agriPairMetaFlow installation without changing it

Inspects core dependencies, optional backends, rendering tools, frozen
data, and smoke examples while never installing or modifying software.

## Usage

``` r
apm_doctor(full = FALSE, check_backends = TRUE, check_render = FALSE, check_examples = FALSE)
```

## Arguments

- full:

  Run extended reproducibility checks.

- check_backends:

  Inspect optional backends.

- check_render:

  Inspect Pandoc and Quarto.

- check_examples:

  Run small core smoke examples.

## Value

An apm_doctor object with PASS, WARN, FAIL, and NOT RUN checks plus
remediation guidance.

## Examples

``` r
# Example 1: core diagnosis.
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
# Example 2: extended backend diagnosis.
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
#>                                                                                                                       detail
#>                                                                                                                      R 4.6.0
#>                                                                                                                version 3.6.6
#>                                                                                                                version 0.1.4
#>                                                                                                                version 4.0.3
#>                                                                                                                version 5.0.1
#>                                                                                                                version 1.3.0
#>                                                                                                                version 4.6.0
#>                                                                                                                version 4.6.0
#>                                                                                                                version 3.3.1
#>                                                                                                                version 4.6.0
#>                                                                                                                version 0.7.3
#>                                                                       11 frozen teaching datasets are present and non-empty.
#>                                                          apm_workflow(), apm_capabilities(), and apm_doctor() are available.
#>                                                                                                    AVAILABLE ; version 0.7.0
#>                                                                                                    AVAILABLE ; version 0.3.2
#>                                                                                                    AVAILABLE ; version 2.2.0
#>                                                                                                    AVAILABLE ; version 1.2.2
#>                                                                                                      AVAILABLE ; version 3.5
#>                                                                                                    AVAILABLE ; version 4.0.0
#>                                                                                                   AVAILABLE ; version 2.23.0
#>                                                                                                    AVAILABLE ; version 2.4.0
#>                                                                                                    AVAILABLE ; version 0.1.5
#>                                                                                                   AVAILABLE ; version 4.12.1
#>                                                                                                     AVAILABLE ; version 2.31
#>                                                                                                     AVAILABLE ; version 1.29
#>                                                                                                    AVAILABLE ; version 0.9.0
#>                                                                                                           check_render=FALSE
#>                                                       check_examples=FALSE; formal testthat remains a separate release gate.
#>  LC_COLLATE=C;LC_CTYPE=Portuguese_Brazil.utf8;LC_MONETARY=Portuguese_Brazil.utf8;LC_NUMERIC=C;LC_TIME=Portuguese_Brazil.utf8
#>                                                                                                           x86_64-w64-mingw32
#>                                                                           C:\\Users\\wep69\\AppData\\Local\\Temp\\RtmpcjLDfO
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
# Example 3: release-machine diagnosis.
apm_doctor(full=TRUE, check_render=TRUE, check_examples=TRUE)
#> <apm_doctor> CORE PASS 
#>                              check status            scope
#>                          R version   PASS             core
#>                                cli   PASS     core-backend
#>                           generics   PASS     core-backend
#>                            ggplot2   PASS     core-backend
#>                            metafor   PASS     core-backend
#>                              rlang   PASS     core-backend
#>                            splines   PASS     core-backend
#>                              stats   PASS     core-backend
#>                             tibble   PASS     core-backend
#>                              utils   PASS     core-backend
#>                              vctrs   PASS     core-backend
#>                  teaching datasets   PASS             core
#>                1.0 integration API   PASS             core
#>              backend: clubSandwich   PASS optional-backend
#>                  backend: wildmeta   PASS optional-backend
#>                backend: dosresmeta   PASS optional-backend
#>                   backend: mixmeta   PASS optional-backend
#>                 backend: bayesmeta   PASS optional-backend
#>                     backend: RoBMA   PASS optional-backend
#>                      backend: brms   PASS optional-backend
#>  backend: PublicationBias/metasens   PASS optional-backend
#>                backend: metaforest   PASS optional-backend
#>        backend: plotly/htmlwidgets   PASS optional-backend
#>           backend: rmarkdown/knitr   PASS optional-backend
#>                 backend: openxlsx2   PASS optional-backend
#>                  backend: cmdstanr   PASS optional-backend
#>                             Pandoc   PASS           render
#>                             Quarto   PASS           render
#>                     core smoke fit   PASS            smoke
#>                             locale   PASS  reproducibility
#>                           platform   PASS  reproducibility
#>                temporary directory   PASS  reproducibility
#>                                                                                                                       detail
#>                                                                                                                      R 4.6.0
#>                                                                                                                version 3.6.6
#>                                                                                                                version 0.1.4
#>                                                                                                                version 4.0.3
#>                                                                                                                version 5.0.1
#>                                                                                                                version 1.3.0
#>                                                                                                                version 4.6.0
#>                                                                                                                version 4.6.0
#>                                                                                                                version 3.3.1
#>                                                                                                                version 4.6.0
#>                                                                                                                version 0.7.3
#>                                                                       11 frozen teaching datasets are present and non-empty.
#>                                                          apm_workflow(), apm_capabilities(), and apm_doctor() are available.
#>                                                                                                    AVAILABLE ; version 0.7.0
#>                                                                                                    AVAILABLE ; version 0.3.2
#>                                                                                                    AVAILABLE ; version 2.2.0
#>                                                                                                    AVAILABLE ; version 1.2.2
#>                                                                                                      AVAILABLE ; version 3.5
#>                                                                                                    AVAILABLE ; version 4.0.0
#>                                                                                                   AVAILABLE ; version 2.23.0
#>                                                                                                    AVAILABLE ; version 2.4.0
#>                                                                                                    AVAILABLE ; version 0.1.5
#>                                                                                                   AVAILABLE ; version 4.12.1
#>                                                                                                     AVAILABLE ; version 2.31
#>                                                                                                     AVAILABLE ; version 1.29
#>                                                                                                    AVAILABLE ; version 0.9.0
#>                                                                                                                  version 3.9
#>                                                                                        C:\\PROGRA~1\\Quarto\\bin\\quarto.exe
#>                                                                                      Random-effects benchmark fit completed.
#>  LC_COLLATE=C;LC_CTYPE=Portuguese_Brazil.utf8;LC_MONETARY=Portuguese_Brazil.utf8;LC_NUMERIC=C;LC_TIME=Portuguese_Brazil.utf8
#>                                                                                                           x86_64-w64-mingw32
#>                                                                           C:\\Users\\wep69\\AppData\\Local\\Temp\\RtmpcjLDfO
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
#>         <NA>
#> Environment mutated: FALSE 
```
