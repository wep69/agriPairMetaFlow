# agriPairMetaFlow 1.0.1

Patch release addressing all 21 findings of an independent execution audit of
version 1.0.0 (report `RELATORIO-AO-AUTOR.md`, audit date 2026-09-14).

**High severity.** `seed` arguments in `apm_workflow()` and `apm_prior_check()`
no longer hijack the global RNG (state is saved and restored).
`apm_rho_sensitivity()` returns fitted rows instead of failing every
repetition (`<<-` inside `tryCatch` removed; failures now warn at top level).
`apm_moderator_screen()` runs with its documented defaults. Fitted
`backend_fit$call` objects are re-evaluable again, which also repairs
`apm_wild_bootstrap()` end to end (plus a conventional-call shim at the
wildmeta boundary and `coefs` passed to `constrain_zero()`).
`apm_vcov(sparse = TRUE)` preserves the sparse S4 object instead of degrading
it.

**Medium severity.** `apm_compare_inference()` maps robust `beta`/`CI_L`/`CI_U`
columns. `apm_forest()` de-duplicates default labels and accepts a subgroup
column name or vector. `apm_influence()` auto-promotes to `unit = "effect"`
for `baujat`/`radial` plots. `apm_curve_features()` and
`apm_marginal_effects()` run with default argument combinations.
`apm_predict_context()` computes threshold probabilities by normal
approximation instead of delegating an unsupported `prob` argument to the
backend. The `apm_bayes()` refusal message is emittable (escaped cli
braces). `apm_prediction(method =)` is restricted to the supported
`"model"`.

**Low severity.** Figure export is quiet (`height` honoured, draw-time message
muffled). User-facing messages no longer cite development versions.
`apm_capabilities()` class assigned once. `tidy.apm_model()` gains
`statistic`/`p.value`. `confint.apm_model()` defaults to coefficients with
`parm = c("coef", "heterogeneity")`. New `as.data.frame.apm_data()`.
`min_studies` documented as a warning threshold. The spurious metafor
`struct` warning is muffled. `apm_bayes_diagnostics()` falls back to serial
PPC when parallel workers lack the package library.

Regression tests in `tests/testthat/test-audit-fixes.R` cover every item.

# agriPairMetaFlow 1.0.0

**Data de validação:** 2026-08-26 — validação local completa com toolchain R 4.6.0, metafor 5.0.1, bayesmeta 3.5, brms 2.23.0, JAGS 4.3.1, CmdStan 2.37.0. Correções aplicadas: DESCRIPTION (email maintainer), R/capabilities.R (ase::package_version), R/fit-core.R (weights=NULL handling), R/diagnostics-influence.R (stats::influence). Status: desenvolvimento 1.0.0.9000 promovido a formal 1.0.0 após gates locais; vignettes com 10/17 falhas conhecidas documentadas para correção pós-release.

# agriPairMetaFlow 1.0.0.9000 (arquivo)

## Stable integration layer

- Added `apm_workflow()` as an auditable orchestrator over the existing 0.1.0-0.5.0 API. It stores audit, plan, effects, sampling covariance, fitted model, diagnostics, sensitivity objects, table metadata, and a step-by-step routing log.
- Automatic dependence routing distinguishes independent, shared-control, and explicitly paired structures. Treatment-versus-control labeling alone is never used as evidence of pairing.
- Shared-control routing constructs the sampling covariance matrix before synthesis and selects a multilevel route by default. User overrides remain possible and are recorded.
- Added `apm_capabilities()` as the single feature/backend/version/validation-tier registry. Optional backends remain capabilities rather than brands in the user-facing API.
- Added non-mutating `apm_doctor()` for core dependencies, optional engines, teaching-data integrity, rendering tools, reproducibility information, and opt-in smoke checks. The doctor never installs or updates software.

## Consolidation and documentation

- The stable analytical API now contains 57 exported functions: 14 from 0.1.0, 10 from 0.2.0, 10 from 0.3.0, 10 from 0.4.0, 10 from 0.5.0, and 3 integration functions in 1.0.0.
- Added three dedicated 1.0 test files, conservative manual snapshots, and `v15-integration-workflow-and-release-readiness.Rmd`.
- Added end-to-end numerical equivalence tests comparing `apm_workflow()` with the same lower-level calls executed manually.
- Consolidated README, architecture, implementation summary, validation status, and local release instructions around the final 57-function API.

## Release status

- The construction environment performs static validation only and intentionally does not install R.
- This archive therefore uses development version `1.0.0.9000`. Promotion to formal `1.0.0` requires local runtime validation, documentation regeneration, full tests/examples/vignettes, `R CMD build`, and `R CMD check --as-cran` on the exact frozen tarball.

# agriPairMetaFlow 0.5.0.9000

## Diagnostics and influence

- Added `apm_influence()` for effect- or study-level Cook-type influence, leverage, DFBETAS, heterogeneity-change diagnostics, and native Baujat/radial displays where supported.
- Added `apm_leave_one_out()` with explicit study-versus-effect deletion semantics, retention of failed refits, prediction/heterogeneity tracking, and optional output transformation.
- Added `apm_gosh()` with direct `metafor::gosh()` routing for supported independent models and a cluster-respecting random-subset route when study-level dependence must be preserved.
- `apm_fit()` now retains the fitted sampling covariance matrix `V` so diagnostic refits do not silently revert dependence-aware analyses to independence.

## Small-study effects and publication-bias sensitivity

- Added `apm_bias()` with separate adapters for regression/Egger diagnostics, rank correlation, trim-and-fill, selection models, `PublicationBias` S-values and selection-ratio analyses, and optional Copas/limit sensitivity through `metasens`.
- Each method retains applicability/failure status and its backend. Funnel asymmetry and corrected estimates are never treated as proof of one publication mechanism.
- Added `apm_funnel_contour()` as an explicit contour-enhanced funnel interface.

## Advanced visualization and moderator exploration

- Added native `apm_orchard()` plots showing observed effects, mean-effect uncertainty, and prediction intervals when identifiable.
- Added optional interactive conversion through `plotly`.
- Added `apm_moderator_screen()` using MetaForest for exploratory moderator screening, optional cluster-aware cross-validation/tuning, permutation importance, and minimal-depth summaries when available.
- MetaForest output is explicitly marked exploratory and is not substituted for confirmatory meta-regression.

## Reporting and export

- Added deterministic `apm_explain()` for scientific, teaching, and extension-oriented interpretation based only on fitted quantities and declared assumptions.
- Added `apm_report()` to render HTML, DOCX, or PDF summaries from an existing fitted object without refitting it. The report records object hashes, package version, R version, and selected analysis sections.
- Added `apm_export()` for CSV, XLSX, RDS, JSON, PNG, SVG, TIFF, and HTML output. Raster figures default to 600 dpi and complete RDS objects preserve analytical provenance.
- Extended `apm_table()` to Bayesian, bias-sensitivity, and influence objects and to backend-provided confidence bounds where available.

## Documentation and validation

- Added four English vignettes covering influence/GOSH, bias sensitivity/visualization, exploratory screening/reporting/export, and a three-example API reference for all 0.5.0 functions.
- Added ten dedicated 0.5.0 test files and new static scientific-safety gates.
- Construction-environment validation remains static only. Runtime validation is intentionally local and R is not installed here.

# agriPairMetaFlow 0.4.0.9000

## Multivariate synthesis

- Added `apm_multivariate()` for joint synthesis of multiple agronomic outcomes with explicit sampling covariance and outcome-specific effects.
- Added unstructured (`UN`), compound-symmetry (`CS`), and diagonal (`DIAG`) between-outcome heterogeneity structures.
- `metafor::rma.mv()` is the default multivariate backend; `mixmeta` is an optional alternative for complete outcome profiles.
- Added `apm_mvcor_sensitivity()` to refit the model across prespecified within-study outcome correlations when cross-outcome covariances are unavailable.
- Added `apm_multivariate_plot()` for outcome summaries and between-outcome heterogeneity-correlation visualization, with optional `plotly` conversion.
- Added `biochar_multiresponse` and extended `soil_management_multiresponse` for deterministic multivariate teaching and validation.

## Bayesian layer

- Added `apm_prior()` for backend-neutral, auditable effect, heterogeneity, and moderator prior declarations.
- Added `apm_prior_check()` for seeded prior simulation, natural-scale lnRR/VR/CVR implications, moderator contexts, and threshold-tail summaries before fitting.
- Added `apm_bayes()` with adapters for `bayesmeta`, `RoBMA`, and `brms` while keeping all heavy Bayesian packages optional.
- Added `apm_bayes_predict()` and separated posterior mean-effect uncertainty from prediction for a new true study effect.
- Added `apm_bayes_threshold()` for posterior or predictive probability relative to user-defined agronomic relevance thresholds and optional ROPEs, without automated decision rules.
- Added `apm_bayes_diagnostics()` with backend-specific behavior. R-hat, ESS, and MCSE are not fabricated for deterministic `bayesmeta` integration.
- Added `apm_bayes_compare()` for prespecified compatible Bayesian-model comparisons. The 0.4.0 predictive-criterion adapter is intentionally conservative and restricted to supported model families.

## Backend-compatibility safeguards

- Corrected `bayesmeta` quantile routing to use `mu.p`/`theta.p` in the normal-normal model and `qpredict()`/`ppredict()` in `bmr()` meta-regression.
- For `RoBMA >= 4.0.0`, a new-study meta-analytic prediction uses `predict.brma(type="estimate")`; `type="response"` is not used because it additionally simulates sampling error.
- RoBMA continuous-predictor standardization is disabled in the adapter so that declared moderator priors remain on the package model scale.
- Corrected BayesTools translation to use the documented `exp` distribution identifier and `a`/`b` parameters for uniform priors.
- The initial `brms` adapter stops on unsupported prior families rather than silently dropping them.
- Two-sided relevance probabilities now evaluate probability outside `[-|threshold|, |threshold|]` instead of using a symmetric tail shortcut that is invalid for asymmetric posterior locations.

## Validation

- Added ten dedicated 0.4.0 test files, multivariate golden-test contracts against `metafor`, and optional-backend tests for `mixmeta` and Bayesian engines.
- Added extensive multivariate and Bayesian pedagogical vignettes and an API coverage vignette.
- Runtime validation remains intentionally local for this package. The construction environment performs static validation only and does not install R.

