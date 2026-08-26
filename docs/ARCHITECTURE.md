# agriPairMetaFlow architecture through 1.0.0

## Scientific flow

``` text
raw agronomic summaries
        |
        v
validation -> audit -> estimand/effect size
        |
        v
sampling dependence (shared control / paired / V)
        |
        +------------------------+---------------------------+
        |                        |                           |
        v                        v                           v
frequentist core          moderator / dose            multivariate
multilevel / CR2          meta-regression              outcomes + V
        |                        |                           |
        |                        |                           +--> rho sensitivity
        |                        |                           +--> metafor / mixmeta
        |                        |
        +------------------------+---------------------------+
                                 |
                                 v
                         Bayesian synthesis
                          prior -> prior check
                          bayesmeta / RoBMA / brms
                          posterior -> prediction
                          thresholds -> diagnostics
                                 |
                                 v
                     diagnostics / bias sensitivity
                                 |
                                 v
                 tables / advanced figures / reports / export
```

## Public analytical API by release

### 0.1.0: foundations, 14 functions

`apm_read`, `apm_validate`, `apm_audit`, `apm_plan`,
`apm_recover_uncertainty`, `apm_effect_size`, `apm_fit`, `apm_subgroup`,
`apm_heterogeneity`, `apm_prediction`, `apm_threshold`, `apm_forest`,
`apm_funnel`, `apm_table`.

### 0.2.0: dependence and robust inference, 10 functions

`apm_shared_control`, `apm_vcov`, `apm_pair_vcov`,
`apm_dependence_audit`, `apm_rho_sensitivity`, `apm_multilevel`,
`apm_variance_components`, `apm_robust`, `apm_wild_bootstrap`,
`apm_compare_inference`.

### 0.3.0: moderators and dose-response, 10 functions

`apm_metareg`, `apm_marginal_effects`, `apm_interaction`,
`apm_metareg_curve`, `apm_model_compare`, `apm_predict_context`,
`apm_curve_features`, `apm_dose_response`, `apm_dose_plot`,
`apm_bubble`.

### 0.4.0: multivariate and Bayesian, 10 functions

`apm_multivariate`, `apm_mvcor_sensitivity`, `apm_prior`,
`apm_prior_check`, `apm_bayes`, `apm_bayes_predict`,
`apm_bayes_threshold`, `apm_bayes_diagnostics`, `apm_bayes_compare`,
`apm_multivariate_plot`.

### 0.5.0: diagnostics, bias sensitivity, and communication, 10 functions

`apm_influence`, `apm_leave_one_out`, `apm_gosh`, `apm_bias`,
`apm_funnel_contour`, `apm_orchard`, `apm_moderator_screen`,
`apm_report`, `apm_explain`, `apm_export`.

Total analytical exports through 0.5.0: **54**.

### 1.0.0: integration and release readiness, 3 functions

[`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md),
[`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md),
and
[`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
complete the stable API at 57 analytical functions. They add no new
estimator. Their responsibility is orchestration, capability discovery,
auditability, and environment diagnosis.

## 1.0 integration contract

[`apm_workflow()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_workflow.md)
follows five constraints:

1.  every automatic routing choice is recorded in `routing_log`;
2.  pairing is never inferred from treatment-control labeling alone;
3.  shared controls lead to an explicit sampling covariance
    representation before fitting;
4.  user overrides are preserved and identified as user decisions;
5.  the returned object retains all intermediate analytical objects
    needed to reproduce the same fit manually.

[`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md)
is a static registry plus optional installation inspection. It does not
install dependencies. Each row declares feature, backend,
minimum-version policy, core/optional status, and validation tier.

[`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
is non-mutating. It reports `PASS`, `WARN`, `FAIL`, or `NOT RUN`,
separates core failures from optional unavailable capabilities, and
never presents a static/environment check as numerical validation.

## New 0.4.0 classes

`apm_multivariate` inherits from `apm_model` and retains the backend
fit, sampling covariance matrix, outcome estimates, between-outcome
covariance/correlation, source data hash, and model settings.
`apm_mvcor_sensitivity` inherits from `apm_sensitivity` and preserves
successful and failed rho scenarios.

Bayesian classes are `apm_prior`, `apm_prior_check`, `apm_bayes`,
`apm_bayes_prediction`, `apm_bayes_threshold`, `apm_bayes_diagnostics`,
and `apm_bayes_comparison`. Backend objects are retained for audit and
advanced inspection.

## Backend contract

`metafor` is an Import and remains the core engine. `mixmeta`,
`bayesmeta`, `BayesTools`, `RoBMA`, `brms`, `cmdstanr`, `posterior`,
`bayesplot`, and `loo` remain in `Suggests`.

The public API is estimand-oriented rather than backend-oriented.
Backend routing is explicit and must not alter the requested inferential
target. A capability that cannot be represented faithfully by the
selected backend raises an error.

## Multivariate covariance contract

[`apm_multivariate()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_multivariate.md)
requires one effect per study-outcome combination. `V` is authoritative
when supplied and must be square, symmetric, positive semidefinite
within tolerance, and aligned with the rows of the analysis data. When
`V=NULL`, a diagonal matrix is created and a warning records the zero
within-study outcome-correlation assumption.

[`apm_mvcor_sensitivity()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_mvcor_sensitivity.md)
builds block covariance matrices as

``` text
S_ij = rho * sqrt(vi_i * vi_j), i != j
S_ii = vi_i
```

within each independent study, checks positive semidefiniteness, and
refits the identical model across the declared rho grid.

## Bayesian target contract

A prior declaration and a prior check are separate from fitting.
`apm_bayes_predict(predictive=FALSE)` targets a posterior mean effect.
`predictive=TRUE` targets a new true study effect when the backend can
represent that quantity. It does not intentionally add future
measurement/sampling error.

Bayesian threshold probabilities are descriptive quantities relative to
a user-defined agronomic threshold. They are not p-values, and the
package does not create universal posterior-probability cutoffs.

## Validation boundary

Runtime validation is local by project decision. This construction
environment performs static source, API, documentation, data, and hash
audits only. Official release artifacts must later be regenerated and
validated with the local R toolchain on the exact tarball intended for
release.

## New 0.5.0 classes and contracts

`apm_influence` preserves diagnostic metrics, the unit of deletion, plot
data, backend provenance, and a no-automatic-removal caution. `apm_gosh`
stores subset results, inclusion information where available, seed,
sampling design, and the source-model hash. `apm_bias` stores every
requested method independently together with applicability, failure
status, backend, and a cross-method summary. `apm_moderator_screen`
retains the complete MetaForest backend fit, importance table, tuning
metadata, independent-unit count, and an explicit exploratory flag.
`apm_report` stores rendered-file, source-template, payload, and
checksum provenance.

Influence and leave-one-out diagnostics refit the same model family and
preserve the stored sampling covariance matrix when a full `V` was used.
Study-level deletion is the default scientific unit when `study_id` is
available. Effect-level diagnostics are permitted but are labeled
cautiously for dependence-aware models.

Publication-bias functions are sensitivity analyses. Regression tests,
rank tests, trim-and-fill, selection models, S-values, Copas models, and
limit meta-analysis make different assumptions and are not collapsed
into a single yes/no diagnosis.

The orchard implementation is native `ggplot2`; `orchaRd` is retained as
an optional numerical/visual comparison target. MetaForest is an
optional exploratory backend. Neither visualization nor machine-learning
screening changes the fitted primary meta-analysis.

[`apm_report()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_report.md)
consumes an existing analytical object and does not refit it.
[`apm_export()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_export.md)
preserves complete objects in RDS and numeric table representations in
CSV/XLSX; figure export defaults to 600 dpi for raster formats.

## Stable 1.0 result classes

- `apm_workflow`: integrated analysis plus routing log and all
  intermediate objects.
- `apm_capabilities`: data-frame registry of feature/backend/readiness
  state.
- `apm_doctor`: local environment diagnostic table plus remediation
  guidance and session metadata.

The stable release boundary remains treatment-versus-control synthesis
for agronomic experiments. Network meta-analysis, diagnostic-accuracy
synthesis, transcriptomic meta-analysis, IPD meta-analysis, and
systematic-review screening remain outside the package core.
