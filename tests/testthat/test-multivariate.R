test_that("apm_multivariate validates multivariate structure", {
  expect_error(apm_multivariate(soil_management_multiresponse[soil_management_multiresponse$outcome=="yield",], outcome=outcome, study=mv_study_id), "two outcomes")
  expect_error(apm_multivariate(transform(soil_management_multiresponse, vi=-abs(vi)), outcome=outcome, study=mv_study_id), "positive")
})

test_that("apm_multivariate agrees with direct metafor rma.mv", {
  skip_if_not_installed("metafor")
  d <- soil_management_multiresponse
  V <- diag(d$vi)
  a <- apm_multivariate(d, outcome=outcome, study=mv_study_id, V=V, structure="UN", backend="metafor")
  d$.o <- factor(d$outcome, levels=unique(d$outcome)); d$.s <- d$mv_study_id
  ref <- metafor::rma.mv(yi=d$yi, V=V, mods=~.o-1, random=~.o|.s, struct="UN", method="REML", data=d)
  expect_equal(unname(coef(a)), unname(coef(ref)), tolerance=1e-8)
  expect_equal(unname(vcov(a)), unname(vcov(ref)), tolerance=1e-8)
})

test_that("apm_multivariate can fit biochar outcomes", {
  skip_if_not_installed("metafor")
  d <- biochar_multiresponse; d$yi <- d$lnRR
  a <- apm_multivariate(d, outcome=outcome, study=study_id, V=diag(d$vi), structure="CS")
  expect_s3_class(a,"apm_multivariate")
  expect_equal(length(a$outcomes),3)
})

test_that("mixmeta adapter reorders shuffled long data and V together", {
  skip_if_not_installed("mixmeta")
  set.seed(44)
  idx <- sample(seq_len(nrow(biochar_multiresponse)))
  d <- biochar_multiresponse[idx, ]
  V <- diag(d$vi)
  fit <- apm_multivariate(d, outcome=outcome, study=study_id, V=V, backend="mixmeta", structure="CS")
  expect_s3_class(fit, "apm_multivariate")
  expect_equal(sort(fit$data$.apm_source_row), seq_len(nrow(d)))
  expect_equal(diag(fit$V), fit$data$vi, tolerance=1e-12)
  by_study <- split(as.character(fit$data$.apm_outcome), fit$data$.apm_study)
  expect_true(all(vapply(by_study, identical, logical(1), fit$outcomes)))
})

test_that("multivariate prediction table distinguishes CI from between-study PI", {
  fit <- apm_multivariate(
    soil_management_multiresponse,
    outcome=outcome, study=mv_study_id,
    V=diag(soil_management_multiresponse$vi), backend="metafor"
  )
  expect_true(all(c("tau","pi_lower","pi_upper") %in% names(fit$outcome_estimates)))
  ok <- is.finite(fit$outcome_estimates$pi_lower) & is.finite(fit$outcome_estimates$pi_upper)
  expect_true(all((fit$outcome_estimates$pi_upper-fit$outcome_estimates$pi_lower)[ok] >=
                  (fit$outcome_estimates$ci_upper-fit$outcome_estimates$ci_lower)[ok]))
})
