# Exploratory Moderator Screening, Reporting, Interpretation, and Export

## MetaForest is exploratory

When many plausible agronomic moderators are available, random-forest
screening can help reveal nonlinearities and interactions worth
investigating. It does not turn exploratory importance into confirmatory
evidence.

``` r

mf1 <- apm_moderator_screen(agri_effects_benchmark, ~dose+rainfall+crop+soil_texture, seed=1, tune=FALSE)
mf2 <- apm_moderator_screen(agri_effects_benchmark, ~dose+rainfall+crop, seed=2, importance="permutation", tune=FALSE)
mf3 <- apm_moderator_screen(agri_effects_benchmark, ~dose+rainfall+soil_texture, seed=3, importance="minimal_depth", tune=FALSE)
```

Candidate moderators identified here should be re-expressed as
scientifically interpretable hypotheses and evaluated with the
meta-regression tools, with uncertainty and multiplicity kept visible.

## Deterministic interpretation

[`apm_explain()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_explain.md)
uses explicit rules and quantities already present in package objects.
It does not generate unsupported causal claims.

``` r

e1 <- apm_explain(fit, audience="scientific", transform="percent")
e2 <- apm_explain(apm_heterogeneity(fit), audience="teaching")
e3 <- apm_explain(fit, audience="extension", transform="percent")
```

## Reproducible reporting

Reports summarize an already fitted object and do not refit the model.
The payload records object hashes, package version, R version and
selected sections.

``` r

r1 <- apm_report(fit, "meta-report.html", format="html")
r2 <- apm_report(fit, "meta-report.docx", format="docx", sections=c("model","heterogeneity","prediction","plots"))
r3 <- apm_report(fit, "meta-report.pdf", format="pdf", title="Agronomic treatment-control synthesis", seed=2026)
```

## Publication-quality export

``` r

x1 <- apm_export(fit, "pooled-model.csv", format="csv")
x2 <- apm_export(apm_orchard(fit), "orchard.svg", format="svg", width=8, height=5)
x3 <- apm_export(fit, "model.rds", format="rds")
```

Numeric tables remain numeric in CSV/XLSX output, while RDS preserves
the complete analysis object and provenance.
