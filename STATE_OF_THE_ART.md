# State of the art consolidated for agriPairMetaFlow 1.0.0

Checked during the 0.5.0 construction phase: 2026-08-26.

## Core diagnostic infrastructure

`metafor 5.0-1` remains the primary frequentist backend. Its current API
provides influence diagnostics for `rma.uni` objects, cluster-aware Cook
distances, DFBETAS and hat values for multivariate/multilevel models,
leave-one-out diagnostics, Baujat and radial plots, and GOSH subset
analyses. Version 0.5.0 wraps these capabilities where the fitted model
is compatible and uses explicit cluster-preserving refits when the
scientific unit is a study rather than an individual dependent effect.

Primary documentation checked: current `metafor` reference pages for
`influence.rma.uni`, `leave1out`, `cooks.distance.rma.mv`, `gosh`,
`baujat`, and `radial`.

## Small-study effects and selection sensitivity

The `metafor` publication-bias toolkit includes regression tests for
funnel asymmetry, rank-correlation tests, trim-and-fill, and explicit
selection models. The selection-model documentation emphasizes that
directional one-sided selection and p-value cutpoints must be specified
coherently and that sparse p-value intervals can make step-function
estimates unstable. The wrapper therefore retains method failures and
assumptions rather than forcing every method to return an adjusted
estimate.

`PublicationBias 2.4.0` implements sensitivity analyses based on the
ratio by which affirmative studies would need to be more likely to be
published. Its `pubbias_svalue()` and `pubbias_meta()` functions support
fixed and robust specifications and clustered effects. These methods
answer a sensitivity question about a declared selection mechanism; they
are not generic funnel-asymmetry tests.

`metasens` provides complementary Copas and limit meta-analysis
approaches. They remain optional because they require a different object
ecosystem and make assumptions that should remain visible in the result.

## Funnel and orchard visualization

Contour-enhanced funnel plotting remains a diagnostic visualization, not
a publication-bias test. Version 0.5.0 exposes this explicitly through
[`apm_funnel_contour()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_funnel_contour.md).

`orchaRd 2.2.1`, released on CRAN in July 2026, provides contemporary
orchard plots that combine individual effects, group estimates,
confidence intervals and prediction intervals. `agriPairMetaFlow`
implements its orchard-style plot natively with `ggplot2` so the primary
package does not depend on `orchaRd`; the external package is retained
as an optional comparison/reference implementation.

## MetaForest moderator screening

`metaforest 0.1.5` is the current R-universe/CRAN release checked for
this snapshot. It provides random-forest-based meta-analysis, variable
importance, partial dependence, and tuning through its `ModelInfo_mf()`
interface with `caret`. The package documentation describes MetaForest
as a method for exploring heterogeneity when many moderators may be
relevant. `agriPairMetaFlow` therefore labels its wrapper exploratory
and directs scientific confirmation to prespecified meta-regression
rather than treating importance rankings as inferential tests.

When a study identifier is available, the wrapper passes study
clustering to MetaForest and uses grouped resampling during optional
tuning so dependent effect sizes are not treated as unrelated
cross-validation units.

## Reporting and export

Version 0.5.0 deliberately keeps reporting downstream of analysis.
[`apm_report()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_report.md)
consumes an existing object, records provenance and renders it; it does
not change model defaults or refit the statistical analysis. Heavy GOSH,
bootstrap, Bayesian, or MetaForest computations belong in developer-side
precomputation when used in release vignettes.

Exports distinguish between numeric interchange formats and complete
scientific objects. CSV/XLSX are intended for tables, RDS for full
analytical provenance, SVG for vector figures, raster formats for
publication output, and HTML for interactive graphics.

## Design choices retained from earlier releases

The package continues to separate scientific estimands from backend
syntax. Shared controls are not treated as independent. Prediction
intervals are distinct from confidence intervals. Bayesian posterior
mean uncertainty is distinct from new-study prediction. Bias sensitivity
is distinct from a claim that publication bias has been established.
Influence is distinct from an exclusion rule. Machine-learning screening
is distinct from confirmatory meta-regression.

## Sources to re-check during local release validation

Before freezing formal 1.0.0, verify the locally installed manuals and
NEWS for `metafor`, `PublicationBias`, `meta`, `metasens`, `metaforest`,
and `orchaRd`, in addition to all backends already required by versions
0.1.0-0.4.0. External APIs may change independently of this source
snapshot.

## 1.0 consolidation principle

The 1.0 integration layer deliberately does not duplicate upstream
estimators. `metafor` remains the core computational foundation, while
specialized robust, dose-response, multivariate, Bayesian,
publication-bias, machine-learning, rendering, and export capabilities
remain optional adapters. The stable contribution of `agriPairMetaFlow`
is the agronomic treatment-control data contract, explicit dependence
semantics, consistent result classes, auditable routing, interpretation
safeguards, and a reproducible end-to-end workflow.

[`apm_capabilities()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_capabilities.md)
materializes this architecture as a runtime-readable registry.
[`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
distinguishes package readiness from statistical validation. This
separation follows the project rule that the presence of a backend is
not evidence that its numerical adapter has passed the
release-validation suite.
