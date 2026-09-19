# Local validation and formal release procedure for agriPairMetaFlow 1.0.0

This document is the authoritative runtime-validation path for version
1.0.0. By project decision, the construction environment does not
install R. All runtime, numerical, Bayesian, rendering, build, and
CRAN-style gates are performed locally.

## 1. Work from an immutable source snapshot

Unpack the supplied ZIP into a clean directory, for example:

``` text
D:/Walter/R/Pacotes_criados/agriPairMetaFlow
```

In R:

``` r

Pkg <- "D:/Walter/R/Pacotes_criados/agriPairMetaFlow"
setwd(Pkg)
ValidationDir <- file.path(dirname(Pkg),"agriPairMetaFlow-validation-1.0.0")
dir.create(ValidationDir,showWarnings=FALSE,recursive=TRUE)
```

Before editing anything, save the SHA-256 of the ZIP/TAR.GZ and compare
it with `agriPairMetaFlow_1.0.0.9000_ARCHIVE_SHA256.txt`.

## 2. Record the local toolchain

``` r

sessionInfo()
R.version.string
Sys.info()
```

Save the output in a dated validation-log directory. For full Bayesian
validation also record JAGS, CmdStan, compiler, and Pandoc versions.

## 3. Install validation dependencies

### Core and frequentist profile

``` r

install.packages(c(
  "metafor", "testthat", "roxygen2", "knitr", "rmarkdown",
  "clubSandwich", "wildmeta", "dosresmeta", "mixmeta",
  "plotly", "gt", "flextable", "openxlsx2", "readxl", "waldo",
  "PublicationBias", "meta", "metasens", "metaforest", "caret",
  "ranger", "jsonlite", "htmlwidgets"
))
```

### Bayesian profile

``` r

install.packages(c(
  "bayesmeta", "BayesTools", "RoBMA", "posterior", "bayesplot", "loo"
))
```

`RoBMA` requires a working JAGS installation. Validate JAGS
independently before treating RoBMA failures as package failures.

For the optional `brms` route, install a working Stan backend
appropriate to the local system. The package lists `cmdstanr` as an
optional dependency, but the exact Stan installation should follow the
current `brms`/`cmdstanr` documentation.

``` r

install.packages("brms")
# install cmdstanr/current CmdStan only if this route will be fully tested
```

The **full 1.0.0 validation profile** includes `mixmeta`, `bayesmeta`,
`BayesTools`, `RoBMA`, `posterior`, `loo`, and, when available, `brms`
with a functioning Stan backend. Core package installation must not
require JAGS or Stan.

## 4. Confirm dependency versions

``` r

pkgs <- c(
  "metafor","mixmeta","bayesmeta","BayesTools","RoBMA","brms",
  "posterior","loo","clubSandwich","wildmeta","dosresmeta",
  "testthat","roxygen2","PublicationBias","meta","metasens",
  "metaforest","caret","ranger","jsonlite","htmlwidgets"
)

versions <- data.frame(
  package = pkgs,
  installed = vapply(pkgs, requireNamespace, logical(1), quietly=TRUE),
  version = vapply(pkgs, function(p) {
    if (requireNamespace(p, quietly=TRUE)) as.character(packageVersion(p)) else NA_character_
  }, character(1))
)
versions

stopifnot(packageVersion("metafor") >= "5.0-1")
if (requireNamespace("mixmeta", quietly=TRUE)) stopifnot(packageVersion("mixmeta") >= "1.2.2")
if (requireNamespace("bayesmeta", quietly=TRUE)) stopifnot(packageVersion("bayesmeta") >= "3.5")
if (requireNamespace("BayesTools", quietly=TRUE)) stopifnot(packageVersion("BayesTools") >= "0.3.0")
if (requireNamespace("RoBMA", quietly=TRUE)) stopifnot(packageVersion("RoBMA") >= "4.0.0")
if (requireNamespace("PublicationBias", quietly=TRUE)) stopifnot(packageVersion("PublicationBias") >= "2.4.0")
if (requireNamespace("metaforest", quietly=TRUE)) stopifnot(packageVersion("metaforest") >= "0.1.5")
```

If a later backend version is installed, inspect its NEWS/manual before
proceeding because external API changes can invalidate adapter
assumptions.

## 5. Regenerate authoritative documentation

``` r

roxygen2::roxygenise(Pkg)
```

Inspect the regenerated `NAMESPACE` and `man/`. The locally regenerated
roxygen output is authoritative for the release candidate. Compare
changes with the conservative source snapshots included in this archive.

Acceptance criteria:

``` r

ns <- readLines(file.path(Pkg,"NAMESPACE"))
stopifnot(any(grepl("export\\(apm_multivariate\\)",ns)))
stopifnot(any(grepl("export\\(apm_bayes\\)",ns)))
stopifnot(any(grepl("S3method\\(predict,apm_bayes\\)",ns)))
stopifnot(any(grepl("S3method\\(autoplot,apm_multivariate\\)",ns)))
stopifnot(any(grepl("export\\(apm_influence\\)",ns)))
stopifnot(any(grepl("export\\(apm_bias\\)",ns)))
stopifnot(any(grepl("export\\(apm_moderator_screen\\)",ns)))
stopifnot(any(grepl("export\\(apm_report\\)",ns)))
stopifnot(any(grepl("export\\(apm_export\\)",ns)))
stopifnot(any(grepl("export\\(apm_workflow\\)",ns)))
stopifnot(any(grepl("export\\(apm_capabilities\\)",ns)))
stopifnot(any(grepl("export\\(apm_doctor\\)",ns)))
stopifnot(any(grepl("S3method\\(print,apm_workflow\\)",ns)))
stopifnot(any(grepl("S3method\\(print,apm_doctor\\)",ns)))
```

## 6. Parse every R source file

``` r

rfiles <- list.files(file.path(Pkg,"R"), pattern="[.]R$", full.names=TRUE)
for (f in rfiles) {
  message("Parsing ", basename(f))
  parse(f)
}
```

Acceptance: zero parse errors.

## 7. Install into a clean temporary library

``` r

lib <- file.path(tempdir(), "agriPairMetaFlow-lib")
dir.create(lib, showWarnings=FALSE, recursive=TRUE)
install.packages(Pkg, repos=NULL, type="source", lib=lib)
library(agriPairMetaFlow, lib.loc=lib)
packageVersion("agriPairMetaFlow")
```

Expected development version: `1.0.0.9000` until the formal release is
frozen.

## 8. Run the complete test suite

``` r

testthat::test_dir(file.path(Pkg,"tests","testthat"), reporter="summary")
```

Run first with the core profile, then repeat with all optional backends
installed. Core tests must not fail merely because JAGS or Stan is
absent. Optional-backend tests may skip only when their documented
external dependency is genuinely unavailable.

## 8A. Validate the stable 1.0 capability registry

Run the registry before any optional-backend validation:

``` r

caps <- apm_capabilities(installed=TRUE, detail="full")
print(caps, row.names=FALSE)

stopifnot(nrow(caps) >= 20)
stopifnot(any(caps$feature == "effect-sizes" & caps$core))
stopifnot(any(caps$feature == "dose-response" & !caps$core))
stopifnot(any(caps$feature == "bayesian" & !caps$core))
stopifnot(all(c("feature","backend","package","minimum_version","core",
                "validation_tier","installed","version","version_ok",
                "system_ready","status","validation_status") %in% names(caps)))
```

Check the declared core engine:

``` r

core_cap <- apm_capabilities("effect-sizes", installed=TRUE, detail="full")
stopifnot(core_cap$installed)
stopifnot(core_cap$version_ok)
stopifnot(core_cap$status == "AVAILABLE")
```

Check optional feature filtering:

``` r

dose_cap <- apm_capabilities("dose-response", installed=TRUE, detail="full")
bayes_cap <- apm_capabilities("bayesian", installed=TRUE, detail="full")
print(dose_cap, row.names=FALSE)
print(bayes_cap, row.names=FALSE)
```

Acceptance rules:

1.  a missing package in `Suggests` may produce `NOT INSTALLED`, but
    must never be reported as an available capability;
2.  a package below the registered minimum version must report
    `VERSION TOO OLD`;
3.  a missing CmdStan installation must not be reported as a usable
    CmdStan capability simply because `cmdstanr` is installed;
4.  the registry must not install, update, or configure any dependency.

Save the result:

``` r

write.csv(caps, file.path(ValidationDir,"capabilities.csv"), row.names=FALSE)
```

## 8B. Validate `apm_doctor()` as a non-mutating diagnostic

Run the core inspection first:

``` r

d0 <- apm_doctor(
  full=FALSE,
  check_backends=FALSE,
  check_render=FALSE,
  check_examples=FALSE
)
print(d0)
stopifnot(inherits(d0,"apm_doctor"))
stopifnot(identical(d0$mutated_environment,FALSE))
stopifnot(!any(d0$checks$status == "FAIL" & d0$checks$scope %in% c("core","core-backend")))
```

Then inspect the full release computer:

``` r

d1 <- apm_doctor(
  full=TRUE,
  check_backends=TRUE,
  check_render=TRUE,
  check_examples=TRUE
)
print(d1)
write.csv(d1$checks,file.path(ValidationDir,"doctor_checks.csv"),row.names=FALSE)
```

Interpret statuses carefully:

- `PASS`: the requested environmental check actually passed;
- `WARN`: an optional capability or auxiliary tool is unavailable or
  needs attention;
- `FAIL`: a core/runtime check failed and must be resolved before
  release;
- `NOT RUN`: the corresponding check was intentionally not requested.

[`apm_doctor()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_doctor.md)
is not evidence that all statistical adapters are numerically correct.
Even a complete `PASS` from the doctor does **not** replace Sections 9
onward, `testthat`, vignette rendering, or `R CMD check --as-cran`.

To confirm non-mutation in a strict validation session, record installed
packages and selected options before and after:

``` r

before_pkgs <- installed.packages()[,"Version"]
before_opts <- options()
dtmp <- apm_doctor(full=TRUE,check_backends=TRUE,check_render=TRUE,check_examples=TRUE)
after_pkgs <- installed.packages()[,"Version"]
after_opts <- options()
stopifnot(identical(before_pkgs,after_pkgs))
```

If option differences occur because an upstream package changes a
temporary option during loading, identify and document that upstream
behavior. `agriPairMetaFlow` itself must not install or update software.

## 8C. Validate `apm_workflow()` against manual lower-level calls

### Shared-control nitrogen example

``` r

wf <- apm_workflow(
  maize_n_shared,
  measure="lnRR",
  dependence="shared_control",
  model="multilevel"
)

stopifnot(inherits(wf,"apm_workflow"))
stopifnot(wf$settings$dependence == "shared_control")
stopifnot(wf$settings$model == "multilevel")
stopifnot(inherits(wf$V,"apm_vcov"))
stopifnot(all(c("step","decision","reason","source") %in% names(wf$routing_log)))
```

Reproduce the same analysis manually:

``` r

es_manual <- apm_effect_size(
  maize_n_shared,"lnRR",
  m_t=mean_t,sd_t=sd_t,n_t=n_t,
  m_c=mean_c,sd_c=sd_c,n_c=n_c
)

V_manual <- apm_vcov(
  es_manual,
  cluster=experiment_id,
  shared_control=TRUE
)

fit_manual <- apm_multilevel(
  es_manual,
  random=~1|study_id/experiment_id/effect_id,
  V=V_manual
)

stopifnot(isTRUE(all.equal(
  unname(coef(wf$fit$backend_fit)),
  unname(coef(fit_manual$backend_fit)),
  tolerance=1e-10
)))
stopifnot(isTRUE(all.equal(as.matrix(wf$V),as.matrix(V_manual),tolerance=1e-12)))
```

### Automatic dependence/model routing

``` r

wa <- apm_workflow(maize_n_shared,measure="lnRR")
stopifnot(wa$settings$dependence == "shared_control")
stopifnot(wa$settings$model == "multilevel")
stopifnot(any(wa$routing_log$source == "auto"))
```

Review the log manually:

``` r

wa$routing_log
```

Every automatic decision must have a human-readable reason. No hidden
decision should be required to reconstruct the model.

### Moderator and agronomic-threshold example

``` r

wi <- apm_workflow(
  irrigation_climate,
  measure="lnRR",
  moderators=~rainfall+mean_temp,
  threshold=5
)

stopifnot(inherits(wi$fit,"apm_metareg"))
stopifnot(inherits(wi$diagnostics$threshold,"apm_threshold"))
stopifnot(any(wi$routing_log$step=="moderators"))
stopifnot(any(wi$routing_log$step=="threshold"))
```

Compare the fitted coefficients with an explicit
[`apm_metareg()`](https://wep69.github.io/agriPairMetaFlow/reference/apm_metareg.md)
fit using the same effects and moderator formula.

### Explicit paired design

``` r

wp <- apm_workflow(
  wheat_paired_blocks,
  measure="lnRR",
  dependence="paired",
  model="random"
)

stopifnot(attr(wp$effects,"design") == "paired")
stopifnot(wp$settings$dependence == "paired")
```

Verify the guard against invented pairing:

``` r

bad <- wheat_paired_blocks
bad$r_tc <- NULL
stopifnot(inherits(
  try(apm_workflow(bad,measure="lnRR",dependence="paired"),silent=TRUE),
  "try-error"
))
```

### Optional robust sensitivity inside the workflow

``` r

if (requireNamespace("clubSandwich",quietly=TRUE)) {
  wr <- apm_workflow(
    maize_n_shared,
    measure="lnRR",
    dependence="shared_control",
    model="multilevel",
    robust=TRUE
  )
  stopifnot(inherits(wr$sensitivities$robust,"apm_robust"))
}
```

### Optional Bayesian sensitivity inside the workflow

Only run this after the selected Bayesian backend has independently
passed its own validation section.

``` r

if (requireNamespace("bayesmeta",quietly=TRUE)) {
  wb <- apm_workflow(
    irrigation_climate,
    measure="lnRR",
    bayes=TRUE,
    seed=20260826
  )
  stopifnot(inherits(wb$sensitivities$bayesian,"apm_bayes"))
}
```

The integrated workflow must never be considered validated solely
because it returns an object. Its manual-equivalence checks are part of
the 1.0 release gate.

## 9. Multivariate numerical validation

### 9.1 Direct `metafor::rma.mv()` equivalence

``` r

d <- soil_management_multiresponse
V <- diag(d$vi)

a <- apm_multivariate(
  d,
  outcome=outcome,
  study=mv_study_id,
  V=V,
  structure="UN",
  backend="metafor"
)

d$.o <- factor(d$outcome, levels=unique(d$outcome))
d$.s <- d$mv_study_id

b <- metafor::rma.mv(
  yi=d$yi,
  V=V,
  mods=~.o-1,
  random=~.o|.s,
  struct="UN",
  method="REML",
  data=d
)

stopifnot(isTRUE(all.equal(unname(coef(a)), unname(coef(b)), tolerance=1e-8)))
stopifnot(isTRUE(all.equal(unname(vcov(a)), unname(vcov(b)), tolerance=1e-8)))
```

Also repeat for `CS` and `DIAG` where estimable.

### 9.2 Sampling-correlation sensitivity

``` r

s <- apm_mvcor_sensitivity(
  soil_management_multiresponse,
  outcome=outcome,
  study=mv_study_id,
  rho=c(0,.25,.50,.75)
)
print(s)
stopifnot(all(c(0,.25,.50,.75) %in% unique(s$results$rho)))
```

Manually verify one covariance block:

``` r

d <- soil_management_multiresponse
idx <- which(d$mv_study_id == unique(d$mv_study_id)[1])
rho <- .5
S <- outer(sqrt(d$vi[idx]), sqrt(d$vi[idx])) * rho
diag(S) <- d$vi[idx]
stopifnot(min(eigen((S+t(S))/2, symmetric=TRUE)$values) >= -1e-10)
```

### 9.3 Optional `mixmeta` cross-check

``` r

if (requireNamespace("mixmeta",quietly=TRUE)) {
  mm <- apm_multivariate(
    biochar_multiresponse,
    outcome=outcome,
    study=study_id,
    V=diag(biochar_multiresponse$vi),
    structure="CS",
    backend="mixmeta"
  )
  print(mm)
  stopifnot(all(is.finite(coef(mm))))
  stopifnot(all(is.finite(diag(vcov(mm)))))
}
```

Do not require exact coefficient equality between different covariance
parameterizations unless the fitted models are mathematically identical.
Document any intended parameterization differences.

## 10. Prior-object and prior-predictive validation

These functions do not require a Bayesian backend and must always run.

``` r

p <- apm_prior(
  effect=list(dist="normal",mean=0,sd=.2),
  tau=list(dist="halfnormal",scale=.2),
  moderators=list(rainfall=list(dist="normal",mean=0,sd=.001))
)

pc1 <- apm_prior_check(p,"lnRR",x=data.frame(rainfall=c(600,1200)),draws=5000,seed=123,plot=FALSE)
pc2 <- apm_prior_check(p,"lnRR",x=data.frame(rainfall=c(600,1200)),draws=5000,seed=123,plot=FALSE)
stopifnot(identical(pc1$draws,pc2$draws))
stopifnot(all(is.finite(pc1$transformed$ratio)))
```

Inspect whether the implied percentage changes and heterogeneity values
are scientifically plausible for the intended agronomic application.

## 11. `bayesmeta` validation

### 11.1 Intercept-only model

``` r

stopifnot(requireNamespace("bayesmeta",quietly=TRUE))

p <- apm_prior(
  effect=list(dist="normal",mean=0,sd=.2),
  tau=list(dist="halfnormal",scale=.2)
)

a <- apm_bayes(agri_effects_benchmark, prior=p, backend="bayesmeta")
print(a)
summary(a)
```

Validate the backend object directly:

``` r

stopifnot(inherits(a$backend_fit,"bayesmeta"))
q_mean <- a$backend_fit$qposterior(mu.p=c(.025,.5,.975))
q_pred <- a$backend_fit$qposterior(theta.p=c(.025,.5,.975), predict=TRUE)

pa <- apm_bayes_predict(a,predictive=FALSE,transform="none")
pp <- apm_bayes_predict(a,predictive=TRUE,transform="none")

stopifnot(isTRUE(all.equal(as.numeric(pa$raw[1,-1]), as.numeric(q_mean), tolerance=1e-10)))
stopifnot(isTRUE(all.equal(as.numeric(pp$raw[1,-1]), as.numeric(q_pred), tolerance=1e-10)))
```

### 11.2 Bayesian meta-regression via `bmr()`

``` r

es <- apm_effect_size(irrigation_climate,"lnRR",
  m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
es$rainfall <- irrigation_climate$rainfall

b <- apm_bayes(es,mods=~rainfall,backend="bayesmeta")
stopifnot(inherits(b$backend_fit,"bmr"))

nd <- data.frame(rainfall=c(700,1000))
pr <- apm_bayes_predict(b,newdata=nd,predictive=TRUE,transform="none")
Xn <- model.matrix(~rainfall,nd)
ref <- sapply(c(.025,.5,.975), function(z) b$backend_fit$qpredict(z,x=Xn,mean=FALSE))
stopifnot(isTRUE(all.equal(as.matrix(pr$raw[,-1]), ref, tolerance=1e-10)))
```

## 12. Bayesian agronomic-threshold validation

``` r

t_mean <- apm_bayes_threshold(a,threshold=5,scale="percent",predictive=FALSE)
t_pred <- apm_bayes_threshold(a,threshold=5,scale="percent",predictive=TRUE)
print(t_mean)
print(t_pred)

stopifnot(t_mean$probability >= 0, t_mean$probability <= 1)
stopifnot(t_pred$probability >= 0, t_pred$probability <= 1)
```

Verify a two-sided threshold against direct CDF calculations:

``` r

a0 <- log(1.05)
lo <- a$backend_fit$pposterior(mu=-a0)
hi <- a$backend_fit$pposterior(mu= a0)
ref_prob <- lo + (1-hi)
two <- apm_bayes_threshold(a,threshold=5,scale="percent",direction="two-sided")
stopifnot(isTRUE(all.equal(two$probability,ref_prob,tolerance=1e-10)))
```

## 13. RoBMA/JAGS validation

Run only after JAGS is independently confirmed operational.

``` r

stopifnot(requireNamespace("RoBMA",quietly=TRUE))
stopifnot(requireNamespace("BayesTools",quietly=TRUE))

rfit <- apm_bayes(
  agri_effects_benchmark,
  backend="RoBMA",
  chains=3,
  iter=5000,
  warmup=2000,
  seed=2026
)

rd <- apm_bayes_diagnostics(rfit,checks=c("convergence","ess","mcse","ppc"),plot=TRUE)
print(rd)
```

Inspect the backend summary manually. Do not proceed to substantive
interpretation if convergence warnings remain.

Verify the prediction target explicitly:

``` r

p_apm <- apm_bayes_predict(rfit,predictive=TRUE,transform="none")
p_ref <- predict(rfit$backend_fit,newdata=TRUE,type="estimate",quiet=TRUE)
stopifnot(isTRUE(all.equal(as.matrix(p_apm$draws),as.matrix(p_ref),check.attributes=FALSE,tolerance=1e-8)))
```

For comparison only, confirm that `type="response"` is a different
target because it includes future sampling variability when that
information is supplied.

## 14. BayesTools prior-translation validation

Exercise every supported RoBMA translation locally:

``` r

priors <- list(
  apm_prior(tau=list(dist="halfnormal",scale=.2)),
  apm_prior(tau=list(dist="halft",scale=.2,df=3)),
  apm_prior(tau=list(dist="halfcauchy",scale=.2)),
  apm_prior(tau=list(dist="exponential",rate=4)),
  apm_prior(tau=list(dist="uniform",min=0,max=1))
)

# Internal translation can be exercised from the namespace for validation only:
for (p in priors) {
  z <- agriPairMetaFlow:::.apm_to_bayestools_prior(p$tau)
  print(z)
}
```

Confirm from the printed backend objects that the exponential route uses
the BayesTools `exp` distribution and that uniform bounds correspond to
`a`/`b`.

## 15. Optional brms/Stan validation

Run only with a validated Stan toolchain.

``` r

if (requireNamespace("brms",quietly=TRUE)) {
  bf <- apm_bayes(
    agri_effects_benchmark,
    backend="brms",
    chains=4,iter=4000,warmup=1000,seed=2026
  )
  bd <- apm_bayes_diagnostics(bf,plot=TRUE)
  print(bd)
  stopifnot(!bd$severe_failure)

  pm <- apm_bayes_predict(bf,predictive=FALSE)

  # agriPairMetaFlow defines predictive=TRUE as the latent true effect in a
  # new study/context, not as a future noisy observed effect-size estimate.
  # Reproduce the brms adapter directly with posterior_epred().
  set.seed(2026)
  pp <- apm_bayes_predict(bf,predictive=TRUE)

  nd <- bf$data
  row_new <- paste0(".apm_new_row_", seq_len(nrow(nd)))
  nd$.apm_row <- factor(row_new, levels=c(levels(bf$data$.apm_row), row_new))
  if (!is.null(bf$cluster)) {
    cl_new <- paste0(".apm_new_cluster_", seq_len(nrow(nd)))
    nd$.apm_cluster <- factor(cl_new, levels=c(levels(bf$data$.apm_cluster), cl_new))
  }
  set.seed(2026)
  direct_pp <- brms::posterior_epred(
    bf$backend_fit,
    newdata=nd,
    re_formula=NULL,
    allow_new_levels=TRUE,
    sample_new_levels="gaussian"
  )
  direct_pm <- brms::posterior_epred(
    bf$backend_fit,
    newdata=bf$data,
    re_formula=NA,
    allow_new_levels=TRUE
  )

  stopifnot(identical(pp$target, "brms latent true-effect prediction for a new study/context"))
  stopifnot(identical(pm$target, "brms population-level mean effect"))
  stopifnot(isTRUE(all.equal(
    as.numeric(pp$raw[1, c("q0.025","q0.5","q0.975")]),
    as.numeric(stats::quantile(direct_pp[,1], c(.025,.5,.975))),
    tolerance=1e-8
  )))
  stopifnot(isTRUE(all.equal(
    as.numeric(pm$raw[1, c("q0.025","q0.5","q0.975")]),
    as.numeric(stats::quantile(direct_pm[,1], c(.025,.5,.975))),
    tolerance=1e-8
  )))
  print(pm); print(pp)
}
```

Inspect R-hat, bulk/tail ESS, MCSE, divergent transitions, and treedepth
warnings. The prediction check above verifies that the `brms` route
targets the same latent new-study effect concept used by the other
Bayesian adapters. A successful compilation is not sufficient evidence
of model convergence.

## 16. Bayesian model-comparison validation

For `brms` or `RoBMA`, compare only prespecified models fitted to
exactly the same analysis data, effect measure, and backend.

``` r

# Examples after fitting compatible models b1 and b2:
# apm_bayes_compare(b1,b2,criterion="loo",weights=TRUE)
# apm_bayes_compare(b1,b2,criterion="waic")
# For RoBMA 4.0.0, the adapter computes/caches add_loo() or add_waic() before extraction.
```

Inspect Pareto-k diagnostics before interpreting LOO results. WAIC and
LOO estimate predictive performance and should not be presented as
null-hypothesis tests.

For a RoBMA model-averaging object:

``` r

# rob <- apm_bayes(..., backend="RoBMA", bias_adjust=TRUE)
# apm_bayes_compare(rob,criterion="model_probability")
```

Posterior model probabilities and LOO/WAIC answer different questions
and must not be combined into a single ranking without justification.

## 17. Validate leave-one-out and influence diagnostics

``` r

fit <- apm_fit(agri_effects_benchmark)
loo <- apm_leave_one_out(fit, unit="effect")
ref <- metafor::leave1out(fit$backend_fit)
stopifnot(isTRUE(all.equal(loo$raw$estimate, as.numeric(ref$estimate), tolerance=1e-8)))

inf <- apm_influence(fit, unit="effect", plot=FALSE)
stopifnot(inherits(inf,"apm_influence"))
stopifnot(nrow(inf$diagnostics) == nrow(fit$data))
```

For dependence-aware fits, repeat at the study level and verify that the
refit retains the same submatrix of the stored sampling covariance
matrix `V`. Do not compare study-level cluster deletion with
[`metafor::leave1out()`](https://wviechtb.github.io/metafor/reference/leave1out.html)
as if they were the same operation.

## 18. Validate GOSH reproducibility and clustering

``` r

g1 <- apm_gosh(fit, subsets=100, seed=2026, plot=FALSE)
g2 <- apm_gosh(fit, subsets=100, seed=2026, plot=FALSE)
stopifnot(identical(g1$results,g2$results))
```

For large GOSH runs, use developer-side precomputation and retain seed,
package versions, input hash, subset count, and result hash. If several
effect sizes belong to one study, validate the cluster-respecting route
rather than randomly breaking clusters across subsets.

## 19. Validate small-study-effect and publication-bias sensitivity

``` r

b <- apm_bias(fit, methods=c("egger","rank","trimfill","selection"))
print(b$status)
stopifnot(all(c("method","applicable","message","backend") %in% names(b$status)))
```

Compare the core methods directly with
[`metafor::regtest()`](https://wviechtb.github.io/metafor/reference/regtest.html),
`ranktest()`, `trimfill()`, and `selmodel()` using identical settings.
Some selection models can fail because a p-value interval is empty; this
should be retained as an informative method failure rather than hidden.

With `PublicationBias` installed:

``` r

s1 <- apm_bias(fit, methods="svalue", q=0, favor="positive")
s2 <- PublicationBias::pubbias_svalue(
  yi=fit$data$yi, vi=fit$data$vi, cluster=fit$data$study_id,
  q=0, model_type="fixed", favor_positive=TRUE, small=TRUE
)
stopifnot(inherits(s1,"apm_bias"))
# Inspect s1$results$svalue and s2 numerically; preserve the backend object.
```

If `meta` and `metasens` are installed, exercise both `copas` and
`limit` adapters. Treat all methods as sensitivity analyses under
different assumptions. Do not select one adjusted estimate merely
because it is more or less statistically significant.

## 20. Validate contour funnel and orchard graphics

``` r

p1 <- apm_funnel_contour(fit)
p2 <- apm_orchard(fit, transform="percent")
stopifnot(inherits(p1,"ggplot"), inherits(p2,"ggplot"))
stopifnot(!is.null(attr(p1,"apm_plot_data")))
stopifnot(!is.null(attr(p2,"apm_plot_data")))
```

Visually verify the reference line, SE-axis direction, contour
boundaries, observed effects, confidence intervals, prediction
intervals, transformation labels, and study/group alignment. When
`orchaRd` is installed, use it as a visual/numerical cross-check for
compatible simple models; exact layout identity is neither expected nor
required.

## 21. Validate exploratory MetaForest screening

``` r

if (requireNamespace("metaforest",quietly=TRUE)) {
  mf <- apm_moderator_screen(
    agri_effects_benchmark,
    moderators=~dose+rainfall+crop+soil_texture,
    seed=2026, tune=FALSE
  )
  stopifnot(inherits(mf,"apm_moderator_screen"))
  stopifnot(isTRUE(mf$exploratory))
  stopifnot(all(is.finite(mf$importance$importance)))
}
```

Repeat with `tune=TRUE` when `caret` is installed. For clustered
effects, inspect the cross-validation indices and confirm that effects
from the same study are not split between training and assessment folds.
Use MetaForest for hypothesis generation; confirm candidate moderators
with the appropriate meta-regression workflow.

## 22. Validate explanation, report, and export

``` r

e1 <- apm_explain(fit,audience="scientific",transform="percent")
e2 <- apm_explain(fit,audience="scientific",transform="percent")
stopifnot(identical(e1,e2))

tf <- tempfile(fileext=".rds")
apm_export(fit,tf,format="rds",overwrite=TRUE)
stopifnot(inherits(readRDS(tf),"apm_model"))

cf <- tempfile(fileext=".csv")
apm_export(fit,cf,format="csv",overwrite=TRUE)
stopifnot(is.numeric(utils::read.csv(cf)$estimate))
```

Render at least one HTML and one DOCX report locally. PDF additionally
requires an appropriate LaTeX installation. Confirm that the report
states that it summarizes an existing object and does not refit the
model. Check its object hash, payload hash, session information, tables,
figures, and transformed interpretation against the originating object.

Export a PNG and TIFF at 600 dpi and an SVG. Visually inspect that no
clipping, rasterization error, or transformed-axis inconsistency was
introduced.

## 23. Render all vignettes

``` r

vigs <- list.files(file.path(Pkg,"vignettes"),pattern="[.]Rmd$",full.names=TRUE)
for (v in vigs) {
  message("Rendering ",basename(v))
  rmarkdown::render(v,quiet=FALSE)
}
```

Then separately run every Bayesian block marked `eval=FALSE` under the
corresponding full backend profile. Those blocks are deliberately
excluded from lightweight rendering because JAGS/Stan are optional
external systems.

## 24. Visual inspection

At minimum inspect:

``` r

mv <- apm_multivariate(
  soil_management_multiresponse,
  outcome=outcome,study=mv_study_id,
  V=diag(soil_management_multiresponse$vi)
)
apm_multivariate_plot(mv,"outcome_forest",transform="percent")
if(!is.null(mv$between_cor)) apm_multivariate_plot(mv,"correlation")

pc <- apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)),"lnRR",seed=1)
pc$plot
```

Check axes, transformations, endpoint labels, zero/reference lines,
uncertainty intervals, correlation labels, and whether any graphic could
imply observed covariance when only an assumed rho was used.

## 25. Run all examples under check conditions

The definitive example test should come from `R CMD check`. Before that,
selected manuals can be extracted with
[`tools::Rd2ex()`](https://rdrr.io/r/tools/Rd2HTML.html).

``` r

tools::Rd2ex(file.path(Pkg,"man","apm_multivariate.Rd"),out="apm_multivariate-ex.R")
source("apm_multivariate-ex.R",echo=TRUE)

tools::Rd2ex(file.path(Pkg,"man","apm_bayes.Rd"),out="apm_bayes-ex.R")
source("apm_bayes-ex.R",echo=TRUE)
```

## 26. Build the actual R source tarball

From a terminal in the parent directory:

``` bash
R CMD build agriPairMetaFlow
```

Do not rename a manually created `.tar.gz` as if it were produced by
`R CMD build`.

Record the generated filename and SHA-256.

## 27. Check the exact built tarball

``` bash
R CMD check --as-cran agriPairMetaFlow_1.0.0.9000.tar.gz
```

Use the actual filename generated by `R CMD build`.

Acceptance target before release freezing: no ERROR; investigate every
WARNING and NOTE rather than suppressing them mechanically.

## 28. Re-test the installed tarball

Install from the exact built artifact into a new clean library and rerun
the core numerical tests, multivariate equivalence, `bayesmeta` checks,
and all S3 dispatch tests. The immutable built tarball, not the working
directory, is the release candidate.

## 29. Freeze release evidence

Archive together:

``` text
sessionInfo.txt
backend_versions.csv
roxygen_log.txt
testthat_log.txt
vignette_render_log.txt
R_CMD_build.log
R_CMD_check_as_cran.log
built_tarball_sha256.txt
Bayesian_diagnostics/
plot_inspection_notes.md
```

Only after these local gates pass should `DESCRIPTION` be changed from
`1.0.0.9000` to `1.0.0` and a formal release tarball be frozen.

## 30. Promote the validated development candidate to formal 1.0.0

Do **not** change the version number before the complete `1.0.0.9000`
validation cycle has passed. The first successful build/check
establishes that the source is internally coherent. Then create the
formal release commit/copy.

### 30.1 Change only the release metadata

In `DESCRIPTION`:

``` text
Version: 1.0.0
```

Update the top NEWS heading from `1.0.0.9000` to `1.0.0` and record the
validation date. Do not change statistical code at this point.

### 30.2 Regenerate documentation again

``` r

roxygen2::roxygenise(Pkg)
```

If documentation regeneration changes source-facing behavior, return to
the complete test sequence.

### 30.3 Rebuild the formal release

From the package parent directory:

``` bash
R CMD build agriPairMetaFlow
```

The expected filename is normally:

``` text
agriPairMetaFlow_1.0.0.tar.gz
```

Freeze this file immediately. Do not edit the source and continue using
the old tarball.

### 30.4 Check the exact formal tarball

``` bash
R CMD check --as-cran agriPairMetaFlow_1.0.0.tar.gz
```

Read the complete `agriPairMetaFlow.Rcheck/00check.log`. Resolve every
package-caused ERROR and WARNING and every correctable NOTE. If any
source file changes, rebuild and repeat the check from the new tarball.

### 30.5 Install the exact formal tarball into a clean library

``` r

release_lib <- file.path(tempdir(),"agriPairMetaFlow-release-lib")
dir.create(release_lib,showWarnings=FALSE,recursive=TRUE)
install.packages("agriPairMetaFlow_1.0.0.tar.gz",repos=NULL,type="source",lib=release_lib)
library(agriPairMetaFlow,lib.loc=release_lib)
stopifnot(as.character(packageVersion("agriPairMetaFlow"))=="1.0.0")
```

Rerun the core smoke suite, the workflow manual-equivalence checks, and
`apm_doctor(full=TRUE,...)` from this exact installed artifact.

## 31. Hash and archive the formal artifacts

### Windows PowerShell

``` powershell
Get-FileHash .\agriPairMetaFlow_1.0.0.tar.gz -Algorithm SHA256
Get-FileHash .\agriPairMetaFlow_1.0.0_source.zip -Algorithm SHA256
```

### Linux/macOS

``` bash
sha256sum agriPairMetaFlow_1.0.0.tar.gz
sha256sum agriPairMetaFlow_1.0.0_source.zip
```

Archive at minimum:

``` text
agriPairMetaFlow_1.0.0.tar.gz
agriPairMetaFlow_1.0.0_source.zip
SHA256SUMS.txt
DESCRIPTION
NAMESPACE
NEWS.md
ARCHITECTURE.md
STATE_OF_THE_ART.md
IMPLEMENTATION_SUMMARY.md
LOCAL_VALIDATION.md
VALIDATION.md
00check.log
sessionInfo.txt
backend_versions.csv
capabilities.csv
doctor_checks.csv
testthat_log.txt
example_log.txt
vignette_render_log.txt
plot_inspection_notes.md
Bayesian_diagnostics/
```

The archived tarball must be byte-for-byte the same tarball that
received the final `R CMD check --as-cran` result.

## 32. Final acceptance checklist

A formal **1.0.0 PASS** requires all of the following:

package version is `1.0.0` in the final built artifact;

57/57 exported analytical functions are present after roxygen
regeneration;

every exported function has three meaningful manual examples;

every exported function appears at least three times across the vignette
sources;

all registered S3 methods dispatch correctly;

all R files parse;

all core tests pass in a clean library;

all optional-backend tests required for the intended full-feature
release pass;

manual and orchestrated workflow results agree numerically;

shared-control covariance tests reproduce the direct backend/reference
calculations;

robust, dose-response, multivariate, Bayesian, bias-sensitivity, and
MetaForest adapters pass their documented validation tiers;

stochastic analyses use recorded seeds and convergence/Monte Carlo
criteria;

normal vignettes render successfully;

heavy computations use audited frozen developer-side results where
applicable;

figures and exports pass visual inspection;

HTML and DOCX reports render; PDF is checked when the required LaTeX
stack is part of the release environment;

`R CMD build` succeeds;

the exact frozen formal tarball passes `R CMD check --as-cran` with no
unresolved package-caused ERROR/WARNING and no unreviewed NOTE;

the installed formal tarball passes the post-install
smoke/reproducibility checks;

SHA-256 hashes, logs, backend versions, capability registry, doctor
output, and session information are archived.

If any item is not satisfied, retain development status and do not label
the archive as a validated formal 1.0.0 release.
