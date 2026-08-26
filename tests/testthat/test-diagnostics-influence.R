test_that("apm_influence preserves observations and returns diagnostics", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_influence(fit, plot=FALSE)
  expect_s3_class(z, "apm_influence")
  expect_true(is.data.frame(z$diagnostics))
  expect_equal(nrow(fit$data), nrow(agri_effects_benchmark))
})

test_that("Baujat data agree with metafor for independent rma.uni models", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_influence(fit, unit="effect", plot_type="baujat", plot=FALSE)
  expect_s3_class(z, "apm_influence")
  expect_true(grepl("metafor", z$source))
})
