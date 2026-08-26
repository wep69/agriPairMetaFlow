test_that("study leave-one-out returns one row per independent study", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_leave_one_out(fit, unit="study")
  expect_s3_class(z, "apm_sensitivity")
  expect_equal(nrow(z$results), length(unique(fit$data$study_id)))
})

test_that("independent leave-one-effect agrees with metafor leave1out", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_leave_one_out(fit, unit="effect")
  ref <- metafor::leave1out(fit$backend_fit)
  expect_equal(z$results$estimate, as.numeric(ref$estimate), tolerance=1e-8)
})
