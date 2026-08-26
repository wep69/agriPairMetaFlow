# agriPairMetaFlow 1.0

`agriPairMetaFlow` is a design-first R workflow for treatment-versus-control meta-analysis in agronomy. The 1.0 development snapshot consolidates the full analytical path from effect-size construction to dependence-aware modeling, heterogeneity and prediction, robust and Bayesian sensitivity analysis, quantitative moderators and dose-response, multivariate outcomes, diagnostics, publication-bias sensitivity, visualization, reporting, and export.

The stable public analytical API contains **57 functions**. Version 1.0 adds only three integration functions because the statistical scope was already complete in 0.5.0:

- `apm_workflow()` orchestrates an end-to-end analysis while retaining every intermediate object and every automatic routing decision;
- `apm_capabilities()` reports the feature/backend registry, minimum-version policy, local installation state, and validation tier;
- `apm_doctor()` inspects the local installation and reproducibility stack without installing packages or changing the environment.

## Stable scientific flow

```text
raw treatment-control summaries
        |
        v
apm_validate() / apm_audit() / apm_plan()
        |
        v
apm_effect_size()
        |
        +--> independent effects
        +--> genuinely paired effects
        +--> shared-control covariance via apm_vcov()
        |
        v
random / multilevel / meta-regression / dose-response / multivariate model
        |
        v
heterogeneity + prediction + robust/Bayesian sensitivity
        |
        v
influence + bias sensitivity + figures + tables + report/export
```

`apm_workflow()` does not add an estimator. It records and reproduces this existing sequence.

## Integrated examples

### Shared zero-N controls

```r
library(agriPairMetaFlow)

wf <- apm_workflow(
  maize_n_shared,
  measure = "lnRR",
  dependence = "shared_control",
  model = "multilevel"
)

wf$routing_log
wf$fit
```

When `clubSandwich` is installed, the same workflow can add CR2 sensitivity with `robust = TRUE`.

### Climatic moderators and an agronomic threshold

```r
wf <- apm_workflow(
  irrigation_climate,
  measure = "lnRR",
  moderators = ~ rainfall + mean_temp,
  threshold = 5
)

wf$diagnostics$prediction
wf$diagnostics$threshold
```

### Explicitly paired summaries

```r
wf <- apm_workflow(
  wheat_paired_blocks,
  measure = "lnRR",
  dependence = "paired",
  model = "random"
)
```

A treatment-control comparison is not automatically a paired design. Pairing requires explicit matched/repeated information such as paired sample size and treatment-control correlation or an explicit paired plan.

## Capability and installation inspection

```r
apm_capabilities()
apm_capabilities("bayesian", detail = "full")
apm_doctor(full = TRUE, check_backends = TRUE)
```

An unavailable optional backend is reported as an unavailable optional capability, not as a failure of the core package. `apm_doctor()` is non-mutating and does not replace the formal test suite or CRAN-style checking.

## Scientific safeguards

The stable package follows these interpretation rules:

* shared controls and paired designs are not converted into independent effects;
* automatic routing decisions are written to `routing_log` and can be overridden;
* no model-selection routine is allowed to choose a scientific model only by p-value;
* prediction intervals are not replaced by confidence intervals;
* funnel asymmetry is not equated with publication bias;
* publication-bias sensitivity estimates are not silently substituted for the primary analysis;
* influence statistics do not define automatic exclusion rules;
* MetaForest output is exploratory and does not replace prespecified meta-regression;
* Bayesian interpretation requires backend-appropriate diagnostics;
* automated interpretation is deterministic and constrained by quantities present in the statistical object.

## Optional backends

`metafor` remains the core statistical engine. Optional capabilities use `clubSandwich`, `wildmeta`, `dosresmeta`, `mixmeta`, `bayesmeta`, `RoBMA`, `brms`, `PublicationBias`, `meta`, `metasens`, `metaforest`, `plotly`, `gt`, `flextable`, `openxlsx2`, and related supporting packages only when those features are requested.

Use `apm_capabilities(detail="full")` to inspect the registry rather than inferring support from installed package names.

## Validation policy

By project decision, R is intentionally **not installed or executed in the construction environment** for `agriPairMetaFlow`. Static source auditing, documentation coverage, source consistency, manifests, hashes, and packaging are performed here. Runtime validation is performed locally on the target R installation.

Therefore this development archive is **not yet the formal 1.0.0 release tarball**. The package version remains `1.0.0.9000` until the local release gates pass.

Mandatory local gates include:

1. regenerate documentation with `roxygen2`;
2. parse all R sources;
3. install into a clean library;
4. run every unit test and all executable examples;
5. validate deterministic backends numerically against their upstream implementations;
6. validate stochastic backends with fixed seeds and appropriate Monte Carlo criteria;
7. render normal vignettes and validate heavy-vignette frozen objects;
8. run `R CMD build`;
9. freeze the generated source tarball;
10. run `R CMD check --as-cran` on that exact tarball;
11. inspect the complete `00check.log`;
12. only after all package-caused issues are resolved, change `Version:` from `1.0.0.9000` to `1.0.0`, rebuild, refreeze, recheck, and archive hashes/logs.

See `LOCAL_VALIDATION.md` for the detailed reproducible procedure.
