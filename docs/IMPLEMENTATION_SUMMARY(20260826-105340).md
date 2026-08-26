# agriPairMetaFlow 1.0.0.9000 implementation summary

## Status

The complete planned analytical architecture through version 1.0 has
been implemented and consolidated in this source snapshot. By project
decision, R is not installed or executed in the construction
environment. Consequently, this artifact is a **development release
candidate** with package version `1.0.0.9000`, not yet a
runtime-validated formal `1.0.0` release.

This distinction follows the Scientific Package Builder rule that
source/static checks must never be reported as numerical or CRAN-style
runtime validation.

## Stable scientific identity

`agriPairMetaFlow` is an R-first package for treatment-versus-control
evidence synthesis in agronomy. Its stable scope includes:

- independent and genuinely paired treatment-control effect sizes;
- shared-control covariance and other explicitly represented sampling
  dependence;
- common, random, mixed, and multilevel meta-analysis;
- cluster-robust and cluster wild-bootstrap sensitivity;
- categorical and quantitative meta-regression;
- nonlinear moderator curves and dose-response synthesis;
- multivariate outcomes;
- Bayesian synthesis and Bayesian sensitivity through optional mature
  engines;
- heterogeneity and prediction intervals;
- mean-response and variability effect sizes, including lnRR, VR, and
  CVR;
- influence, leave-one-out, GOSH, and small-study-effect diagnostics;
- publication-bias sensitivity under explicitly stated assumptions;
- static and optional interactive graphics;
- tables, deterministic interpretation, reporting, and export.

Network meta-analysis, diagnostic-accuracy meta-analysis, transcriptomic
meta-analysis, IPD meta-analysis, and systematic-review screening remain
intentionally outside the core scope.

## Public API by release

| Release block | New functions | Cumulative analytical API |
|---------------|--------------:|--------------------------:|
| 0.1.0         |            14 |                        14 |
| 0.2.0         |            10 |                        24 |
| 0.3.0         |            10 |                        34 |
| 0.4.0         |            10 |                        44 |
| 0.5.0         |            10 |                        54 |
| 1.0.0         |             3 |                    **57** |

The three 1.0 integration functions are:

### `apm_workflow()`

Runs an auditable end-to-end analysis using the lower-level package
functions. It retains:

- data audit;
- explicit or automatically constructed plan;
- effect-size object;
- sampling covariance matrix when required;
- fitted model;
- dependence/heterogeneity/prediction/threshold diagnostics;
- optional robust or Bayesian sensitivity objects;
- table/plot metadata;
- complete `routing_log` identifying automatic, user-specified, and
  derived decisions.

No new estimator is implemented inside
[`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md).

Scientific safeguards include:

- shared controls route through an explicit sampling covariance matrix;
- a treatment-control comparison is never automatically labeled paired;
- paired treatment-control correlation is used in the paired effect-size
  sampling variance and does not automatically create covariance between
  independent studies;
- optional Bayesian routing is blocked for shared-control data when the
  current Bayesian adapter cannot propagate the full sampling covariance
  matrix, preventing silent loss of dependence;
- user overrides are recorded rather than hidden.

### `apm_capabilities()`

Provides the canonical feature/backend registry. It records:

- feature;
- computational backend;
- R package;
- minimum-version policy where defined;
- core versus optional status;
- validation tier;
- installed version and readiness when requested.

This function does not install software.

### `apm_doctor()`

Provides a non-mutating runtime/readiness diagnostic with `PASS`,
`WARN`, `FAIL`, and `NOT RUN` states. It checks core dependencies,
optional engines, teaching-data presence, rendering stack,
reproducibility environment, and opt-in smoke examples. It is explicitly
not a replacement for the unit tests, numerical golden tests, vignette
rendering, `R CMD build`, or `R CMD check --as-cran`.

## Consolidated source inventory

Current construction snapshot:

- analytical exports: **57**;
- all NAMESPACE exports including teaching datasets: **68**;
- R source files: **66**;
- conservative `.Rd` topics: **68**;
- dedicated `testthat` files: **58**;
- English R Markdown vignettes: **17**;
- frozen agronomic CSV datasets in `inst/extdata`: **11**.

`inst/metadata/api_1_0_coverage.csv` records source file, roxygen call
count, vignette call count, manual presence, and test presence for all
57 analytical exports.

## Documentation

The vignette system retains the foundations-to-advanced tutorial as the
pedagogical anchor and adds specialized non-overlapping blocks for
data/effect sizes, heterogeneity/prediction, shared controls and
pairing, robust/multilevel inference, meta-regression, dose-response,
multivariate synthesis, Bayesian methods, influence/GOSH,
publication-bias sensitivity, visualization, MetaForest,
reporting/export, API examples, and the new 1.0 integrated
workflow/release-readiness block.

Every analytical export has at least three distinct agronomic/example
calls in its roxygen source and at least three uses across the vignette
source collection in the current static audit.

## Construction-environment validation

The final source-only validation suite reports:

**755/755 static checks PASS.**

The static gates cover:

- 57 analytical exports in NAMESPACE;
- source function presence;
- roxygen export/example blocks;
- three function calls in roxygen example blocks;
- conservative manual topic presence and three example calls;
- at least three vignette calls per function;
- corresponding test-file coverage;
- lexical delimiter balance for all R/test files;
- frozen teaching-data presence and SHA-256 integrity;
- release-specific scientific safety checks from 0.3.0 through 1.0;
- optional dependency policy;
- Bayesian target/diagnostic safeguards;
- diagnostic/refit preservation of sampling covariance;
- publication-bias and MetaForest scope safeguards;
- report/export provenance requirements;
- 1.0 routing-log, capability-registry, and doctor non-mutation
  contracts.

Static validation evidence is saved to
`inst/metadata/static_validation.csv`.

## Runtime validation status

The following remain **NOT RUN / LOCAL**:

- R parser execution;
- [`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html);
- installation into a clean R library;
- all 58 `testthat` files;
- execution of package examples;
- deterministic golden comparisons against `metafor`, `clubSandwich`,
  `mixmeta`, `dosresmeta`, `PublicationBias`, and related backends;
- seeded stochastic validation for `wildmeta`, Bayesian backends, and
  MetaForest;
- JAGS/Stan convergence and system validation;
- vignette rendering;
- report rendering;
- full visual inspection;
- `R CMD build`;
- `R CMD check --as-cran` on the exact built tarball.

The complete sequence is specified in `LOCAL_VALIDATION.md`.

## Release promotion rule

Do not label this construction snapshot as formal validated `1.0.0`
merely because the static suite passes. The intended release sequence
is:

``` text
1.0.0.9000 source snapshot
        -> local roxygen/test/examples/golden validation
        -> local vignette/report/visual validation
        -> R CMD build
        -> freeze exact candidate tarball
        -> R CMD check --as-cran on that exact tarball
        -> resolve package-caused issues
        -> change only release metadata to 1.0.0
        -> regenerate/rebuild/refreeze
        -> repeat R CMD check --as-cran on exact formal tarball
        -> install/retest the exact formal tarball
        -> archive logs, hashes, versions, capabilities, doctor results
```

Any source change after a successful check invalidates the previous
release evidence and requires rebuilding and rechecking.
