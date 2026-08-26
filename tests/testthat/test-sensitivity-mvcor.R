test_that("apm_mvcor_sensitivity constructs covariance scenarios", {
  skip_if_not_installed("metafor")
  d <- soil_management_multiresponse; if(!"yi" %in% names(d)) d$yi <- d$lnRR
  s <- apm_mvcor_sensitivity(d, outcome=outcome, study=mv_study_id, rho=c(0,.5))
  expect_s3_class(s,"apm_sensitivity")
  expect_equal(sort(unique(s$results$rho)),c(0,.5))
})

test_that("apm_mvcor_sensitivity rejects boundary correlations", {
  expect_error(apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=1), "strictly")
})

test_that("apm_mvcor_sensitivity preserves failed scenarios", {
  skip_if_not_installed("metafor")
  d <- soil_management_multiresponse; if(!"yi" %in% names(d)) d$yi <- d$lnRR
  s <- apm_mvcor_sensitivity(d, outcome=outcome, study=mv_study_id, rho=c(0,.2), fit_args=list(structure="DIAG"))
  expect_true(is.list(s$fits)); expect_equal(length(s$rho),2)
})
