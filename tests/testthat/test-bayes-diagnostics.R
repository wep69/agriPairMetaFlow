test_that("bayesmeta diagnostics do not fabricate MCMC quantities", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  d <- apm_bayes_diagnostics(b,plot=FALSE)
  expect_s3_class(d,"apm_bayes_diagnostics")
  expect_true(any(grepl("not defined",d$warnings)))
  expect_false(d$severe_failure)
})

test_that("diagnostic requests are validated", {
  b <- structure(list(),class="apm_bayes")
  expect_error(apm_bayes_diagnostics(b,checks="magic"),"Unsupported")
})

test_that("bayesmeta diagnostic computation is marked deterministic", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  d <- apm_bayes_diagnostics(b,checks="convergence",plot=FALSE)
  expect_true(any(grepl("deterministic",d$table$value)))
})

test_that("bayesmeta deterministic diagnostics are explicitly verified without MCMC metrics", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  d <- apm_bayes_diagnostics(b,plot=FALSE)
  expect_true(d$diagnostics_verified)
  expect_true(d$interpretation_allowed)
  expect_false(d$severe_failure)
  expect_true(any(grepl("not defined", d$warnings, fixed=TRUE)))
})
