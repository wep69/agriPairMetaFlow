test_that("GOSH records reproducibility metadata", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_gosh(fit, subsets=50, seed=42, plot=FALSE)
  expect_s3_class(z, "apm_gosh")
  expect_identical(z$seed, 42)
  expect_true(is.data.frame(z$results))
})
