# Implementation status update: 1.0.0.9000

The architecture specified below has now been implemented through all
planned release blocks. The source snapshot contains all 57 planned
analytical functions. Construction-environment static validation passes
755/755 gates. Runtime R validation remains deliberately local, so the
package is retained at development version `1.0.0.9000` until the formal
procedure in `LOCAL_VALIDATION.md` passes. This status note does not
alter the implementation contracts below.

# agriPairMetaFlow: Implementation Specification

**Status:** implementation-ready specification

**Target language:** R

**Scope:** treatment-versus-control evidence synthesis for agricultural
experiments, with explicit handling of shared controls, genuinely
paired/matched summaries, multilevel dependence, quantitative
moderators, dose-response, multivariate outcomes, robust inference,
Bayesian analysis, sensitivity analysis, publication-bias diagnostics,
static and interactive graphics, tables, and reproducible reporting.

**Design principle:** the public API is estimand-first and design-first.
Backend package names are capabilities, not the scientific interface.

## 1. Scientific and software contract

The package must make treatment-control meta-analysis easier to apply
without hiding assumptions. The primary workflow is:

``` text
Data -> validation -> design/estimand plan -> effect size -> dependence/V -> model -> uncertainty/prediction -> diagnostics/sensitivity -> interpretation -> report
```

Non-negotiable rules:

- No silent deletion, imputation, covariance repair, model switching, or
  effect-size transformation.
- Treatment-control pairing is not automatically treated as a
  statistically paired-sample design. `design='paired'` is used only
  when the primary-study design justifies correlated treatment-control
  summaries.
- Shared controls create dependent contrasts and must be represented in
  the sampling covariance matrix or handled in an explicitly documented
  sensitivity/robust analysis.
- Prediction intervals are shown whenever scientifically defined and
  supported, in addition to confidence intervals.
- lnRR, VR and CVR are first-class continuous effect sizes; paired
  analogues use the corresponding matched/change measures.
- Practical agronomic thresholds are supplied by the user. The package
  never invents a minimally important effect.
- Model choice is not driven only by p-values. Design, likelihood,
  dependence, fit, uncertainty, support and scientific relevance are
  retained in the decision record.
- Bayesian analyses preserve priors, seeds, backend versions,
  convergence diagnostics and posterior predictive information.
- Plots and tables consume stored analytical results. They do not
  silently refit models.
- Every exported function has at least three distinct agronomic
  examples. Heavy examples use frozen precomputed scientific objects in
  release vignettes.

## 2. Backend baseline checked for this specification

The implementation should be developed and golden-tested against the
following current reference ecosystem, while using minimum-version
policies rather than hard-pinning users to one patch release:

| Backend | Checked version | Role |
|----|---:|----|
| `metafor` | 5.0-1 | Core effect sizes, rma.uni/rma.mv, vcalc, prediction, influence, GOSH, publication-bias methods |
| `clubSandwich` | 0.7.0 | CR2 covariance, Satterthwaite coefficient tests, HTZ joint tests |
| `mixmeta` | 1.2.2 | Multivariate/multilevel cross-validation backend |
| `dosresmeta` | 2.2.0 | Dose-response meta-analysis |
| `bayesmeta` | 3.5 | Normal-normal Bayesian meta-analysis and meta-regression |
| `RoBMA` | 4.0.0 | Bayesian model averaging, meta-regression, multilevel models and publication-bias adjustment |
| `pimeta` | 1.1.3 | Alternative prediction-interval methods |
| `PublicationBias` | 2.4.0 | Selection-ratio sensitivity and S-values |
| `wildmeta` | current CRAN | Cluster wild-bootstrap tests |
| `metaforest` | current CRAN/R-universe | Exploratory moderator screening |
| `orchaRd` | current release | Visual reference/parity checks for orchard-style summaries |
| `metasens` | current CRAN | Optional Copas/limit-meta adapters |

## 3. Package-level directory architecture

``` text
agriPairMetaFlow/
  DESCRIPTION
  NAMESPACE
  LICENSE
  README.md
  NEWS.md
  STATE_OF_THE_ART.md
  ARCHITECTURE.md
  IMPLEMENTATION_SPEC.md
  VALIDATION.md
  LOCAL_VALIDATION.md
  R/
  data/
  data-raw/
  inst/extdata/
  inst/metadata/
  inst/templates/
  tests/testthat/
  tests/testthat.R
  vignettes/
  tools/
  man/
  _pkgdown.yml
  .github/workflows/
```

### 3.1 R/ architecture

- `R/bayes-compare.R`:
  [`apm_bayes_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_compare.md)
- `R/bayes-diagnostics.R`:
  [`apm_bayes_diagnostics()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_diagnostics.md)
- `R/bayes-fit.R`:
  [`apm_bayes()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes.md)
- `R/bayes-predict.R`:
  [`apm_bayes_predict()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_predict.md)
- `R/bayes-prior-check.R`:
  [`apm_prior_check()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior_check.md)
- `R/bayes-prior.R`:
  [`apm_prior()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior.md)
- `R/bayes-threshold.R`:
  [`apm_bayes_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_threshold.md)
- `R/capabilities.R`:
  [`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md)
- `R/compare-inference.R`:
  [`apm_compare_inference()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_compare_inference.md)
- `R/curve-features.R`:
  [`apm_curve_features()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_curve_features.md)
- `R/data-audit.R`:
  [`apm_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_audit.md)
- `R/data-read.R`:
  [`apm_read()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_read.md)
- `R/data-validate.R`:
  [`apm_validate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_validate.md)
- `R/dependence-audit.R`:
  [`apm_dependence_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dependence_audit.md)
- `R/dependence-paired.R`:
  [`apm_pair_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_pair_vcov.md)
- `R/dependence-shared-control.R`:
  [`apm_shared_control()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_shared_control.md)
- `R/dependence-vcov.R`:
  [`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md)
- `R/diagnostics-gosh.R`:
  [`apm_gosh()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_gosh.md)
- `R/diagnostics-influence.R`:
  [`apm_influence()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_influence.md)
- `R/diagnostics-leave-one-out.R`:
  [`apm_leave_one_out()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_leave_one_out.md)
- `R/doctor.R`:
  [`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
- `R/dose-response.R`:
  [`apm_dose_response()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_response.md)
- `R/effect-size.R`:
  [`apm_effect_size()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_effect_size.md)
- `R/explain.R`:
  [`apm_explain()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_explain.md)
- `R/export.R`:
  [`apm_export()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_export.md)
- `R/fit-core.R`:
  [`apm_fit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_fit.md)
- `R/fit-multilevel.R`:
  [`apm_multilevel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multilevel.md)
- `R/heterogeneity.R`:
  [`apm_heterogeneity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_heterogeneity.md)
- `R/interaction.R`:
  [`apm_interaction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_interaction.md)
- `R/marginal-effects.R`:
  [`apm_marginal_effects()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_marginal_effects.md)
- `R/metareg-curve.R`:
  [`apm_metareg_curve()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg_curve.md)
- `R/metareg.R`:
  [`apm_metareg()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg.md)
- `R/model-compare.R`:
  [`apm_model_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_model_compare.md)
- `R/moderator-screen.R`:
  [`apm_moderator_screen()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_moderator_screen.md)
- `R/multivariate.R`:
  [`apm_multivariate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate.md)
- `R/plan.R`:
  [`apm_plan()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_plan.md)
- `R/plot-bubble.R`:
  [`apm_bubble()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bubble.md)
- `R/plot-dose.R`:
  [`apm_dose_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_plot.md)
- `R/plot-forest.R`:
  [`apm_forest()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_forest.md)
- `R/plot-funnel.R`:
  [`apm_funnel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel.md),
  [`apm_funnel_contour()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel_contour.md)
- `R/plot-multivariate.R`:
  [`apm_multivariate_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate_plot.md)
- `R/plot-orchard.R`:
  [`apm_orchard()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_orchard.md)
- `R/predict-context.R`:
  [`apm_predict_context()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_predict_context.md)
- `R/prediction.R`:
  [`apm_prediction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prediction.md)
- `R/publication-bias.R`:
  [`apm_bias()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bias.md)
- `R/report.R`:
  [`apm_report()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_report.md)
- `R/robust.R`:
  [`apm_robust()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_robust.md)
- `R/sensitivity-mvcor.R`:
  [`apm_mvcor_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_mvcor_sensitivity.md)
- `R/sensitivity-rho.R`:
  [`apm_rho_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_rho_sensitivity.md)
- `R/subgroup.R`:
  [`apm_subgroup()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_subgroup.md)
- `R/table.R`:
  [`apm_table()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_table.md)
- `R/threshold.R`:
  [`apm_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_threshold.md)
- `R/uncertainty.R`:
  [`apm_recover_uncertainty()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_recover_uncertainty.md)
- `R/variance-components.R`:
  [`apm_variance_components()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_variance_components.md)
- `R/wild-bootstrap.R`:
  [`apm_wild_bootstrap()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_wild_bootstrap.md)
- `R/workflow.R`:
  [`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md)
- `R/aaa-package.R`: Package documentation, imports and global package
  concepts.
- `R/constants.R`: Effect-measure registry, backend capability registry,
  class constants.
- `R/utils-assert.R`: Assertions and informative error helpers.
- `R/utils-backend.R`: Backend discovery, version checks, adapters and
  capability routing.
- `R/utils-transform.R`: Effect-scale transformations and percent/ratio
  conversions.
- `R/utils-model-matrix.R`: Safe formula/model-matrix construction and
  contrast utilities.
- `R/s3-print.R`: Print methods.
- `R/s3-summary.R`: Summary methods.
- `R/s3-extract.R`: coef, vcov, confint, fitted and residuals methods.
- `R/s3-predict.R`: predict methods.
- `R/s3-tidy.R`: tidy, glance and augment methods via generics.
- `R/s3-plot.R`: plot/autoplot dispatch.
- `R/zzz.R`: Startup options and backend registration, without startup
  messages unless actionable.

## 4. Core dependency policy

### Imports

`stats`, `utils`, `methods`, `graphics`, `grDevices`, `metafor`,
`ggplot2`, `rlang`, `vctrs`, `tibble`, `cli`, `generics`.

### Suggests

`readxl`, `openxlsx2`, `clubSandwich`, `wildmeta`, `mixmeta`,
`dosresmeta`, `bayesmeta`, `RoBMA`, `brms`, `cmdstanr`, `posterior`,
`bayesplot`, `pimeta`, `PublicationBias`, `metasens`, `metaforest`,
`orchaRd`, `plotly`, `gt`, `flextable`, `jsonlite`, `rmarkdown`,
`quarto`, `knitr`, `testthat`, `waldo`, `withr`, `vdiffr`, `meta`,
`emmeans`.

JAGS and CmdStan remain optional system dependencies. Basic package
installation must not require either.

## 5. Public S3 object contract

| Class | Scientific role | Required core fields |
|----|----|----|
| `apm_data` | Imported/normalized study data | data, mapping, units, provenance, source_hash, issues |
| `apm_validation` | Schema and field validation | ok, issues, field_summary, roles |
| `apm_audit` | Design/data audit | issues, severities, recommendations, repair_log |
| `apm_plan` | Estimand and design plan | roles, design, hierarchy, dependence, estimand, recommendations, data_hash |
| `apm_uncertainty` | Recovered uncertainty data | data, derivations, assumptions, provenance |
| `apm_effects` | Effect-size table | yi, vi, sei, measure, design, IDs, raw summaries, provenance |
| `apm_vcov` | Sampling covariance matrix | V, blocks, assumptions, eigenvalues, repaired, provenance |
| `apm_model` | Frequentist model wrapper | backend_fit, coefficients, vcov, heterogeneity, model_matrix, data_hash, settings |
| `apm_subgroup` | Subgroup synthesis | subgroup_estimates, PI, heterogeneity, omnibus_test |
| `apm_multilevel` | Multilevel model | apm_model fields + random structure + variance components |
| `apm_robust` | Cluster-robust inference | model, robust_vcov, tests, df, cluster_info |
| `apm_wild` | Wild-bootstrap inference | tests, bootstrap_distribution summary, MCSE, seed, failures |
| `apm_inference_comparison` | Inference sensitivity | aligned results by method, discrepancies |
| `apm_metareg` | Meta-regression model | apm_model fields + moderator metadata + residual heterogeneity |
| `apm_curve` | Quantitative meta-regression curve | basis, fit, grid, predictions, support |
| `apm_dose` | Dose-response meta-analysis | backend_fit, dose basis, covariance, predictions, GOF |
| `apm_multivariate` | Multivariate synthesis | outcome estimates, within/between covariance, correlations, backend fit |
| `apm_prior` | Backend-neutral Bayesian prior spec | effect, tau, moderators, model_probability, scale, rationale |
| `apm_bayes` | Bayesian model wrapper | backend_fit, draws/summary, priors, diagnostics, predictive metadata, versions |
| `apm_sensitivity` | Sensitivity analysis | grid, results, failures, stability flags |
| `apm_bias` | Publication-bias/small-study analysis | method results, assumptions, applicability, cross-method summary |
| `apm_influence` | Influence diagnostics | unit results, ranks, refit status, plot data |
| `apm_gosh` | GOSH diagnostics | subset results, seed, cluster design, plot data |
| `apm_moderator_screen` | Exploratory MetaForest screen | fit, tuning, CV/OOB, importance, partial dependence |
| `apm_report` | Rendered report metadata | path, source, hashes, session metadata, sections |
| `apm_workflow` | End-to-end workflow | audit, plan, effects, V, fit, diagnostics, sensitivities, routing_log |
| `apm_doctor` | Installation/runtime diagnostic | checks, status, remediation |

### 5.1 Required S3 methods

| Generic | Classes | Contract |
|----|----|----|
| [`print()`](https://rdrr.io/r/base/print.html) | apm_data, apm_validation, apm_audit, apm_plan, apm_effects, apm_vcov, apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes, apm_sensitivity, apm_bias, apm_workflow, apm_doctor | Compact scientific status, never raw backend dump. |
| [`summary()`](https://rdrr.io/r/base/summary.html) | apm_audit, apm_plan, apm_effects, apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes, apm_sensitivity, apm_bias | Detailed inferential summary. |
| [`coef()`](https://rdrr.io/r/stats/coef.html) | apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes | Standardized coefficient extraction. |
| [`vcov()`](https://rdrr.io/r/stats/vcov.html) | apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate | Coefficient covariance, not sampling V unless explicitly requested. |
| [`confint()`](https://rdrr.io/r/stats/confint.html) | apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes | Frequentist CI or Bayesian CrI, labeled. |
| [`predict()`](https://rdrr.io/r/stats/predict.html) | apm_model, apm_metareg, apm_curve, apm_dose, apm_multivariate, apm_bayes | Dispatch to apm_prediction/apm_bayes_predict semantics. |
| [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) | apm_model, apm_metareg, apm_multilevel, apm_multivariate | Fitted mean effects. |
| [`residuals()`](https://rdrr.io/r/stats/residuals.html) | apm_model, apm_metareg, apm_multilevel, apm_multivariate | Raw/studentized/decorrelated where available. |
| [`plot()`](https://rdrr.io/r/graphics/plot.default.html) | main analysis classes | Base convenience dispatcher to scientifically appropriate plot. |
| `autoplot()` | apm_model, apm_metareg, apm_curve, apm_dose, apm_multivariate, apm_bayes, apm_sensitivity, apm_bias, apm_influence | ggplot2 dispatcher with `type=`. |
| `tidy()` | apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes | Coefficient-level tidy output via `generics`. |
| `glance()` | apm_model, apm_robust, apm_metareg, apm_dose, apm_multivariate, apm_bayes | One-row model summary. |
| `augment()` | apm_model, apm_metareg | Effect-level fitted/residual/influence columns. |
| [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) | apm_effects, apm_vcov summaries, apm_sensitivity, apm_bias | Lossless coercion of tabular summaries. |

All methods must preserve the underlying data hash and model provenance.
[`summary()`](https://rdrr.io/r/base/summary.html) and plotting methods
are not allowed to refit with different defaults.

## 6. Canonical teaching and validation datasets

All datasets below are simulated or synthetic-but-realistic, frozen with
documented seeds and stored with a `data-raw/` generation script. They
are teaching and validation assets, not field evidence.

| Dataset | Target size | Primary purpose | Core columns |
|----|---:|----|----|
| `maize_n_shared` | ~140 contrasts / ~35 studies | Multiple N doses vs zero-N/shared control; dependence, lnRR, multilevel and robust examples. | study_id, experiment_id, effect_id, site, year, crop, treatment, control, control_id, N_rate, mean_t, sd_t, n_t, mean_c, sd_c, n_c, soil_texture, soil_organic_matter, rainfall, yield_unit |
| `covercrop_variability` | ~80 contrasts / ~40 studies | Cover crop vs bare/control; mean response and response variability. | study_id, effect_id, crop, cover_type, mean_t, sd_t, n_t, mean_c, sd_c, n_c, outcome, climate_zone |
| `irrigation_climate` | ~120 contrasts / ~55 studies | Irrigation strategy vs reference; quantitative climate moderators and interaction examples. | study_id, experiment_id, effect_id, irrigation, control, mean_t, sd_t, n_t, mean_c, sd_c, n_c, rainfall, mean_temp, climate_zone, soil_clay, altitude |
| `bioinoculant_multicrop` | ~110 contrasts / ~50 studies | Inoculant vs non-inoculated control across crops and soils; categorical moderators. | study_id, experiment_id, effect_id, crop, inoculant, control, mean_t, sd_t, n_t, mean_c, sd_c, n_c, soil_pH, rainfall, site |
| `fertilizer_dose_response` | ~180 dose rows / ~40 studies | Several fertilizer doses vs reference within study; true dose-response meta-analysis. | study_id, dose_id, control_id, N_rate, lnRR, vi, mean_t, sd_t, n_t, mean_c, sd_c, n_c, soil_texture, crop |
| `soil_management_multiresponse` | ~180 outcome effects / ~45 studies | Conservation vs conventional management with multiple outcomes. | study_id, effect_id, outcome, yi, vi, site, year, climate_zone, management, control, outcome_unit |
| `biochar_multiresponse` | ~120 effects / ~35 studies | Biochar vs control for yield, SOC, pH, N2O and water-use outcomes. | study_id, effect_id, outcome, yi, vi, dose, feedstock, soil_pH, climate_zone |
| `wheat_paired_blocks` | ~45 studies | Genuinely paired/matched treatment-control summaries with known/unknown treatment-control correlation. | study_id, block_id, treatment, control, mean_t, sd_t, mean_c, sd_c, n_pairs, r_tc, grain_yield, site, year |
| `agri_uncertainty_mixed` | ~90 study rows | Mixed reporting of SD, SE, CV, MSE and confidence intervals for uncertainty recovery. | study_id, mean_yield, n, sd_yield, se_yield, cv_percent, residual_mse, ci_lower, ci_upper, df, reporting_type |
| `pest_suppression_binary` | ~70 contrasts / ~30 studies | Binary pest/disease suppression examples for RR/OR/RD. | study_id, effect_id, treatment, control, event_t, n_t, event_c, n_c, crop, pest, site |
| `agri_effects_benchmark` | ~40 independent effects | Frozen numerically transparent effect-size benchmark used in manuals and golden tests. | study_id, yi, vi, crop, soil_texture, rainfall, dose, label |

Each dataset must have: a roxygen data topic, unit definitions,
simulation seed, generation script, input checksum, expected structural
invariants, and at least one frozen expected-output fixture for
numerical tests.

## 7. Effect-size registry and semantic mapping

| User measure | Independent groups | Paired/matched design | Natural interpretation |
|----|----|----|----|
| lnRR | ROM | ROMC | log treatment/control mean ratio; exp(yi) is the mean ratio |
| MD | MD | MC | absolute treatment-control mean difference |
| SMD | SMD/Hedges g | SMCC or SMCR family | standardized difference/change |
| VR | VR | VRC | log SD ratio |
| CVR | CVR | CVRC | log coefficient-of-variation ratio |
| RR | RR | MPRR where paired binary structure applies | risk ratio |
| OR | OR | MPOR/MPORC as appropriate | odds ratio |
| RD | RD | MPRD | risk difference |
| ZCOR | ZCOR | design-specific correlation route | Fisher z |
| GEN | direct yi/vi | direct yi/vi | generic effect supplied by user |

The registry stores required inputs, sign convention, null value,
reversible transformations, applicability to zero/negative means, and
the backend measure code. This registry is the single source of truth
for validation, plotting and interpretation.

## 8. Exact release allocation

| Release | New exported functions | Cumulative | Scientific gate |
|----|---:|---:|----|
| 0.1.0 | 14 | 14 | Core independent and paired treatment-control effect sizes, random-effects synthesis, heterogeneity, prediction, thresholds, forest/funnel and tables. |
| 0.2.0 | 10 | 24 | Shared-control covariance, paired covariance, multilevel models, CR2 and wild-bootstrap inference. |
| 0.3.0 | 10 | 34 | Meta-regression, quantitative moderator curves and true dose-response synthesis. |
| 0.4.0 | 10 | 44 | Multivariate and Bayesian analysis with backend-neutral priors and diagnostics. |
| 0.5.0 | 10 | 54 | Influence, GOSH, publication-bias/small-study sensitivity, orchard plots, MetaForest, reporting and export. |
| 1.0.0 | 3 | 57 | Stable orchestrated workflow, capability registry, installation/runtime doctor, frozen API and full release validation. |

### 0.1.0

[`apm_read()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_read.md),
[`apm_validate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_validate.md),
[`apm_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_audit.md),
[`apm_plan()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_plan.md),
[`apm_recover_uncertainty()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_recover_uncertainty.md),
[`apm_effect_size()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_effect_size.md),
[`apm_fit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_fit.md),
[`apm_subgroup()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_subgroup.md),
[`apm_heterogeneity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_heterogeneity.md),
[`apm_prediction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prediction.md),
[`apm_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_threshold.md),
[`apm_forest()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_forest.md),
[`apm_funnel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel.md),
[`apm_table()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_table.md).

### 0.2.0

[`apm_shared_control()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_shared_control.md),
[`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md),
[`apm_pair_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_pair_vcov.md),
[`apm_dependence_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dependence_audit.md),
[`apm_rho_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_rho_sensitivity.md),
[`apm_multilevel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multilevel.md),
[`apm_variance_components()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_variance_components.md),
[`apm_robust()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_robust.md),
[`apm_wild_bootstrap()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_wild_bootstrap.md),
[`apm_compare_inference()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_compare_inference.md).

### 0.3.0

[`apm_metareg()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg.md),
[`apm_marginal_effects()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_marginal_effects.md),
[`apm_interaction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_interaction.md),
[`apm_metareg_curve()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg_curve.md),
[`apm_model_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_model_compare.md),
[`apm_predict_context()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_predict_context.md),
[`apm_curve_features()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_curve_features.md),
[`apm_dose_response()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_response.md),
[`apm_dose_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_plot.md),
[`apm_bubble()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bubble.md).

### 0.4.0

[`apm_multivariate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate.md),
[`apm_mvcor_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_mvcor_sensitivity.md),
[`apm_prior()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior.md),
[`apm_prior_check()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior_check.md),
[`apm_bayes()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes.md),
[`apm_bayes_predict()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_predict.md),
[`apm_bayes_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_threshold.md),
[`apm_bayes_diagnostics()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_diagnostics.md),
[`apm_bayes_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_compare.md),
[`apm_multivariate_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate_plot.md).

### 0.5.0

[`apm_influence()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_influence.md),
[`apm_leave_one_out()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_leave_one_out.md),
[`apm_gosh()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_gosh.md),
[`apm_bias()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bias.md),
[`apm_funnel_contour()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel_contour.md),
[`apm_orchard()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_orchard.md),
[`apm_moderator_screen()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_moderator_screen.md),
[`apm_report()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_report.md),
[`apm_explain()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_explain.md),
[`apm_export()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_export.md).

### 1.0.0

[`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md),
[`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md),
[`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md).

## 9. Function-by-function implementation contract

The 57 exported functions below define the intended 1.0.0 public API.
Each function has exactly three agronomic example contexts in this
specification, giving a minimum of **171 exported-function examples**
before counting S3-method exercises.

### 1. `apm_read()` - release 0.1.0

**Source:** `R/data-read.R`\
**Signature:**

``` r

apm_read(path, sheet = NULL, mapping = NULL, na = c("", "NA"), units = NULL, strict = TRUE)
```

**Purpose:** Read CSV/XLSX/RDS study-level meta-analytic data and attach
role, unit, and provenance metadata.

**Arguments:** `path`: file path; `sheet`: Excel sheet name/index;
`mapping`: named role-to-column mapping; `na`: missing-value tokens;
`units`: optional named unit map; `strict`: fail on
unsupported/ambiguous input.

**Returns:** `apm_data`, containing normalized data, mapping, units,
source hash, import log, and unresolved issues.

**Backend:** Base R; optional `readxl`/`openxlsx2` for Excel. No
statistical backend.

**Validation contract:** Path must exist; unique column names; supported
tabular type; mapping columns must exist; unit map cannot reference
unknown columns.

**Unit-test file:** `tests/testthat/test-data-read.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `maize <- apm_read(system.file("extdata/maize_n_shared.csv", package="agriPairMetaFlow"))`
2.  `unc <- apm_read("agri_uncertainty.xlsx", sheet = "studies", mapping = c(study="PaperID", treatment="Trt", control="Ctrl"))`
3.  `soil <- apm_read("soil_management.csv", units = c(response="Mg ha-1", dose="kg N ha-1"))`

### 2. `apm_validate()` - release 0.1.0

**Source:** `R/data-validate.R`\
**Signature:**

``` r

apm_validate(data, schema = c("summary", "binary", "effect"), roles = NULL, strict = TRUE)
```

**Purpose:** Validate raw summary data, binary data, or precomputed
effect-size data before analysis.

**Arguments:** `data`: data.frame/apm_data; `schema`: expected data
family; `roles`: optional role map; `strict`: error vs issue table for
violations.

**Returns:** `apm_validation` with pass/fail status, issue table, field
diagnostics, and normalized role map.

**Backend:** Native validation layer.

**Validation contract:** Positive sample sizes; finite summaries; SD/SE
nonnegative; event counts within totals; `vi > 0`; IDs not missing; no
silent coercion of nonnumeric measurements.

**Unit-test file:** `tests/testthat/test-data-validate.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_validate(maize_n_shared, schema = "summary")`
2.  `apm_validate(pest_suppression_binary, schema = "binary")`
3.  `apm_validate(agri_effects_benchmark, schema = "effect")`

### 3. `apm_audit()` - release 0.1.0

**Source:** `R/data-audit.R`\
**Signature:**

``` r

apm_audit(data, plan = NULL, level = c("basic", "full"), repair = FALSE)
```

**Purpose:** Audit design semantics, duplicates, shared controls,
inconsistent units, missing uncertainty, and probable dependence.

**Arguments:** `data`: raw/effect data; `plan`: optional apm_plan;
`level`: audit depth; `repair`: only deterministic safe repairs such as
trimming labels, never statistical imputation.

**Returns:** `apm_audit` with severity-ranked issues, row IDs,
recommended action, and an audit trail.

**Backend:** Native; uses `vctrs`/base R for type consistency.

**Validation contract:** Never deletes observations; repairs must be
reversible and logged; statistical quantities are never imputed here.

**Unit-test file:** `tests/testthat/test-data-audit.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_audit(maize_n_shared, level = "full")`
2.  `apm_audit(agri_uncertainty_mixed, level = "full")`
3.  `apm_audit(soil_management_multiresponse, level = "basic")`

### 4. `apm_plan()` - release 0.1.0

**Source:** `R/plan.R`\
**Signature:**

``` r

apm_plan(data, study, treatment, control, response = NULL, experiment = NULL, effect_id = NULL, dose = NULL, site = NULL, year = NULL, outcome = NULL, block = NULL, time = NULL, cluster = NULL, units = NULL, design = c("auto", "independent", "paired"))
```

**Purpose:** Encode the agricultural estimand, experimental hierarchy,
treatment-control roles, and dependence structure before computing
effect sizes.

**Arguments:** Tidy-evaluated role columns plus `design`; `units`
optionally maps response/dose units.

**Returns:** `apm_plan` with role map, detected hierarchy,
control-sharing map, pairing status, candidate estimands, warnings, and
recommendations.

**Backend:** Native planning layer.

**Validation contract:** Treatment and control roles cannot be
identical; study ID required; `paired` requires compatible paired
information; dose must be numeric when supplied; unit conflicts are
reported.

**Unit-test file:** `tests/testthat/test-plan.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_plan(maize_n_shared, study=study_id, experiment=experiment_id, treatment=treatment, control=control, response=yield, dose=N_rate, site=site, year=year)`
2.  `apm_plan(wheat_paired_blocks, study=study_id, treatment=treatment, control=control, response=grain_yield, block=block_id, design="paired")`
3.  `apm_plan(bioinoculant_multicrop, study=study_id, treatment=inoculant, control=control, response=yield, outcome=outcome, site=site)`

### 5. `apm_recover_uncertainty()` - release 0.1.0

**Source:** `R/uncertainty.R`\
**Signature:**

``` r

apm_recover_uncertainty(data, mean, n, sd = NULL, se = NULL, cv = NULL, mse = NULL, ci_lower = NULL, ci_upper = NULL, level = 0.95, df = NULL, method = c("auto", "sd", "se", "cv", "mse", "ci"), impute = FALSE, group = NULL)
```

**Purpose:** Reconstruct SD from reported SE, CV, MSE, or confidence
intervals when algebraically justified, with explicit provenance.

**Arguments:** Summary-statistic columns; `level` and `df` for CI
conversion; `impute`: whether group-level imputation is allowed;
`group`: strata for optional imputation.

**Returns:** `apm_uncertainty`/data frame with recovered SD/SE,
derivation method, assumptions, and provenance flag.

**Backend:** Native formulas; optional `estmeansd` can be evaluated
later for median/range extensions, not core.

**Validation contract:** No silent imputation; CV conversion requires
compatible units and nonzero mean; MSE route requires design-compatible
residual variance; CI route requires valid level and df or documented
normal approximation.

**Unit-test file:** `tests/testthat/test-uncertainty.R`

**Numerical-test contract:** Closed-form checks: SD=SE*sqrt(n);
SD=CV*mean; SD=sqrt(MSE) where justified; CI inversion against
hand-calculated t critical values.

**Three required agronomic examples:**

1.  `apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, se=se_yield)`
2.  `apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, cv=cv_percent, method="cv")`
3.  `apm_recover_uncertainty(agri_uncertainty_mixed, mean=mean_yield, n=n, mse=residual_mse, method="mse")`

### 6. `apm_effect_size()` - release 0.1.0

**Source:** `R/effect-size.R`\
**Signature:**

``` r

apm_effect_size(data, measure = c("lnRR", "MD", "SMD", "VR", "CVR", "RR", "OR", "RD", "ZCOR", "GEN"), design = c("auto", "independent", "paired"), m_t = NULL, sd_t = NULL, n_t = NULL, m_c = NULL, sd_c = NULL, n_c = NULL, event_t = NULL, event_c = NULL, r = NULL, yi = NULL, vi = NULL, correct = TRUE, vtype = "LS", paired_standardization = c("change", "raw"), append = TRUE)
```

**Purpose:** Compute treatment-control effect sizes and sampling
variances, including paired/matched variants and variability effect
sizes.

**Arguments:** Measure, design, treatment/control summary columns,
optional paired correlation `r`, precomputed `yi`/`vi`, bias correction,
variance type, and paired standardization choice.

**Returns:** `apm_effects`, a tibble-like object containing `yi`, `vi`,
`sei`, effect measure, raw summaries, design metadata, transform
metadata, and provenance.

**Backend:** Primary:
[`metafor::escalc()`](https://wviechtb.github.io/metafor/reference/escalc.html).
Maps independent lnRR/VR/CVR to ROM/VR/CVR and paired analogues to
ROMC/VRC/CVRC; paired mean changes use MC/SMCC/SMCR families.

**Validation contract:** lnRR/CVR require positive means; n \> 1 for
variance-based continuous measures; paired designs require valid `r`
unless only point estimates are requested; binary counts must lie in
\[0,n\]; no mixing of measures in one fit unless explicitly modeled.

**Unit-test file:** `tests/testthat/test-effect-size.R`

**Numerical-test contract:** Golden equality to
[`metafor::escalc()`](https://wviechtb.github.io/metafor/reference/escalc.html)
for independent ROM/MD/SMD/VR/CVR, paired ROMC/VRC/CVRC/SMCC, and binary
RR/OR/RD within tolerance 1e-10 where formulas coincide.

**Three required agronomic examples:**

1.  `apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)`
2.  `apm_effect_size(covercrop_variability, "CVR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)`
3.  `apm_effect_size(wheat_paired_blocks, "lnRR", design="paired", m_t=mean_t, sd_t=sd_t, n_t=n_pairs, m_c=mean_c, sd_c=sd_c, n_c=n_pairs, r=r_tc)`

### 7. `apm_fit()` - release 0.1.0

**Source:** `R/fit-core.R`\
**Signature:**

``` r

apm_fit(effects, yi = yi, vi = vi, V = NULL, mods = ~ 1, model = c("random", "common", "mixed"), method = "REML", test = c("z", "t", "knha"), level = 0.95, weights = NULL, backend = c("auto", "metafor"), ...)
```

**Purpose:** Fit common-effect, random-effects, or mixed-effects
treatment-control meta-analysis.

**Arguments:** Effect object/data; effect/variance columns; optional
full sampling covariance `V`; moderators; model family; heterogeneity
estimator; inference method; confidence level; optional weights.

**Returns:** `apm_model` wrapping the backend fit plus standardized
coefficients, covariance, heterogeneity, model matrix, convergence data,
and provenance.

**Backend:**
[`metafor::rma.uni()`](https://wviechtb.github.io/metafor/reference/rma.uni.html)
for diagonal sampling variance;
[`metafor::rma.mv()`](https://wviechtb.github.io/metafor/reference/rma.mv.html)
when `V` is non-diagonal or hierarchy is required.

**Validation contract:** Finite yi/vi; positive variances; `V` symmetric
and dimensionally conformable; REML default; common-effect must be
explicit; `knha` only where supported; omitted rows recorded with
reasons.

**Unit-test file:** `tests/testthat/test-fit-core.R`

**Numerical-test contract:** Golden equality of coefficients, SE, tau²,
Q and logLik to
[`metafor::rma.uni`](https://wviechtb.github.io/metafor/reference/rma.uni.html)/`rma.mv`;
tolerance 1e-8 for deterministic optimizers.

**Three required agronomic examples:**

1.  `es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c); apm_fit(es)`
2.  `apm_fit(apm_effect_size(covercrop_variability, "VR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c), test="knha")`
3.  `apm_fit(agri_effects_benchmark, yi=yi, vi=vi, model="common")`

### 8. `apm_subgroup()` - release 0.1.0

**Source:** `R/subgroup.R`\
**Signature:**

``` r

apm_subgroup(effects, subgroup, method = "REML", test = "knha", interaction_test = TRUE, min_studies = 2, ...)
```

**Purpose:** Fit and compare prespecified agronomic subgroups without
conflating subgroup-specific significance with between-subgroup
evidence.

**Arguments:** Effect data; subgroup factor; heterogeneity/inference
methods; whether to test subgroup interaction; minimum independent
studies.

**Returns:** `apm_subgroup` with subgroup estimates, CIs/PIs,
heterogeneity, and omnibus interaction test.

**Backend:**
[`metafor::rma.uni()`](https://wviechtb.github.io/metafor/reference/rma.uni.html)/`rma.mv()`
depending dependence; `anova.rma` for joint tests.

**Validation contract:** Subgroups must be prespecified factors; reports
cluster counts; warns for sparse levels; never declares groups different
because one p-value is \<0.05 and another is not.

**Unit-test file:** `tests/testthat/test-subgroup.R`

**Numerical-test contract:** Subgroup models equal explicit per-level
`metafor` fits; omnibus moderator test equals single model with subgroup
factor.

**Three required agronomic examples:**

1.  `apm_subgroup(apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c), crop)`
2.  `apm_subgroup(apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c), climate_zone)`
3.  `apm_subgroup(agri_effects_benchmark, soil_texture, interaction_test=TRUE)`

### 9. `apm_heterogeneity()` - release 0.1.0

**Source:** `R/heterogeneity.R`\
**Signature:**

``` r

apm_heterogeneity(model, ci = TRUE, level = 0.95, method_ci = c("auto", "profile", "QP"))
```

**Purpose:** Summarize Q, tau², tau, I², H², residual heterogeneity, and
uncertainty without relying on I² alone.

**Arguments:** Fitted model; whether to calculate intervals; level;
interval method.

**Returns:** `apm_heterogeneity` with absolute and relative
heterogeneity measures and interval metadata.

**Backend:** `metafor` fit components and `confint.rma`; Bayesian models
dispatch to posterior summaries later.

**Validation contract:** Only reports measures defined for model type;
separates total and residual heterogeneity; multilevel decomposition
delegated to
[`apm_variance_components()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_variance_components.md).

**Unit-test file:** `tests/testthat/test-heterogeneity.R`

**Numerical-test contract:** Cross-check Q/tau²/I²/H² and profile/QP
intervals against `metafor` reference output.

**Three required agronomic examples:**

1.  `apm_heterogeneity(apm_fit(agri_effects_benchmark))`
2.  `apm_heterogeneity(apm_fit(apm_effect_size(covercrop_variability,"CVR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)))`
3.  `apm_heterogeneity(apm_fit(agri_effects_benchmark, mods=~ rainfall))`

### 10. `apm_prediction()` - release 0.1.0

**Source:** `R/prediction.R`\
**Signature:**

``` r

apm_prediction(model, newdata = NULL, level = 0.95, method = c("model", "HTS", "HK", "KR", "NNF"), transform = c("auto", "none", "exp", "percent"), threshold = NULL, ...)
```

**Purpose:** Calculate pooled or moderator-specific predictions with
confidence intervals, prediction intervals, and optional exceedance
probabilities.

**Arguments:** Model; new moderator data; interval method; output
transform; practical threshold.

**Returns:** `apm_prediction` with predicted mean effect, CI, PI,
transform, and optional probability relative to threshold.

**Backend:**
[`metafor::predict()`](https://wviechtb.github.io/metafor/reference/predict.rma.html)
by default; optional `pimeta` for HTS/HK/KR/NNF in supported univariate
settings.

**Validation contract:** PI only for models with heterogeneity; improved
PI methods restricted to compatible models; transform must match effect
measure; newdata levels validated against model terms.

**Unit-test file:** `tests/testthat/test-prediction.R`

**Numerical-test contract:** Golden equality to
[`metafor::predict`](https://wviechtb.github.io/metafor/reference/predict.rma.html);
optional PI parity with `pimeta` for supported methods, allowing
documented method-specific differences.

**Three required agronomic examples:**

1.  `apm_prediction(apm_fit(agri_effects_benchmark), transform="percent")`
2.  `apm_prediction(apm_fit(agri_effects_benchmark, mods=~ rainfall), newdata=data.frame(rainfall=c(600,900,1200)))`
3.  `apm_prediction(apm_fit(agri_effects_benchmark), method="NNF", transform="exp")`

### 11. `apm_threshold()` - release 0.1.0

**Source:** `R/threshold.R`\
**Signature:**

``` r

apm_threshold(model, threshold, scale = c("model", "ratio", "percent", "absolute"), direction = c("greater", "less", "two-sided"), prediction = TRUE)
```

**Purpose:** Evaluate practical agronomic relevance relative to a
user-defined minimally important effect.

**Arguments:** Model; threshold; threshold scale; direction; whether
predictive rather than mean-effect probability is requested.

**Returns:** `apm_threshold` with transformed threshold, mean-effect
conclusion, CI/PI relation, and probability where available.

**Backend:** Native transformation + `metafor::predict(prob=...)` where
supported; Bayesian dispatch later.

**Validation contract:** Threshold is never invented by package; scale
must be convertible from fitted measure; sign/direction explicitly
recorded.

**Unit-test file:** `tests/testthat/test-threshold.R`

**Numerical-test contract:** Threshold conversions checked exactly;
probability/PI relation verified on synthetic normal cases.

**Three required agronomic examples:**

1.  `apm_threshold(apm_fit(agri_effects_benchmark), threshold=5, scale="percent")`
2.  `apm_threshold(apm_fit(agri_effects_benchmark), threshold=1.10, scale="ratio", direction="greater")`
3.  `apm_threshold(apm_fit(agri_effects_benchmark), threshold=0, scale="model", direction="less")`

### 12. `apm_forest()` - release 0.1.0

**Source:** `R/plot-forest.R`\
**Signature:**

``` r

apm_forest(model, data = NULL, slab = NULL, transform = c("auto", "none", "exp", "percent"), sort = NULL, subgroup = NULL, prediction = TRUE, columns = NULL, interactive = FALSE, theme = "agri")
```

**Purpose:** Create publication-quality static or interactive
forest/estimation plots with agronomic metadata columns.

**Arguments:** Model; optional data/labels; transform; ordering;
subgroup; PI display; side columns; interactive flag; theme.

**Returns:** `ggplot` when static; `plotly` object when interactive;
plot data stored as attribute.

**Backend:** Native `ggplot2`; optional `plotly`; numerical summaries
from package model, not recomputed by plot.

**Validation contract:** Plot cannot alter estimates; all transformed
axes labeled; interactive mode requires plotly; columns must exist.

**Unit-test file:** `tests/testthat/test-plot-forest.R`

**Numerical-test contract:** Snapshot + plot-data equality to model
summaries; plots never alter estimates.

**Three required agronomic examples:**

1.  `apm_forest(apm_fit(agri_effects_benchmark), transform="percent", columns=c("crop","dose"))`
2.  `apm_forest(apm_fit(agri_effects_benchmark), subgroup="crop", prediction=TRUE)`
3.  `apm_forest(apm_fit(agri_effects_benchmark), interactive=TRUE)`

### 13. `apm_funnel()` - release 0.1.0

**Source:** `R/plot-funnel.R`\
**Signature:**

``` r

apm_funnel(model, yaxis = c("se", "vi", "precision", "n"), contour = FALSE, levels = c(0.90, 0.95, 0.99), label = FALSE, interactive = FALSE)
```

**Purpose:** Create funnel plots; `contour=TRUE` gives the
tunnel/contour-enhanced form requested in applied workflows.

**Arguments:** Model; vertical precision metric; contour flag and
levels; study labels; interactive flag.

**Returns:** Static `ggplot` or interactive `plotly` object, with
funnel-data attribute.

**Backend:** Native ggplot layer informed by `metafor` model quantities;
optional plotly.

**Validation contract:** Requires compatible SE/variance information;
warns that asymmetry is not equivalent to publication bias; contour
levels strictly between 0 and 1.

**Unit-test file:** `tests/testthat/test-plot-funnel.R`

**Numerical-test contract:** Plot-data parity to model yi/se; contour
geometry tested at known z critical values.

**Three required agronomic examples:**

1.  `apm_funnel(apm_fit(agri_effects_benchmark))`
2.  `apm_funnel(apm_fit(agri_effects_benchmark), contour=TRUE)`
3.  `apm_funnel(apm_fit(agri_effects_benchmark), yaxis="precision", interactive=TRUE)`

### 14. `apm_table()` - release 0.1.0

**Source:** `R/table.R`\
**Signature:**

``` r

apm_table(x, component = c("auto", "effects", "model", "heterogeneity", "metareg", "robust", "bayes", "sensitivity"), transform = c("auto", "none", "exp", "percent"), digits = 3, format = c("data.frame", "gt", "flextable"), ...)
```

**Purpose:** Produce a single standardized table interface for effect
sizes, models, heterogeneity, robust inference, Bayesian output, and
sensitivities.

**Arguments:** Package object; component; transform; digits; output
format.

**Returns:** data.frame/tibble by default; optional `gt` or `flextable`
object.

**Backend:** Native; optional `gt`/`flextable`.

**Validation contract:** Component must exist for object; formatting
never changes underlying values; rounding only at presentation layer.

**Unit-test file:** `tests/testthat/test-table.R`

**Numerical-test contract:** Formatting round-trip: underlying unrounded
numeric values identical to source object.

**Three required agronomic examples:**

1.  `apm_table(apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c), component="effects")`
2.  `apm_table(apm_fit(agri_effects_benchmark), component="model", transform="percent")`
3.  `apm_table(apm_heterogeneity(apm_fit(agri_effects_benchmark)), format="gt")`

### 15. `apm_shared_control()` - release 0.2.0

**Source:** `R/dependence-shared-control.R`\
**Signature:**

``` r

apm_shared_control(data, study, control_id, treatment_id = NULL, effect_id = NULL, check_values = TRUE)
```

**Purpose:** Detect multiple treatment contrasts that reuse the same
control arm within a study/experiment.

**Arguments:** Data and identifiers for study, control arm, treatment
arm, effect.

**Returns:** `apm_shared_control` map with contrast groups,
multiplicity, potentially duplicated control summaries, and recommended
covariance strategy.

**Backend:** Native design audit.

**Validation contract:** Control IDs must be stable within study;
optionally verifies identical control n/mean/SD across duplicated
records; flags rather than silently reconciles conflicts.

**Unit-test file:** `tests/testthat/test-dependence-shared-control.R`

**Numerical-test contract:** Exact detection against hand-constructed
duplicated-control fixtures.

**Three required agronomic examples:**

1.  `apm_shared_control(maize_n_shared, study=experiment_id, control_id=control_id, treatment_id=treatment)`
2.  `apm_shared_control(fertilizer_dose_response, study=study_id, control_id=control_id, treatment_id=dose)`
3.  `apm_shared_control(bioinoculant_multicrop, study=experiment_id, control_id=control_id, treatment_id=inoculant)`

### 16. `apm_vcov()` - release 0.2.0

**Source:** `R/dependence-vcov.R`\
**Signature:**

``` r

apm_vcov(effects, cluster, subgroup = NULL, obs = NULL, type = NULL, time1 = NULL, time2 = NULL, rho = NULL, phi = NULL, shared_control = TRUE, near_pd = FALSE, sparse = FALSE)
```

**Purpose:** Construct or approximate the sampling variance-covariance
matrix for dependent effect sizes.

**Arguments:** Effect data plus dependency descriptors, correlation
assumptions, shared-control flag, PD handling, sparse matrix option.

**Returns:** `apm_vcov`, a matrix with metadata describing exact/assumed
covariance blocks, rho/phi values, eigen diagnostics, and provenance.

**Backend:** Primary
[`metafor::vcalc()`](https://wviechtb.github.io/metafor/reference/vcalc.html)
plus measure-specific shared-control formulas where exact inputs are
available.

**Validation contract:** Matrix symmetric; diagonal matches `vi`;
positive semidefiniteness checked; `near_pd` is opt-in and logged;
assumed correlations never hidden.

**Unit-test file:** `tests/testthat/test-dependence-vcov.R`

**Numerical-test contract:** Diagonal equals vi; symmetry; PSD;
shared-control covariance checked against hand formulas and
[`metafor::vcalc()`](https://wviechtb.github.io/metafor/reference/vcalc.html).

**Three required agronomic examples:**

1.  `es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); apm_vcov(es, cluster=experiment_id, shared_control=TRUE)`
2.  `apm_vcov(soil_management_multiresponse_effects, cluster=study_id, type=outcome, rho=.5)`
3.  `apm_vcov(irrigation_repeated_effects, cluster=study_id, time1=time_month, phi=.7)`

### 17. `apm_pair_vcov()` - release 0.2.0

**Source:** `R/dependence-paired.R`\
**Signature:**

``` r

apm_pair_vcov(effects, pair_id, r, structure = c("paired", "compound", "user"), user_V = NULL)
```

**Purpose:** Build covariance structures for genuinely paired/matched
treatment-control effects or repeated measurements.

**Arguments:** Effect object; pair ID; correlation(s); structure;
optional user-supplied V.

**Returns:** `apm_vcov` with paired-block metadata and sensitivity-ready
correlation fields.

**Backend:** Native formulas plus `metafor` consistency checks.

**Validation contract:** `-1 < r < 1`; pair IDs must map to compatible
observations; user_V symmetry/PSD checked.

**Unit-test file:** `tests/testthat/test-dependence-paired.R`

**Numerical-test contract:** Hand-calculated paired covariance fixtures;
diagonal/PSD invariants.

**Three required agronomic examples:**

1.  `apm_pair_vcov(wheat_paired_effects, pair_id=study_id, r=.6)`
2.  `apm_pair_vcov(irrigation_repeated_effects, pair_id=study_id, r=.4, structure="compound")`
3.  `apm_pair_vcov(wheat_paired_effects, pair_id=study_id, r=.8)`

### 18. `apm_dependence_audit()` - release 0.2.0

**Source:** `R/dependence-audit.R`\
**Signature:**

``` r

apm_dependence_audit(effects, plan = NULL, V = NULL, cluster = NULL)
```

**Purpose:** Summarize all identified sources of non-independence and
whether the planned model addresses them.

**Arguments:** Effects, optional plan/V, optional robust cluster.

**Returns:** `apm_dependence_audit` with dependency graph, counts by
source, unresolved dependencies, and model recommendations.

**Backend:** Native.

**Validation contract:** Never assumes independence merely because V is
diagonal; checks repeated study IDs, shared controls, repeated
outcomes/times, and hierarchy.

**Unit-test file:** `tests/testthat/test-dependence-audit.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_dependence_audit(maize_n_shared_effects, plan=maize_plan)`
2.  `apm_dependence_audit(soil_management_multiresponse_effects, cluster=study_id)`
3.  `apm_dependence_audit(wheat_paired_effects, V=apm_pair_vcov(wheat_paired_effects, pair_id=study_id, r=.6))`

### 19. `apm_rho_sensitivity()` - release 0.2.0

**Source:** `R/sensitivity-rho.R`\
**Signature:**

``` r

apm_rho_sensitivity(effects, rho = seq(0, 0.9, 0.1), build_vcov, fit = NULL, metric = c("estimate", "se", "ci", "pi", "tau2"), ...)
```

**Purpose:** Evaluate how conclusions change over plausible unknown
within-study/paired correlations.

**Arguments:** Effects; rho grid; a V-building specification/function;
optional base fit; output metric.

**Returns:** `apm_sensitivity` with model results by rho, stability
flags, and plot-ready data.

**Backend:** Repeated
[`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md)/[`apm_fit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_fit.md)
calls; backend inherited.

**Validation contract:** Rho grid in valid interval; failures retained
with reason; no cherry-picking of preferred rho.

**Unit-test file:** `tests/testthat/test-sensitivity-rho.R`

**Numerical-test contract:** At each rho, output must equal direct
`apm_vcov` + `apm_fit`; ordering invariant.

**Three required agronomic examples:**

1.  `apm_rho_sensitivity(wheat_paired_effects, rho=seq(.2,.8,.1), build_vcov=list(pair_id="study_id"))`
2.  `apm_rho_sensitivity(soil_management_multiresponse_effects, rho=c(.25,.5,.75), build_vcov=list(cluster="study_id", type="outcome"))`
3.  `apm_rho_sensitivity(irrigation_repeated_effects, rho=seq(0,.9,.15), build_vcov=list(cluster="study_id"))`

### 20. `apm_multilevel()` - release 0.2.0

**Source:** `R/fit-multilevel.R`\
**Signature:**

``` r

apm_multilevel(effects, random = ~ 1 | study_id/effect_id, V = NULL, mods = ~ 1, struct = "CS", method = "REML", test = "t", dfs = c("contain", "residual"), ...)
```

**Purpose:** Fit hierarchical meta-analytic models for study,
experiment, site, year, outcome, or effect nesting.

**Arguments:** Effects; random-effects formula; sampling covariance;
moderators; covariance structure; estimator; tests/df method.

**Returns:** `apm_multilevel` inheriting from `apm_model`, with backend
random-effect structure and variance components.

**Backend:**
[`metafor::rma.mv()`](https://wviechtb.github.io/metafor/reference/rma.mv.html).

**Validation contract:** Grouping columns required; nesting checked for
accidental cross-classification; V dimensions checked; warns when random
structure is not identifiable.

**Unit-test file:** `tests/testthat/test-fit-multilevel.R`

**Numerical-test contract:** Golden coefficients/variance
components/logLik against
[`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html)
on frozen hierarchical fixtures.

**Three required agronomic examples:**

1.  `apm_multilevel(maize_n_shared_effects, random=~1|study_id/experiment_id/effect_id, V=maize_V)`
2.  `apm_multilevel(soil_management_multiresponse_effects, random=~1|study_id/outcome, V=soil_V)`
3.  `apm_multilevel(irrigation_repeated_effects, random=~1|study_id/site_id/effect_id, V=irrigation_V)`

### 21. `apm_variance_components()` - release 0.2.0

**Source:** `R/variance-components.R`\
**Signature:**

``` r

apm_variance_components(model, level = 0.95, proportion = TRUE)
```

**Purpose:** Extract and interpret heterogeneity variance by level in
multilevel or multivariate models.

**Arguments:** Multilevel/multivariate model; interval level; whether to
report proportional allocation.

**Returns:** `apm_variance_components` with component variance/SD,
uncertainty where available, and percentage of modeled heterogeneity.

**Backend:** `metafor`/`mixmeta` extraction; profile CIs where feasible.

**Validation contract:** Only defined components reported; percentages
based on heterogeneity components, not total observed variance, and are
labeled accordingly.

**Unit-test file:** `tests/testthat/test-variance-components.R`

**Numerical-test contract:** Exact extraction from backend plus
sum/proportion invariants.

**Three required agronomic examples:**

1.  `apm_variance_components(apm_multilevel(maize_n_shared_effects, random=~1|study_id/experiment_id/effect_id, V=maize_V))`
2.  `apm_variance_components(apm_multilevel(soil_management_multiresponse_effects, random=~1|study_id/outcome, V=soil_V))`
3.  `apm_variance_components(apm_multilevel(irrigation_repeated_effects, random=~1|study_id/site_id/effect_id, V=irrigation_V), proportion=FALSE)`

### 22. `apm_robust()` - release 0.2.0

**Source:** `R/robust.R`\
**Signature:**

``` r

apm_robust(model, cluster, vcov = c("CR2", "CR1", "CR0"), test = c("Satterthwaite", "saddlepoint"), constraints = NULL)
```

**Purpose:** Apply cluster-robust variance estimation and small-sample
inference to dependent-effect meta-analysis.

**Arguments:** Fitted model; independent cluster; CR estimator;
single-coefficient test type; optional joint constraints.

**Returns:** `apm_robust` with robust vcov, coefficient tests, df, joint
tests, cluster counts, and comparison to model-based inference.

**Backend:** Primary
[`clubSandwich::vcovCR()`](http://jepusto.github.io/clubSandwich/reference/vcovCR.md),
`coef_test()`, `Wald_test()`; compatible
`metafor::robust(..., clubSandwich=TRUE)` path used for parity checks.

**Validation contract:** Cluster count and leverage diagnosed; CR2
default; warns for low denominator df; constraints dimension checked.

**Unit-test file:** `tests/testthat/test-robust.R`

**Numerical-test contract:** Golden CR2 vcov and Satterthwaite/HTZ
results against `clubSandwich` 0.7.0.

**Three required agronomic examples:**

1.  `apm_robust(apm_multilevel(maize_n_shared_effects, random=~1|study_id/effect_id, V=maize_V), cluster=maize_n_shared_effects$study_id)`
2.  `apm_robust(apm_fit(irrigation_effects, mods=~rainfall), cluster=irrigation_effects$study_id)`
3.  `apm_robust(apm_fit(bioinoculant_effects, mods=~crop+inoculant), cluster=bioinoculant_effects$study_id, constraints="crop")`

### 23. `apm_wild_bootstrap()` - release 0.2.0

**Source:** `R/wild-bootstrap.R`\
**Signature:**

``` r

apm_wild_bootstrap(model, cluster, constraints = NULL, R = 9999, seed = NULL, type = c("Rademacher", "Mammen"), parallel = FALSE)
```

**Purpose:** Perform cluster wild-bootstrap tests for coefficients or
joint moderator hypotheses when cluster counts are limited.

**Arguments:** Model; cluster; constraints; bootstrap replications;
seed; weights; parallel flag.

**Returns:** `apm_wild` with test statistic, bootstrap p-value, Monte
Carlo SE, failures, seed, and settings.

**Backend:** `wildmeta` for supported
[`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html)/`robumeta`
fits; internal wrapper standardizes output.

**Validation contract:** Requires supported model; R positive integer;
seed recorded; bootstrap failures counted; heavy examples precomputed in
vignettes.

**Unit-test file:** `tests/testthat/test-wild-bootstrap.R`

**Numerical-test contract:** Seeded parity to `wildmeta`
p-values/statistics on small frozen bootstrap fixture; Monte Carlo SE
reported.

**Three required agronomic examples:**

1.  `apm_wild_bootstrap(apm_fit(irrigation_effects, mods=~rainfall), cluster=irrigation_effects$study_id, R=499, seed=42)`
2.  `apm_wild_bootstrap(apm_fit(bioinoculant_effects, mods=~crop), cluster=bioinoculant_effects$study_id, constraints="crop", R=999, seed=42)`
3.  `apm_wild_bootstrap(apm_multilevel(maize_n_shared_effects, random=~1|study_id/effect_id, V=maize_V), cluster=maize_n_shared_effects$study_id, R=499, seed=42)`

### 24. `apm_compare_inference()` - release 0.2.0

**Source:** `R/compare-inference.R`\
**Signature:**

``` r

apm_compare_inference(model, robust = NULL, wild = NULL, methods = c("model", "CR2", "wild"), transform = c("auto", "none", "exp", "percent"))
```

**Purpose:** Compare conventional, cluster-robust, and wild-bootstrap
inference without selecting the most favorable result.

**Arguments:** Base model; optional robust/wild objects; method set;
transform.

**Returns:** `apm_inference_comparison` with aligned estimates,
SE/CI/df/p-values and discrepancy flags.

**Backend:** Native reconciliation of existing model objects.

**Validation contract:** All compared objects must refer to same
estimand/model coefficients; discrepancies in model formula or data hash
are fatal.

**Unit-test file:** `tests/testthat/test-compare-inference.R`

**Numerical-test contract:** Aligned rows must equal source objects;
data/model hashes must block incompatible comparisons.

**Three required agronomic examples:**

1.  `apm_compare_inference(irrigation_fit, robust=irrigation_cr2)`
2.  `apm_compare_inference(bioinoculant_fit, robust=bio_cr2, wild=bio_wild)`
3.  `apm_compare_inference(maize_ml, robust=maize_cr2, transform="percent")`

### 25. `apm_metareg()` - release 0.3.0

**Source:** `R/metareg.R`\
**Signature:**

``` r

apm_metareg(effects, moderators, V = NULL, random = NULL, method = "REML", test = "t", center = TRUE, scale = FALSE, interactions = NULL, ...)
```

**Purpose:** Fit agronomic meta-regression with continuous and
categorical moderators.

**Arguments:** Effects; moderator formula; sampling covariance; optional
random structure; estimator/test; centering/scaling; prespecified
interactions.

**Returns:** `apm_metareg` inheriting `apm_model`, plus moderator
metadata, centering constants, joint tests, residual heterogeneity, and
meta-R² descriptors.

**Backend:**
[`metafor::rma.uni`](https://wviechtb.github.io/metafor/reference/rma.uni.html)/`rma.mv`.

**Validation contract:** Continuous moderators numeric; factor reference
levels recorded; support/overlap checked; sparse categories warned; no
automatic stepwise selection.

**Unit-test file:** `tests/testthat/test-metareg.R`

**Numerical-test contract:** Golden coefficients/vcov/QE/QM against
`metafor`; centering transformation invariance.

**Three required agronomic examples:**

1.  `apm_metareg(irrigation_effects, ~ rainfall + mean_temp)`
2.  `apm_metareg(bioinoculant_effects, ~ crop + inoculant)`
3.  `apm_metareg(maize_n_shared_effects, ~ soil_organic_matter + rainfall, V=maize_V, random=~1|study_id/effect_id)`

### 26. `apm_marginal_effects()` - release 0.3.0

**Source:** `R/marginal-effects.R`\
**Signature:**

``` r

apm_marginal_effects(model, variables = NULL, at = NULL, weights = c("equal", "study"), transform = c("auto", "none", "exp", "percent"), level = 0.95)
```

**Purpose:** Compute adjusted marginal meta-analytic predictions for
agronomic moderator levels.

**Arguments:** Meta-regression model; variables; evaluation grid;
marginalization weights; transform; level.

**Returns:** `apm_marginal` with adjusted predictions, CI/PI where
defined, and contrast-ready grid.

**Backend:** Native linear predictor using model coefficient/vcov;
cross-check with `emmeans` where available.

**Validation contract:** No extrapolation beyond observed continuous
moderator range unless explicitly allowed in future; factor levels must
exist; weighting rule reported.

**Unit-test file:** `tests/testthat/test-marginal-effects.R`

**Numerical-test contract:** Matrix-contrast calculations checked
manually and against `emmeans` where compatible.

**Three required agronomic examples:**

1.  `apm_marginal_effects(apm_metareg(bioinoculant_effects,~crop+inoculant), variables="crop")`
2.  `apm_marginal_effects(apm_metareg(irrigation_effects,~rainfall*climate_zone), at=list(rainfall=c(600,900,1200)))`
3.  `apm_marginal_effects(apm_metareg(maize_n_shared_effects,~soil_texture+N_rate,V=maize_V,random=~1|study_id/effect_id), variables="soil_texture")`

### 27. `apm_interaction()` - release 0.3.0

**Source:** `R/interaction.R`\
**Signature:**

``` r

apm_interaction(model, term, at = NULL, contrast = c("difference", "ratio"), adjust = "none", level = 0.95)
```

**Purpose:** Interpret prespecified interactions through simple effects
and contrasts rather than raw coefficient tables alone.

**Arguments:** Meta-regression model; interaction term; evaluation
values; contrast scale; multiplicity adjustment; level.

**Returns:** `apm_interaction` with simple slopes/effects, contrasts,
joint test, and plot-ready data.

**Backend:** Native model-matrix contrasts; optional clubSandwich robust
path if model carries robust vcov.

**Validation contract:** Requested interaction must exist; at-values
checked against support; adjustment from `p.adjust.methods` only.

**Unit-test file:** `tests/testthat/test-interaction.R`

**Numerical-test contract:** Simple effects/contrasts checked by
model-matrix algebra and
[`clubSandwich::linear_contrast`](http://jepusto.github.io/clubSandwich/reference/linear_contrast.md)
when robust.

**Three required agronomic examples:**

1.  `apm_interaction(apm_metareg(irrigation_effects,~rainfall*climate_zone), term="rainfall:climate_zone", at=list(rainfall=c(600,900)))`
2.  `apm_interaction(apm_metareg(bioinoculant_effects,~crop*inoculant), term="crop:inoculant")`
3.  `apm_interaction(apm_metareg(maize_n_shared_effects,~N_rate*soil_texture,V=maize_V,random=~1|study_id/effect_id), term="N_rate:soil_texture")`

### 28. `apm_metareg_curve()` - release 0.3.0

**Source:** `R/metareg-curve.R`\
**Signature:**

``` r

apm_metareg_curve(effects, x, form = c("linear", "quadratic", "cubic", "ns", "rcs"), df = 3, knots = NULL, V = NULL, random = NULL, method = "REML", level = 0.95, grid = 100)
```

**Purpose:** Fit and predict smooth or polynomial relationships between
effect size and a quantitative agronomic moderator.

**Arguments:** Effects; quantitative moderator; functional form; spline
df/knots; covariance/random structure; estimator; grid.

**Returns:** `apm_curve`/`apm_metareg` with basis definition, fit,
prediction grid, CI/PI, and support diagnostics.

**Backend:** `metafor` with base
[`splines::ns`](https://rdrr.io/r/splines/ns.html); restricted cubic
splines via internal basis or optional `rms`-compatible basis.

**Validation contract:** x numeric with adequate unique values;
polynomial hierarchy preserved; knots inside data support; extrapolation
marked.

**Unit-test file:** `tests/testthat/test-metareg-curve.R`

**Numerical-test contract:** Basis matrix and predictions cross-checked
against direct `metafor` fits with identical polynomial/spline basis.

**Three required agronomic examples:**

1.  `apm_metareg_curve(irrigation_effects, x=rainfall, form="linear")`
2.  `apm_metareg_curve(irrigation_effects, x=rainfall, form="quadratic")`
3.  `apm_metareg_curve(maize_n_shared_effects, x=N_rate, form="ns", df=4, V=maize_V, random=~1|study_id/effect_id)`

### 29. `apm_model_compare()` - release 0.3.0

**Source:** `R/model-compare.R`\
**Signature:**

``` r

apm_model_compare(..., criterion = c("AICc", "AIC", "BIC", "LRT"), refit_ml = TRUE, weights = TRUE)
```

**Purpose:** Compare prespecified meta-regression functional forms using
compatible likelihood criteria and hierarchical rules.

**Arguments:** Two or more fitted package models; criterion; ML refit
for fixed-effect comparison; model weights.

**Returns:** `apm_model_comparison` with fit criteria, deltas, weights,
nesting metadata, and warnings.

**Backend:**
[`metafor::fitstats`](https://wviechtb.github.io/metafor/reference/fitstats.html)/`anova`;
native AICc.

**Validation contract:** Models must use same effect data and
likelihood-compatible variance structure; LRT only for nested models; no
selection solely by p-value.

**Unit-test file:** `tests/testthat/test-model-compare.R`

**Numerical-test contract:** AIC/BIC/logLik parity; AICc hand formula;
LRT only for nested compatible models.

**Three required agronomic examples:**

1.  `apm_model_compare(irrig_lin, irrig_quad, criterion="AICc")`
2.  `apm_model_compare(maize_lin, maize_ns, criterion="AIC")`
3.  `apm_model_compare(bio_main, bio_interaction, criterion="LRT")`

### 30. `apm_predict_context()` - release 0.3.0

**Source:** `R/predict-context.R`\
**Signature:**

``` r

apm_predict_context(model, newdata, level = 0.95, prediction = TRUE, threshold = NULL, transform = c("auto", "none", "exp", "percent"))
```

**Purpose:** Predict treatment effect for explicit agronomic contexts
such as rainfall, soil texture, crop, or dose.

**Arguments:** Meta-regression model; new context rows; level; PI flag;
practical threshold; transform.

**Returns:** `apm_prediction` including context columns and
interpolation/extrapolation flags.

**Backend:**
[`metafor::predict()`](https://wviechtb.github.io/metafor/reference/predict.rma.html)
with validated model matrix.

**Validation contract:** New factor levels rejected; continuous support
flagged; context rows retain all units and transforms.

**Unit-test file:** `tests/testthat/test-predict-context.R`

**Numerical-test contract:** Exact equality to direct backend prediction
from validated model matrix.

**Three required agronomic examples:**

1.  `apm_predict_context(apm_metareg(irrigation_effects,~rainfall+mean_temp), data.frame(rainfall=800, mean_temp=24))`
2.  `apm_predict_context(apm_metareg(bioinoculant_effects,~crop+inoculant), data.frame(crop="maize", inoculant="Bradyrhizobium"))`
3.  `apm_predict_context(apm_metareg(maize_n_shared_effects,~N_rate+soil_organic_matter,V=maize_V,random=~1|study_id/effect_id), data.frame(N_rate=120, soil_organic_matter=25), threshold=5, transform="percent")`

### 31. `apm_curve_features()` - release 0.3.0

**Source:** `R/curve-features.R`\
**Signature:**

``` r

apm_curve_features(curve, features = c("slope", "turning_point", "threshold_crossing"), threshold = NULL, interval = TRUE, level = 0.95)
```

**Purpose:** Extract interpretable features from quantitative moderator
curves, without presenting observational moderator optima as causal
recommendations.

**Arguments:** Curve object; requested features; practical threshold;
interval flag/level.

**Returns:** `apm_curve_features` with derivatives, turning points,
crossing locations, uncertainty and causal-caution labels.

**Backend:** Analytic derivatives for polynomial bases; numerical
derivatives/root finding for splines.

**Validation contract:** Turning point only within observed support;
threshold crossing requires threshold; warns that moderator-response
associations are not automatically causal dose recommendations.

**Unit-test file:** `tests/testthat/test-curve-features.R`

**Numerical-test contract:** Analytic polynomial derivatives and roots
compared with symbolic/hand values; spline derivatives checked by finite
differences.

**Three required agronomic examples:**

1.  `apm_curve_features(irrig_quad, features=c("slope","turning_point"))`
2.  `apm_curve_features(maize_ns, features="threshold_crossing", threshold=log(1.05))`
3.  `apm_curve_features(irrig_ns, features="slope")`

### 32. `apm_dose_response()` - release 0.3.0

**Source:** `R/dose-response.R`\
**Signature:**

``` r

apm_dose_response(data, effect, dose, study, V = NULL, form = c("linear", "quadratic", "ns"), df = 3, method = "reml", covariance = c("auto", "user"), reference = 0, moderators = NULL, ...)
```

**Purpose:** Fit true within-study multiple-dose response meta-analysis
while respecting correlation among doses sharing a control/reference.

**Arguments:** Dose-response data; effect/dose/study columns;
covariance; curve form; method; reference dose; optional study-level
moderators.

**Returns:** `apm_dose` with backend model, dose basis, covariance
specification, prediction grid, GOF and provenance.

**Backend:** Primary `dosresmeta` 2.2.x with `mixmeta` infrastructure;
fallback
[`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html)
for supported custom V.

**Validation contract:** At least two dose levels per contributing study
where needed; reference dose defined; dose units homogeneous or
converted; shared-reference covariance required/approximated
transparently.

**Unit-test file:** `tests/testthat/test-dose-response.R`

**Numerical-test contract:** Golden coefficients/vcov/predictions
against `dosresmeta` 2.2.0 and overlapping `mixmeta` models.

**Three required agronomic examples:**

1.  `apm_dose_response(fertilizer_dose_response, effect=lnRR, dose=N_rate, study=study_id, form="linear")`
2.  `apm_dose_response(fertilizer_dose_response, effect=lnRR, dose=N_rate, study=study_id, form="quadratic")`
3.  `apm_dose_response(fertilizer_dose_response, effect=lnRR, dose=N_rate, study=study_id, form="ns", df=4, moderators=~soil_texture)`

### 33. `apm_dose_plot()` - release 0.3.0

**Source:** `R/plot-dose.R`\
**Signature:**

``` r

apm_dose_plot(model, transform = c("auto", "none", "exp", "percent"), observed = TRUE, prediction = TRUE, rug = TRUE, interactive = FALSE)
```

**Purpose:** Plot dose-response meta-analytic curves with observed
effects, CI/PI, and dose support.

**Arguments:** Dose/curve model; transform; observed points; PI; rug;
interactive.

**Returns:** ggplot/plotly object with plot-data attribute.

**Backend:** Native ggplot2/plotly using model predictions.

**Validation contract:** No extrapolation visually disguised;
extrapolated grid segment marked; observed effect weights optional via
point size.

**Unit-test file:** `tests/testthat/test-plot-dose.R`

**Numerical-test contract:** Plot-data equality to `predict.apm_dose`;
support/extrapolation labels tested.

**Three required agronomic examples:**

1.  `apm_dose_plot(apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="linear"), transform="percent")`
2.  `apm_dose_plot(apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="quadratic"), prediction=TRUE)`
3.  `apm_dose_plot(apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="ns",df=4), interactive=TRUE)`

### 34. `apm_bubble()` - release 0.3.0

**Source:** `R/plot-bubble.R`\
**Signature:**

``` r

apm_bubble(model, x, size = c("weight", "precision", "equal"), transform = c("auto", "none", "exp", "percent"), prediction = TRUE, interactive = FALSE)
```

**Purpose:** Create meta-regression bubble plots using scientifically
meaningful weights and uncertainty bands.

**Arguments:** Meta-regression model; x moderator; point-size rule;
transform; PI; interactive.

**Returns:** ggplot/plotly object.

**Backend:** Native ggplot2/plotly.

**Validation contract:** x must be in fitted model; weight definition
explicitly labeled; prediction bands calculated from model not smoothers
fitted by plot.

**Unit-test file:** `tests/testthat/test-plot-bubble.R`

**Numerical-test contract:** Curve and intervals equal meta-regression
prediction data; point sizes equal declared weighting rule.

**Three required agronomic examples:**

1.  `apm_bubble(apm_metareg(irrigation_effects,~rainfall), x=rainfall, transform="percent")`
2.  `apm_bubble(apm_metareg(maize_n_shared_effects,~soil_organic_matter,V=maize_V,random=~1|study_id/effect_id), x=soil_organic_matter)`
3.  `apm_bubble(apm_metareg(irrigation_effects,~mean_temp), x=mean_temp, interactive=TRUE)`

### 35. `apm_multivariate()` - release 0.4.0

**Source:** `R/multivariate.R`\
**Signature:**

``` r

apm_multivariate(effects, outcome, study, V = NULL, mods = ~ 1, random = NULL, structure = c("UN", "CS", "DIAG"), method = "REML", backend = c("auto", "metafor", "mixmeta"), ...)
```

**Purpose:** Jointly synthesize multiple agronomic outcomes while
modeling within-study and between-outcome dependence.

**Arguments:** Effects; outcome and study IDs; within-study covariance;
moderators/random structure; between-outcome covariance structure;
backend.

**Returns:** `apm_multivariate` with outcome-specific pooled effects,
covariance matrices, cross-outcome heterogeneity, predictions, and
backend fit.

**Backend:**
[`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html)
or `mixmeta` 1.2.2; parity tests required for overlapping models.

**Validation contract:** Outcome labels stable; V complete/approximated;
structure identifiable; mixed effect measures prohibited unless on
coherent scale.

**Unit-test file:** `tests/testthat/test-multivariate.R`

**Numerical-test contract:** Golden coefficients/Psi/logLik against
`mixmeta` 1.2.2 and overlapping
[`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html)
models.

**Three required agronomic examples:**

1.  `apm_multivariate(soil_management_multiresponse_effects, outcome=outcome, study=study_id, V=soil_multi_V)`
2.  `apm_multivariate(soil_management_multiresponse_effects, outcome=outcome, study=study_id, V=soil_multi_V, mods=~climate_zone)`
3.  `apm_multivariate(biochar_multiresponse_effects, outcome=outcome, study=study_id, V=biochar_V, structure="CS", backend="mixmeta")`

### 36. `apm_mvcor_sensitivity()` - release 0.4.0

**Source:** `R/sensitivity-mvcor.R`\
**Signature:**

``` r

apm_mvcor_sensitivity(effects, outcome, study, rho = c(0, 0.25, 0.5, 0.75), fit_args = list(), metric = c("estimate", "se", "tau", "cor"))
```

**Purpose:** Assess sensitivity of multivariate synthesis to unknown
within-study outcome correlations.

**Arguments:** Effects; outcome/study; rho grid; arguments passed to
multivariate fit; reported metric.

**Returns:** `apm_sensitivity` with estimates and variance components
across assumed correlations.

**Backend:** Repeated
[`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md) +
[`apm_multivariate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate.md).

**Validation contract:** Rho values valid; covariance blocks checked
PSD; conclusions summarized across full grid.

**Unit-test file:** `tests/testthat/test-sensitivity-mvcor.R`

**Numerical-test contract:** Each rho fit equals independently
constructed V and direct multivariate fit.

**Three required agronomic examples:**

1.  `apm_mvcor_sensitivity(soil_management_multiresponse_effects, outcome=outcome, study=study_id, rho=c(.25,.5,.75))`
2.  `apm_mvcor_sensitivity(biochar_multiresponse_effects, outcome=outcome, study=study_id, rho=seq(0,.8,.2), metric="tau")`
3.  `apm_mvcor_sensitivity(soil_management_multiresponse_effects, outcome=outcome, study=study_id, rho=c(0,.5), fit_args=list(mods=~climate_zone))`

### 37. `apm_prior()` - release 0.4.0

**Source:** `R/bayes-prior.R`\
**Signature:**

``` r

apm_prior(effect = NULL, tau = NULL, moderators = NULL, model_probability = NULL, scale = c("model", "natural"), family = NULL, notes = NULL)
```

**Purpose:** Create an explicit, inspectable prior specification
independent of a particular Bayesian backend.

**Arguments:** Prior definitions for pooled effect, heterogeneity,
moderators and model probabilities; scale/family; notes.

**Returns:** `apm_prior` backend-neutral specification with
transformations and rationale fields.

**Backend:** Native specification translated to `bayesmeta`, `RoBMA`, or
`brms` adapters.

**Validation contract:** Priors proper where backend requires; scale
compatibility checked; defaults always inspectable and never hidden.

**Unit-test file:** `tests/testthat/test-bayes-prior.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_prior(effect=list(dist="normal", mean=0, sd=.2), tau=list(dist="halfnormal", scale=.2))`
2.  `apm_prior(effect=list(dist="normal", mean=0, sd=.1), moderators=list(rainfall=list(dist="normal", mean=0, sd=.05)))`
3.  `apm_prior(effect=list(dist="normal", mean=0, sd=.3), model_probability=list(effect=.5, heterogeneity=.5), notes="weakly informative lnRR prior")`

### 38. `apm_prior_check()` - release 0.4.0

**Source:** `R/bayes-prior-check.R`\
**Signature:**

``` r

apm_prior_check(prior, measure, x = NULL, thresholds = NULL, draws = 5000, seed = NULL, plot = TRUE)
```

**Purpose:** Inspect prior implications on model and agronomic scales
before fitting.

**Arguments:** Prior spec; effect measure; optional moderator values;
practical thresholds; prior draws; seed; plot.

**Returns:** `apm_prior_check` with simulated prior summaries, implied
percent/ratio effects, tail probabilities, and optional ggplot.

**Backend:** Native sampling for supported priors; backend prior-only
modes for RoBMA/brms when needed.

**Validation contract:** Seed recorded; transformation consistent with
measure; impossible prior scales rejected.

**Unit-test file:** `tests/testthat/test-bayes-prior-check.R`

**Numerical-test contract:** Seeded prior draws reproduce summaries;
transformations checked analytically.

**Three required agronomic examples:**

1.  `apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)), measure="lnRR", thresholds=log(c(.8,1.2)), seed=1)`
2.  `apm_prior_check(irrig_prior, measure="lnRR", x=data.frame(rainfall=c(600,1200)), seed=1)`
3.  `apm_prior_check(cvr_prior, measure="CVR", seed=1)`

### 39. `apm_bayes()` - release 0.4.0

**Source:** `R/bayes-fit.R`\
**Signature:**

``` r

apm_bayes(effects, mods = ~ 1, cluster = NULL, prior = NULL, backend = c("auto", "bayesmeta", "RoBMA", "brms"), bias_adjust = FALSE, chains = 4, iter = 4000, warmup = 1000, seed = NULL, ...)
```

**Purpose:** Fit Bayesian univariate, meta-regression, multilevel, or
publication-bias-adjusted meta-analysis through a unified API.

**Arguments:** Effects; moderators; cluster; priors; backend; bias
adjustment; MCMC controls.

**Returns:** `apm_bayes` with standardized posterior draws/summaries,
backend object, priors, diagnostics, predictive metadata, and
reproducibility info.

**Backend:** `bayesmeta` 3.5 for fast normal-normal
models/meta-regression; `RoBMA` 4.0 for model averaging/bias/multilevel;
`brms` optional for structures unsupported elsewhere.

**Validation contract:** Backend capability routing explicit; JAGS/Stan
availability checked; effect measure mapped; seeds and versions saved;
convergence required before interpretation.

**Unit-test file:** `tests/testthat/test-bayes-fit.R`

**Numerical-test contract:** Frozen posterior summaries compared to
backend reference within Monte Carlo error; exact deterministic parity
for `bayesmeta` numerical integration.

**Three required agronomic examples:**

1.  `apm_bayes(agri_effects_benchmark, backend="bayesmeta", prior=apm_prior(effect=list(dist="normal",mean=0,sd=.2)))`
2.  `apm_bayes(irrigation_effects, mods=~rainfall, backend="bayesmeta", seed=1)`
3.  `apm_bayes(maize_n_shared_effects, cluster=study_id, mods=~N_rate, backend="RoBMA", seed=1)`

### 40. `apm_bayes_predict()` - release 0.4.0

**Source:** `R/bayes-predict.R`\
**Signature:**

``` r

apm_bayes_predict(model, newdata = NULL, probs = c(0.025, 0.5, 0.975), predictive = TRUE, transform = c("auto", "none", "exp", "percent"))
```

**Purpose:** Produce posterior mean-effect and new-study predictive
distributions on interpretable agronomic scales.

**Arguments:** Bayesian model; context; posterior quantiles; predictive
flag; transform.

**Returns:** `apm_bayes_prediction` with posterior summaries and
optionally draws.

**Backend:** Backend-specific `predict`/posterior functions normalized
to package format.

**Validation contract:** Model convergence checked; newdata support
validated; transformed medians distinguished from transformed means
where relevant.

**Unit-test file:** `tests/testthat/test-bayes-predict.R`

**Numerical-test contract:** Posterior/predictive quantiles checked
against backend draws/functions.

**Three required agronomic examples:**

1.  `apm_bayes_predict(bayes_yield, transform="percent")`
2.  `apm_bayes_predict(bayes_irrig, newdata=data.frame(rainfall=c(700,1000)), transform="percent")`
3.  `apm_bayes_predict(bayes_maize, newdata=data.frame(N_rate=120), predictive=TRUE)`

### 41. `apm_bayes_threshold()` - release 0.4.0

**Source:** `R/bayes-threshold.R`\
**Signature:**

``` r

apm_bayes_threshold(model, threshold, scale = c("model", "ratio", "percent", "absolute"), direction = c("greater", "less", "two-sided"), predictive = FALSE, rope = NULL)
```

**Purpose:** Quantify posterior probability that an effect exceeds a
user-defined agronomic relevance threshold and optionally lies in a
ROPE.

**Arguments:** Bayesian model; threshold/scale/direction; predictive vs
parameter probability; optional ROPE.

**Returns:** `apm_bayes_threshold` with posterior probability,
predictive probability, ROPE probability, and decision-neutral
interpretation.

**Backend:** Native calculations from posterior draws.

**Validation contract:** Threshold/ROPE user supplied; predictive and
parameter probabilities labeled separately; no automatic accept/reject
rule.

**Unit-test file:** `tests/testthat/test-bayes-threshold.R`

**Numerical-test contract:** Probability from stored draws checked by
direct indicator means.

**Three required agronomic examples:**

1.  `apm_bayes_threshold(bayes_yield, threshold=5, scale="percent")`
2.  `apm_bayes_threshold(bayes_irrig, threshold=10, scale="percent", predictive=TRUE)`
3.  `apm_bayes_threshold(bayes_cvr, threshold=0, scale="model", direction="less", rope=c(-.05,.05))`

### 42. `apm_bayes_diagnostics()` - release 0.4.0

**Source:** `R/bayes-diagnostics.R`\
**Signature:**

``` r

apm_bayes_diagnostics(model, checks = c("convergence", "ess", "mcse", "ppc"), plot = TRUE)
```

**Purpose:** Standardize convergence and posterior predictive
diagnostics across Bayesian backends.

**Arguments:** Bayesian fit; checks; plot flag.

**Returns:** `apm_bayes_diagnostics` with backend-appropriate
R-hat/ESS/MCSE or quadrature diagnostics, PPC summaries, warnings, and
plots.

**Backend:** `posterior`, `bayesplot`, RoBMA/JAGS diagnostics, bayesmeta
analytic diagnostics.

**Validation contract:** Never reports R-hat for backends without MCMC;
flags divergent/poor chains; interpretation blocked when severe
convergence failures occur.

**Unit-test file:** `tests/testthat/test-bayes-diagnostics.R`

**Numerical-test contract:** Diagnostic extraction compared to
backend/native posterior summaries; deliberate bad-chain fixture must
trigger failure.

**Three required agronomic examples:**

1.  `apm_bayes_diagnostics(bayes_yield)`
2.  `apm_bayes_diagnostics(bayes_maize, checks=c("convergence","ess","mcse"))`
3.  `apm_bayes_diagnostics(bayes_irrig, checks="ppc", plot=TRUE)`

### 43. `apm_bayes_compare()` - release 0.4.0

**Source:** `R/bayes-compare.R`\
**Signature:**

``` r

apm_bayes_compare(..., criterion = c("loo", "waic", "model_probability"), weights = TRUE)
```

**Purpose:** Compare prespecified Bayesian meta-analytic models or
summarize model-averaging evidence without treating Bayes factors as
p-values.

**Arguments:** Bayesian model objects; criterion; weights.

**Returns:** `apm_bayes_comparison` with ELPD/WAIC or posterior model
probabilities and uncertainty.

**Backend:** `loo` where supported; RoBMA model probabilities; native
reconciliation.

**Validation contract:** Models must target comparable outcomes; no
mixing of incompatible likelihoods without explicit warning; convergence
checked first.

**Unit-test file:** `tests/testthat/test-bayes-compare.R`

**Numerical-test contract:** LOO/WAIC/model-probability values compared
to backend output.

**Three required agronomic examples:**

1.  `apm_bayes_compare(bayes_irrig_linear, bayes_irrig_quadratic, criterion="loo")`
2.  `apm_bayes_compare(bayes_nohet, bayes_het, criterion="loo")`
3.  `apm_bayes_compare(robma_yield, criterion="model_probability")`

### 44. `apm_multivariate_plot()` - release 0.4.0

**Source:** `R/plot-multivariate.R`\
**Signature:**

``` r

apm_multivariate_plot(model, type = c("outcome_forest", "correlation", "prediction"), transform = c("auto", "none", "exp", "percent"), interactive = FALSE)
```

**Purpose:** Visualize outcome-specific pooled effects,
correlation/heterogeneity structure, or multivariate predictions.

**Arguments:** Multivariate model; plot type; transform; interactive
flag.

**Returns:** ggplot/plotly object.

**Backend:** Native ggplot2; optional plotly.

**Validation contract:** Type must be supported by model;
transformations applied outcome-wise only when compatible.

**Unit-test file:** `tests/testthat/test-plot-multivariate.R`

**Numerical-test contract:** Plot-data equality to multivariate
summaries/correlation matrices.

**Three required agronomic examples:**

1.  `apm_multivariate_plot(soil_mv, type="outcome_forest", transform="percent")`
2.  `apm_multivariate_plot(soil_mv, type="correlation")`
3.  `apm_multivariate_plot(biochar_mv, type="prediction", interactive=TRUE)`

### 45. `apm_influence()` - release 0.5.0

**Source:** `R/diagnostics-influence.R`\
**Signature:**

``` r

apm_influence(model, cluster = NULL, unit = c("study", "effect"), metrics = c("cook", "dfbetas", "leverage", "tau2_change"), plot_type = c("influence", "baujat", "radial"), plot = TRUE)
```

**Purpose:** Assess influential effects or studies and generate standard
influence, Baujat, or radial diagnostics, without automatic deletion.

**Arguments:** Model; optional cluster; influence unit; metrics;
diagnostic plot type; plot flag.

**Returns:** `apm_influence` with influence measures, ranked
diagnostics, and ggplot.

**Backend:**
[`metafor::influence`](https://wviechtb.github.io/metafor/reference/influence.rma.uni.html),
`baujat`, `radial` where compatible; cluster leave-one-out/native refits
for multilevel models.

**Validation contract:** No automatic removal; cluster-level influence
recommended for multiple effects per study; failed refits retained.

**Unit-test file:** `tests/testthat/test-diagnostics-influence.R`

**Numerical-test contract:** Univariate influence parity to `metafor`;
cluster deletion equals direct refits.

**Three required agronomic examples:**

1.  `apm_influence(apm_fit(agri_effects_benchmark), plot_type="baujat")`
2.  `apm_influence(maize_ml, cluster=maize_n_shared_effects$study_id, unit="study", plot_type="influence")`
3.  `apm_influence(irrig_meta, metrics=c("cook","tau2_change"), plot_type="radial")`

### 46. `apm_leave_one_out()` - release 0.5.0

**Source:** `R/diagnostics-leave-one-out.R`\
**Signature:**

``` r

apm_leave_one_out(model, unit = c("study", "effect"), cluster = NULL, transform = c("auto", "none", "exp", "percent"), parallel = FALSE)
```

**Purpose:** Refit the analysis leaving out one study or effect at a
time and quantify changes in pooled effect, heterogeneity, and PI.

**Arguments:** Model; deletion unit; cluster; transform; parallel flag.

**Returns:** `apm_sensitivity` with omitted unit, estimate, CI, PI,
tau², and change from full model.

**Backend:**
[`metafor::leave1out`](https://wviechtb.github.io/metafor/reference/leave1out.html)
for compatible univariate fits; native refit engine otherwise.

**Validation contract:** Study-level deletion enforced when dependent
effects exist unless user explicitly requests effect-level; no silent
failed refits.

**Unit-test file:** `tests/testthat/test-diagnostics-leave-one-out.R`

**Numerical-test contract:** Every row equals direct model refit after
dropping same study/effect.

**Three required agronomic examples:**

1.  `apm_leave_one_out(apm_fit(agri_effects_benchmark))`
2.  `apm_leave_one_out(maize_ml, unit="study", cluster=maize_n_shared_effects$study_id)`
3.  `apm_leave_one_out(irrig_meta, transform="percent")`

### 47. `apm_gosh()` - release 0.5.0

**Source:** `R/diagnostics-gosh.R`\
**Signature:**

``` r

apm_gosh(model, subsets = 10000, seed = NULL, parallel = FALSE, plot = TRUE, cluster = NULL)
```

**Purpose:** Explore heterogeneity patterns across model subsets using
GOSH-style diagnostics.

**Arguments:** Model; subset count; seed; parallel; plot; optional
cluster-respecting sampling.

**Returns:** `apm_gosh` with subset estimates/heterogeneity, seed,
sampling design, clustering summaries and ggplot.

**Backend:**
[`metafor::gosh`](https://wviechtb.github.io/metafor/reference/gosh.html)
for supported models; clustered subset sampler for study-level
extension.

**Validation contract:** Heavy computation precomputed for vignettes;
cluster dependence respected when requested; subset count/seed recorded.

**Unit-test file:** `tests/testthat/test-diagnostics-gosh.R`

**Numerical-test contract:** Seeded subset results compared to
[`metafor::gosh`](https://wviechtb.github.io/metafor/reference/gosh.html)
where supported.

**Three required agronomic examples:**

1.  `apm_gosh(apm_fit(agri_effects_benchmark), subsets=500, seed=1)`
2.  `apm_gosh(maize_ml, subsets=500, seed=1, cluster=maize_n_shared_effects$study_id)`
3.  `apm_gosh(irrig_meta, subsets=1000, seed=1, plot=FALSE)`

### 48. `apm_bias()` - release 0.5.0

**Source:** `R/publication-bias.R`\
**Signature:**

``` r

apm_bias(model, methods = c("egger", "rank", "trimfill", "selection", "svalue"), favor = c("positive", "negative"), q = 0, selection_ratio = NULL, robust = FALSE, ...)
```

**Purpose:** Run a transparent set of small-study/publication-bias
diagnostics and sensitivity analyses while separating detection from
correction.

**Arguments:** Model; methods; favored direction; target q; assumed
selection ratio; robust sensitivity flag.

**Returns:** `apm_bias` containing method-specific results, assumptions,
applicability flags, and a cross-method summary.

**Backend:**
[`metafor::regtest`](https://wviechtb.github.io/metafor/reference/regtest.html),
`ranktest`, `trimfill`, `selmodel`;
`PublicationBias::pubbias_svalue/pubbias_meta`; optional `metasens` for
Copas/limit meta-analysis adapters.

**Validation contract:** Methods only when assumptions fit data; funnel
asymmetry not labeled publication bias; selection direction explicit;
correction methods not automatically preferred.

**Unit-test file:** `tests/testthat/test-publication-bias.R`

**Numerical-test contract:** Method-level parity to `metafor`,
`PublicationBias`, and optional `metasens`; no cross-method equality
assumed.

**Three required agronomic examples:**

1.  `apm_bias(apm_fit(agri_effects_benchmark), methods=c("egger","rank"))`
2.  `apm_bias(apm_fit(agri_effects_benchmark), methods=c("trimfill","selection"))`
3.  `apm_bias(apm_fit(agri_effects_benchmark), methods="svalue", q=0, favor="positive")`

### 49. `apm_funnel_contour()` - release 0.5.0

**Source:** `R/plot-funnel.R`\
**Signature:**

``` r

apm_funnel_contour(model, levels = c(0.90, 0.95, 0.99), yaxis = "se", label = FALSE, interactive = FALSE)
```

**Purpose:** Convenience interface for contour-enhanced funnel/tunnel
plots.

**Arguments:** Model; significance contours; y-axis; labels;
interactive.

**Returns:** ggplot/plotly object.

**Backend:** Calls `apm_funnel(contour=TRUE)`; no separate statistics.

**Validation contract:** Same checks as `apm_funnel`; contours are
descriptive guides, not publication-bias proof.

**Unit-test file:** `tests/testthat/test-plot-funnel.R`

**Numerical-test contract:** Must be numerically identical to
`apm_funnel(contour=TRUE)`.

**Three required agronomic examples:**

1.  `apm_funnel_contour(apm_fit(agri_effects_benchmark))`
2.  `apm_funnel_contour(apm_fit(irrigation_effects), levels=c(.90,.95))`
3.  `apm_funnel_contour(apm_fit(bioinoculant_effects), interactive=TRUE)`

### 50. `apm_orchard()` - release 0.5.0

**Source:** `R/plot-orchard.R`\
**Signature:**

``` r

apm_orchard(model, moderator = NULL, transform = c("auto", "none", "exp", "percent"), raw_effects = TRUE, prediction = TRUE, interactive = FALSE)
```

**Purpose:** Create orchard-style plots emphasizing pooled/marginal
effects, observed effects, CIs and PIs.

**Arguments:** Model; moderator; transform; raw-effect display; PI;
interactive.

**Returns:** ggplot/plotly object.

**Backend:** Native ggplot implementation; optional parity/reference
checks with `orchaRd` where compatible.

**Validation contract:** Uses existing model estimates; moderator plot
requires fitted moderator; CI and PI visually distinct.

**Unit-test file:** `tests/testthat/test-plot-orchard.R`

**Numerical-test contract:** Plot-data equality to model/marginal
summaries; optional parity of compatible values with `orchaRd`.

**Three required agronomic examples:**

1.  `apm_orchard(apm_fit(agri_effects_benchmark), transform="percent")`
2.  `apm_orchard(apm_metareg(bioinoculant_effects,~crop), moderator="crop", transform="percent")`
3.  `apm_orchard(apm_metareg(irrigation_effects,~climate_zone), moderator="climate_zone", interactive=TRUE)`

### 51. `apm_moderator_screen()` - release 0.5.0

**Source:** `R/moderator-screen.R`\
**Signature:**

``` r

apm_moderator_screen(effects, moderators, method = c("metaforest"), cluster = NULL, seed = NULL, tune = TRUE, cv = 10, importance = c("permutation", "minimal_depth"), ...)
```

**Purpose:** Exploratory screening of many potential moderators using
weighted meta-analytic random forests; never substitutes confirmatory
meta-regression.

**Arguments:** Effects; moderator formula/list; method; cluster; seed;
tuning/CV; importance metric.

**Returns:** `apm_moderator_screen` with tuned model, out-of-bag/CV
error, variable importance, partial dependence data, and explicit
exploratory label.

**Backend:** Optional `metaforest`.

**Validation contract:** Requires sufficient studies relative to
moderator count; leakage avoided by cluster-aware resampling; seed
recorded; no inferential p-values generated.

**Unit-test file:** `tests/testthat/test-moderator-screen.R`

**Numerical-test contract:** Seeded MetaForest parity for
tuning/importance; cluster-resampling integrity tests.

**Three required agronomic examples:**

1.  `apm_moderator_screen(irrigation_effects, moderators=~rainfall+mean_temp+soil_clay+altitude, seed=1)`
2.  `apm_moderator_screen(bioinoculant_effects, moderators=~crop+soil_pH+rainfall+inoculant, seed=1)`
3.  `apm_moderator_screen(maize_n_shared_effects, moderators=~N_rate+soil_organic_matter+clay+rainfall, cluster=study_id, seed=1)`

### 52. `apm_report()` - release 0.5.0

**Source:** `R/report.R`\
**Signature:**

``` r

apm_report(x, file, format = c("html", "docx", "pdf"), sections = c("data", "effects", "model", "heterogeneity", "prediction", "diagnostics", "sensitivity", "plots"), title = NULL, bibliography = NULL, seed = NULL)
```

**Purpose:** Generate a reproducible analysis report from package
objects with methods, tables, figures, interpretation and provenance.

**Arguments:** Object/workflow; output file/format; sections; title;
bibliography; seed.

**Returns:** `apm_report` with output path, source template path,
hashes, session metadata, and rendered section inventory.

**Backend:** Quarto/rmarkdown optional; tables/plots from package
objects.

**Validation contract:** Report never recomputes with different
defaults; heavy Bayesian/bootstrap objects loaded from saved results;
source and session info archived.

**Unit-test file:** `tests/testthat/test-report.R`

**Numerical-test contract:** Rendered report must contain hashes/session
info and values matching source objects; no recomputation drift.

**Three required agronomic examples:**

1.  `apm_report(apm_fit(agri_effects_benchmark), "yield_meta.html", format="html")`
2.  `apm_report(maize_workflow, "maize_meta.docx", format="docx")`
3.  `apm_report(bayes_workflow, "bioinoculant_meta.pdf", format="pdf", sections=c("data","model","diagnostics","sensitivity","plots"))`

### 53. `apm_explain()` - release 0.5.0

**Source:** `R/explain.R`\
**Signature:**

``` r

apm_explain(x, audience = c("scientific", "teaching", "extension"), transform = c("auto", "none", "exp", "percent"), include_assumptions = TRUE, include_cautions = TRUE)
```

**Purpose:** Generate concise, rule-based interpretations of estimates,
heterogeneity, PI, dependence and diagnostics without unsupported causal
or significance claims.

**Arguments:** Package object; audience; transform; assumption/caution
flags.

**Returns:** Character vector of interpretation paragraphs plus
machine-readable interpretation tags.

**Backend:** Native rule engine; no generative model required.

**Validation contract:** Statements templated from actual quantities; no
‘no effect’ conclusion from nonsignificance; PI and dependence cautions
inserted when applicable.

**Unit-test file:** `tests/testthat/test-explain.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  `apm_explain(apm_fit(agri_effects_benchmark), audience="scientific", transform="percent")`
2.  `apm_explain(apm_heterogeneity(apm_fit(agri_effects_benchmark)), audience="teaching")`
3.  `apm_explain(apm_compare_inference(irrigation_fit,robust=irrigation_cr2,wild=irrigation_wild), audience="scientific")`

### 54. `apm_export()` - release 0.5.0

**Source:** `R/export.R`\
**Signature:**

``` r

apm_export(x, path, format = c("csv", "xlsx", "rds", "json", "png", "svg", "tiff", "html"), dpi = 600, width = NULL, height = NULL, overwrite = FALSE)
```

**Purpose:** Export tables, model summaries, reproducible objects, and
publication figures with appropriate scientific formats.

**Arguments:** Object; path; format; image resolution/size; overwrite.

**Returns:** Invisible normalized path plus checksum/provenance
attributes.

**Backend:** Base writers; optional `openxlsx2`, `jsonlite`, `ggplot2`
graphics devices.

**Validation contract:** Vector formats used where requested; 600 dpi
default for raster scientific figures; no overwrite unless explicit;
object type must support format.

**Unit-test file:** `tests/testthat/test-export.R`

**Numerical-test contract:** Round-trip read for CSV/XLSX/RDS; raster
dimensions/DPI and vector file creation checks.

**Three required agronomic examples:**

1.  `apm_export(apm_table(apm_fit(agri_effects_benchmark)), "model.xlsx", format="xlsx")`
2.  `apm_export(apm_forest(apm_fit(agri_effects_benchmark)), "forest.tiff", format="tiff", dpi=600)`
3.  `apm_export(maize_ml, "maize_model.rds", format="rds")`

### 55. `apm_workflow()` - release 1.0.0

**Source:** `R/workflow.R`\
**Signature:**

``` r

apm_workflow(data, plan = NULL, measure = "lnRR", dependence = c("auto", "independent", "shared_control", "paired"), model = c("auto", "random", "multilevel"), moderators = NULL, robust = FALSE, bayes = FALSE, threshold = NULL, seed = NULL, ...)
```

**Purpose:** Run an auditable end-to-end workflow while retaining every
intermediate object and never hiding model-routing decisions.

**Arguments:** Data/plan; effect measure; dependence/model routing;
moderators; robust/Bayesian options; practical threshold; seed.

**Returns:** `apm_workflow` containing audit, plan, effects, V, fit,
diagnostics, sensitivities, tables, plots metadata, and routing log.

**Backend:** Orchestrates package functions; does not add new
estimators.

**Validation contract:** `auto` decisions recorded and reproducible;
user can override every major choice; conflicts stop with actionable
messages.

**Unit-test file:** `tests/testthat/test-workflow.R`

**Numerical-test contract:** End-to-end result components equal calling
each constituent function manually with logged routing choices.

**Three required agronomic examples:**

1.  `apm_workflow(maize_n_shared, measure="lnRR", dependence="shared_control", model="multilevel", robust=TRUE)`
2.  `apm_workflow(irrigation_climate, measure="lnRR", moderators=~rainfall+mean_temp, threshold=5)`
3.  `apm_workflow(wheat_paired_blocks, measure="lnRR", dependence="paired", model="random")`

### 56. `apm_capabilities()` - release 1.0.0

**Source:** `R/capabilities.R`\
**Signature:**

``` r

apm_capabilities(feature = NULL, installed = TRUE, detail = c("summary", "full"))
```

**Purpose:** Report supported methods, effect sizes, optional backends,
installed capabilities, and validation tier.

**Arguments:** Optional feature filter; whether to check installation;
detail level.

**Returns:** Data frame with feature, package backend, required version
policy, installed status, and validation status.

**Backend:** Native registry +
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).

**Validation contract:** Never claims optional capability available when
dependency/system requirement is absent; JAGS/CmdStan checked
separately.

**Unit-test file:** `tests/testthat/test-capabilities.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  [`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md)
2.  `apm_capabilities("bayesian", detail="full")`
3.  `apm_capabilities("dose-response", installed=TRUE)`

### 57. `apm_doctor()` - release 1.0.0

**Source:** `R/doctor.R`\
**Signature:**

``` r

apm_doctor(full = FALSE, check_backends = TRUE, check_render = FALSE, check_examples = FALSE)
```

**Purpose:** Diagnose installation, optional engines, system
requirements, package data integrity, and reproducibility
infrastructure.

**Arguments:** Depth; backend checks; rendering stack; example smoke
tests.

**Returns:** `apm_doctor` with PASS/WARN/FAIL/NOT RUN table and
remediation commands.

**Backend:** Native environment checks; optional backend smoke tests.

**Validation contract:** Static checks never reported as runtime
validation; failures categorized core vs optional; no environment
mutation.

**Unit-test file:** `tests/testthat/test-doctor.R`

**Numerical-test contract:** Deterministic invariants,
round-trip/dispatch checks, and exact comparison to the underlying
registered backend where the function exposes backend-derived
quantities.

**Three required agronomic examples:**

1.  [`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
2.  `apm_doctor(full=TRUE, check_backends=TRUE)`
3.  `apm_doctor(full=TRUE, check_render=TRUE, check_examples=TRUE)`

## 10. Unit-test architecture

Use `testthat` edition 3. Every public function receives tests in five
categories where applicable:

| Test category | Examples |
|----|----|
| Input contract | classes, lengths, required columns, missing values, unsupported levels, invalid units |
| Scientific guardrails | invalid estimands, paired correlation bounds, shared-control conflicts, impossible lnRR/CVR means, sparse moderator support |
| Object contract | class, required fields, data hash, provenance, no silent row loss |
| Edge cases | k=1/k=2, tau²=0, extreme precision, duplicated IDs, singular moderator matrices, near-non-PD V |
| Optional backend behavior | clean informative skip/error if Suggested backend or system requirement is absent |

### 10.1 Dedicated test files

- `tests/testthat/test-bayes-compare.R`:
  [`apm_bayes_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_compare.md)
- `tests/testthat/test-bayes-diagnostics.R`:
  [`apm_bayes_diagnostics()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_diagnostics.md)
- `tests/testthat/test-bayes-fit.R`:
  [`apm_bayes()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes.md)
- `tests/testthat/test-bayes-predict.R`:
  [`apm_bayes_predict()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_predict.md)
- `tests/testthat/test-bayes-prior-check.R`:
  [`apm_prior_check()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior_check.md)
- `tests/testthat/test-bayes-prior.R`:
  [`apm_prior()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prior.md)
- `tests/testthat/test-bayes-threshold.R`:
  [`apm_bayes_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bayes_threshold.md)
- `tests/testthat/test-capabilities.R`:
  [`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md)
- `tests/testthat/test-compare-inference.R`:
  [`apm_compare_inference()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_compare_inference.md)
- `tests/testthat/test-curve-features.R`:
  [`apm_curve_features()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_curve_features.md)
- `tests/testthat/test-data-audit.R`:
  [`apm_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_audit.md)
- `tests/testthat/test-data-read.R`:
  [`apm_read()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_read.md)
- `tests/testthat/test-data-validate.R`:
  [`apm_validate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_validate.md)
- `tests/testthat/test-dependence-audit.R`:
  [`apm_dependence_audit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dependence_audit.md)
- `tests/testthat/test-dependence-paired.R`:
  [`apm_pair_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_pair_vcov.md)
- `tests/testthat/test-dependence-shared-control.R`:
  [`apm_shared_control()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_shared_control.md)
- `tests/testthat/test-dependence-vcov.R`:
  [`apm_vcov()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_vcov.md)
- `tests/testthat/test-diagnostics-gosh.R`:
  [`apm_gosh()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_gosh.md)
- `tests/testthat/test-diagnostics-influence.R`:
  [`apm_influence()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_influence.md)
- `tests/testthat/test-diagnostics-leave-one-out.R`:
  [`apm_leave_one_out()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_leave_one_out.md)
- `tests/testthat/test-doctor.R`:
  [`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
- `tests/testthat/test-dose-response.R`:
  [`apm_dose_response()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_response.md)
- `tests/testthat/test-effect-size.R`:
  [`apm_effect_size()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_effect_size.md)
- `tests/testthat/test-explain.R`:
  [`apm_explain()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_explain.md)
- `tests/testthat/test-export.R`:
  [`apm_export()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_export.md)
- `tests/testthat/test-fit-core.R`:
  [`apm_fit()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_fit.md)
- `tests/testthat/test-fit-multilevel.R`:
  [`apm_multilevel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multilevel.md)
- `tests/testthat/test-heterogeneity.R`:
  [`apm_heterogeneity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_heterogeneity.md)
- `tests/testthat/test-interaction.R`:
  [`apm_interaction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_interaction.md)
- `tests/testthat/test-marginal-effects.R`:
  [`apm_marginal_effects()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_marginal_effects.md)
- `tests/testthat/test-metareg-curve.R`:
  [`apm_metareg_curve()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg_curve.md)
- `tests/testthat/test-metareg.R`:
  [`apm_metareg()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg.md)
- `tests/testthat/test-model-compare.R`:
  [`apm_model_compare()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_model_compare.md)
- `tests/testthat/test-moderator-screen.R`:
  [`apm_moderator_screen()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_moderator_screen.md)
- `tests/testthat/test-multivariate.R`:
  [`apm_multivariate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate.md)
- `tests/testthat/test-plan.R`:
  [`apm_plan()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_plan.md)
- `tests/testthat/test-plot-bubble.R`:
  [`apm_bubble()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bubble.md)
- `tests/testthat/test-plot-dose.R`:
  [`apm_dose_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_dose_plot.md)
- `tests/testthat/test-plot-forest.R`:
  [`apm_forest()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_forest.md)
- `tests/testthat/test-plot-funnel.R`:
  [`apm_funnel()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel.md),
  [`apm_funnel_contour()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel_contour.md)
- `tests/testthat/test-plot-multivariate.R`:
  [`apm_multivariate_plot()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate_plot.md)
- `tests/testthat/test-plot-orchard.R`:
  [`apm_orchard()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_orchard.md)
- `tests/testthat/test-predict-context.R`:
  [`apm_predict_context()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_predict_context.md)
- `tests/testthat/test-prediction.R`:
  [`apm_prediction()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_prediction.md)
- `tests/testthat/test-publication-bias.R`:
  [`apm_bias()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_bias.md)
- `tests/testthat/test-report.R`:
  [`apm_report()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_report.md)
- `tests/testthat/test-robust.R`:
  [`apm_robust()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_robust.md)
- `tests/testthat/test-sensitivity-mvcor.R`:
  [`apm_mvcor_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_mvcor_sensitivity.md)
- `tests/testthat/test-sensitivity-rho.R`:
  [`apm_rho_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_rho_sensitivity.md)
- `tests/testthat/test-subgroup.R`:
  [`apm_subgroup()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_subgroup.md)
- `tests/testthat/test-table.R`:
  [`apm_table()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_table.md)
- `tests/testthat/test-threshold.R`:
  [`apm_threshold()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_threshold.md)
- `tests/testthat/test-uncertainty.R`:
  [`apm_recover_uncertainty()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_recover_uncertainty.md)
- `tests/testthat/test-variance-components.R`:
  [`apm_variance_components()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_variance_components.md)
- `tests/testthat/test-wild-bootstrap.R`:
  [`apm_wild_bootstrap()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_wild_bootstrap.md)
- `tests/testthat/test-workflow.R`:
  [`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md)

## 11. Numerical and statistical validation

### 11.1 Validation tiers

- **Tier 1: algebraic.** Effect-size formulas, transforms, uncertainty
  recovery, covariance identities, contrast matrices. Expected
  tolerance: 1e-10 to 1e-12.
- **Tier 2: deterministic backend parity.** metafor, clubSandwich,
  mixmeta, dosresmeta. Coefficients/SE/variance components/logLik
  normally within 1e-8 relative/absolute tolerance unless optimizer
  equivalence requires a documented wider tolerance.
- **Tier 3: stochastic backend parity.** wildmeta, Bayesian MCMC,
  MetaForest. Equality judged using fixed seeds, Monte Carlo SE,
  posterior interval overlap and explicitly defined tolerances, not
  bitwise identity.
- **Tier 4: simulation calibration.** Bias, RMSE, CI/CrI coverage, PI
  coverage, Type I error, power, heterogeneity recovery, covariance
  misspecification and small-k behavior.
- **Tier 5: end-to-end release.** Examples, vignettes, reports, plots,
  build and `R CMD check --as-cran` on the exact frozen source tarball.

### 11.2 Golden backend matrix

| Scientific component | Primary golden reference | Secondary cross-check |
|----|----|----|
| Effect sizes | [`metafor::escalc`](https://wviechtb.github.io/metafor/reference/escalc.html) | `hand formulas` |
| Sampling covariance | [`metafor::vcalc`](https://wviechtb.github.io/metafor/reference/vcalc.html) | `hand shared-control/paired fixtures` |
| Random/mixed models | `metafor::rma.uni/rma.mv` | `meta where compatible` |
| CR2 inference | `clubSandwich` | `metafor::robust(clubSandwich=TRUE)` |
| Wild bootstrap | `wildmeta` | `seeded frozen expected results` |
| Dose-response | `dosresmeta` | `mixmeta/metafor overlapping formulations` |
| Multivariate | `mixmeta` | [`metafor::rma.mv`](https://wviechtb.github.io/metafor/reference/rma.mv.html) |
| Bayesian normal-normal | `bayesmeta` | `analytic/frozen reference summaries` |
| Bayesian model averaging/bias | `RoBMA` | `frozen posterior/model-probability fixtures` |
| Prediction intervals | `metafor` | `pimeta for supported alternative methods` |
| Publication-bias sensitivity | `PublicationBias/metafor` | `metasens where method overlaps` |
| MetaForest | `metaforest` | `seeded reproducibility and cluster-CV integrity` |

### 11.3 Simulation battery

Freeze simulation scenarios in `inst/validation/simulations/` and
developer scripts in `tools/simulations/`. Minimum scenarios:

- Independent lnRR with k = 5, 10, 30, 100; tau = 0, 0.1, 0.3.
- Shared-control designs with 2, 3, 5 treatments per control and
  balanced/unbalanced n.
- Paired designs with true r = 0, 0.3, 0.6, 0.9 plus deliberate rho
  misspecification.
- VR/CVR scenarios with equal means, changing means, changing variance,
  and simultaneous mean/variance change.
- Meta-regression with null, linear, quadratic and nonlinear moderator
  effects, plus sparse moderator support.
- Multilevel study/experiment/effect structures with known variance
  components.
- Multivariate two-, three-, and five-outcome data with known
  within-study and between-study correlations.
- Small-cluster robust scenarios assessing CR2 and wild-bootstrap Type I
  error.
- Dose-response linear, quadratic and spline truth with shared
  reference.
- Publication-bias sensitivity fixtures with known selection mechanisms,
  used only to assess method behavior under its own assumptions.
- Bayesian prior-sensitivity scenarios with weak and informative priors,
  evaluating posterior calibration and predictive coverage.

Each simulation archive must store truth, seed, number of replications,
package versions, failure count, Monte Carlo SE, bias, RMSE, coverage
and runtime metadata.

## 12. Documentation and example-coverage standard

The roxygen source is authoritative. Each of the 57 exports must contain
three labeled, pedagogically distinct examples:

1.  normal/basic agronomic use;
2.  challenging design or uncertainty/dependence case;
3.  integrated downstream use with interpretation, plotting or
    sensitivity.

Optional/heavy examples are protected with
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html) and
appropriate `\dontrun{}` or precomputation, but the scientific code
remains visible.

A machine-readable file `inst/metadata/example_coverage.csv` must
contain one row per exported function and columns `function`,
`example1`, `example2`, `example3`, `manual_calls`, `vignette_calls`,
`status`. Release gate: 57/57 PASS.

## 13. Vignette architecture

| Vignette | Unique responsibility |
|----|----|
| `v00-foundations-to-advanced-tutorial.Rmd` | Panoramic tutorial from data structure and estimand to advanced robust/Bayesian/multivariate workflows. |
| `v01-data-effect-sizes-uncertainty.Rmd` | Input schemas, uncertainty recovery, lnRR/MD/SMD/RR/OR/RD and provenance. |
| `v02-variability-vr-cvr.Rmd` | VR/CVR, simultaneous mean and variability synthesis, agricultural stability interpretation. |
| `v03-shared-controls-paired-dependence.Rmd` | Shared controls, paired designs, V matrices and rho sensitivity. |
| `v04-random-multilevel-robust.Rmd` | Random/mixed models, hierarchy, variance components, CR2 and wild bootstrap. |
| `v05-meta-regression-quantitative-moderators.Rmd` | Categorical moderators, interactions, curves, contextual prediction and support. |
| `v06-dose-response.Rmd` | True multiple-dose meta-analysis, shared reference, nonlinear dose curves. |
| `v07-multivariate-meta-analysis.Rmd` | Multiple agronomic outcomes and unknown-correlation sensitivity. |
| `v08-bayesian-meta-analysis.Rmd` | Priors, bayesmeta, RoBMA, multilevel Bayes, posterior prediction and thresholds. |
| `v09-bias-influence-sensitivity.Rmd` | Influence, leave-one-out, GOSH, funnel asymmetry, selection models and S-values. |
| `v10-figures-tables-interactive.Rmd` | Forest, funnel/tunnel, bubble, orchard, multivariate plots, plotly, gt/flextable. |
| `v11-reporting-reproducibility.Rmd` | Reports, exports, provenance, doctor, exact workflow recreation. |
| `v12-agronomic-case-studies.Rmd` | Integrated maize N, irrigation, inoculant, soil-management and pest examples. |

The v00 tutorial is the pedagogical anchor. Specialized vignettes deepen
topics without repeating full theory. Bayesian, GOSH, wild-bootstrap,
MetaForest and large simulation workloads follow the heavy-vignette
precomputation rule.

## 14. Plotting contract

All scientific plot functions return a ggplot object by default and
accept `interactive=TRUE` where meaningful. Interactive plots are
optional and use plotly. The underlying plot data are attached or
retrievable so figures remain auditable.

Required visual families by 1.0.0:

- Forest/estimation plots with side metadata, study weights, CI and PI.
- Funnel and contour-enhanced funnel/tunnel plots.
- Bubble plots for quantitative moderators.
- Dose-response curves with observed effects, CI, PI and dose support.
- Orchard-style subgroup/moderator summaries.
- Influence, Baujat and radial diagnostics.
- GOSH subset plots.
- Rho/correlation sensitivity through
  `autoplot(apm_sensitivity, type='rho')`.
- Multivariate outcome forest, correlation and prediction views.
- Bayesian prior, posterior, predictive and convergence views through
  class dispatch.

Continuous outcomes should show observed effect sizes together with
fitted estimates whenever practical. Raster publication output defaults
to 600 dpi; SVG/PDF-vector workflows remain available through
export/reporting.

## 15. Validation of units and agronomic semantics

- Outcome units are metadata and cannot be mixed within MD models
  without explicit conversion.
- lnRR/VR/CVR are dimensionless but raw means/SDs must use the same unit
  within each contrast.
- Dose variables carry unit metadata; dose-response analysis stops on
  unresolved kg ha-1 vs g pot-1 type conflicts.
- Zero or negative means make lnRR/CVR undefined unless a scientifically
  justified different estimand is chosen. The package does not add
  arbitrary constants.
- Treatment direction is fixed as treatment minus control for difference
  metrics and treatment/control for ratio metrics.
- Effect direction metadata state whether positive values mean
  agronomically beneficial or adverse only when the user supplies
  outcome orientation.
- Multiple rows from the same article are not assumed to be independent
  studies. Study, experiment and effect identifiers are separate roles.

## 16. Error, warning and message policy

| Severity | Meaning | Example |
|----|----|----|
| error | Analysis cannot be scientifically defined | lnRR with nonpositive mean; malformed V; unknown factor level |
| warning | Analysis can run but interpretation needs caution | very small k; low CR2 df; extrapolated moderator prediction |
| informative issue | User should inspect but computation may proceed | shared controls detected; uncertainty recovered from CV |
| record-only provenance | No console noise unless requested | backend version, transformation, seed, row exclusion reason |

## 17. Reproducibility metadata

Every fitted object must retain at minimum: package version, backend and
backend version, R version, call, data hash, effect-size registry entry,
excluded rows with reasons, V/correlation assumptions, seed where
relevant, model formula/random structure, inference method, transform,
threshold, and system dependency information for JAGS/Stan when used.

## 18. Version-specific acceptance gates

### 0.1.0

All 14 exports implemented and documented with three examples each.

Independent and paired lnRR/VR/CVR numerical parity to metafor.

Core REML/random-effects, CI and PI golden tests pass.

Forest/funnel/table plot-data tests pass.

### 0.2.0

Shared-control detection and covariance fixtures pass.

rma.mv multilevel golden tests pass.

CR2 parity against clubSandwich 0.7.0 passes.

Seeded wildmeta smoke/golden tests pass when installed.

### 0.3.0

Linear/polynomial/spline moderator tests pass.

Dose-response parity to dosresmeta 2.2.0 passes.

Context prediction and interaction contrast algebra passes.

No model-selection function violates hierarchy or selects by p-value
alone.

### 0.4.0

Multivariate parity to mixmeta/metafor passes.

Unknown-correlation sensitivity reproduces direct fits.

bayesmeta deterministic reference analyses pass.

RoBMA/brms optional MCMC validation uses frozen seeds and convergence
gates.

### 0.5.0

Influence/leave-one-out/GOSH diagnostics validated.

Bias/sensitivity adapters reproduce upstream package results.

All plot-data, interactive smoke, report and export tests pass.

MetaForest remains explicitly exploratory and cluster-aware.

### 1.0.0

57/57 exported functions have three manual examples and three vignette
calls.

All registered S3 methods have documented dispatch coverage.

All unit tests pass in clean library.

All optional-backend full-feature tests pass on a validation machine
with dependencies installed.

All non-heavy vignette code executes; heavy vignettes consume frozen
audited objects.

`R CMD build` succeeds, final tarball is frozen, and
`R CMD check --as-cran` is run on that exact tarball.

README, NEWS, ARCHITECTURE, state-of-art and local validation documents
match the final API.

SHA-256 hashes and session/package-version logs are archived.

## 19. Recommended CI and release workflow

Developer CI should run at least R release on Linux and Windows for
routine pushes, with R-devel and macOS in release workflows.
Optional-engine jobs are separated so JAGS/Stan failures are not
confused with core package failures.

Final release sequence:

1.  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    or
    [`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html).
2.  `Rscript tools/check_example_coverage.R`.
3.  `Rscript tools/check_generated_rd_examples.R`.
4.  [`testthat::test_dir()`](https://testthat.r-lib.org/reference/test_dir.html)
    or
    [`devtools::test()`](https://devtools.r-lib.org/reference/test.html).
5.  Execute package examples intended to run.
6.  Render all normal vignettes and validate precomputed heavy-vignette
    metadata/hashes.
7.  `R CMD build .`.
8.  Freeze the resulting `agriPairMetaFlow_<version>.tar.gz`.
9.  `R CMD check --as-cran agriPairMetaFlow_<version>.tar.gz` on that
    exact artifact.
10. Read the complete `00check.log`, fix package-caused
    ERROR/WARNING/NOTE, rebuild and repeat.
11. Archive tarball, source ZIP, check log, SHA-256, validation
    instructions and backend/session metadata.

## 20. Implementation order inside each release

Within each version, implementation should follow this sequence:
registry and data contract, core computation, object class, S3 methods,
unit tests, numerical golden tests, examples, specialized vignette
block, static/interactive figure layer, final release gate. Architecture
defects are corrected before adding the next release block.

## 21. Final 1.0.0 package identity

`agriPairMetaFlow` should not be a generic wrapper around every
meta-analysis method. Its stable identity is treatment-versus-control
synthesis for agricultural experiments, with design-aware dependence,
agronomically interpretable effect scales, quantitative
moderators/dose-response, multivariate outcomes, robust and Bayesian
sensitivity, and publication-quality communication.

Network meta-analysis, diagnostic-accuracy meta-analysis, transcriptomic
meta-analysis, IPD meta-analysis and systematic-review screening remain
outside the core scope.

## 22. Implementation deliverables produced from this specification

- `DESCRIPTION` and dependency policy.
- Complete `R/` skeleton with the 57 exported signatures and internal
  registries.
- 27 S3/result class constructors/validators.
- 11 frozen agronomic teaching/validation datasets plus `data-raw/`
  generators.
- `tests/testthat/` unit suite and numerical golden fixtures.
- Simulation scripts and frozen calibration summaries.
- 13 long English vignettes including the foundations-to-advanced
  anchor.
- `ARCHITECTURE.md`, `STATE_OF_THE_ART.md`, `VALIDATION.md`,
  `LOCAL_VALIDATION.md`, README and NEWS.
- Static and interactive plot layer, table layer, reporting/export
  layer.
- Final release artifacts only after actual runtime validation.
