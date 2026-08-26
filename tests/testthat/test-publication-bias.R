test_that("bias diagnostics keep methods separate", {
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_bias(fit, methods=c("egger","rank"))
  expect_s3_class(z, "apm_bias")
  expect_equal(sort(z$status$method), sort(c("egger","rank")))
  expect_true(all(c("applicable","message","backend") %in% names(z$status)))
})

test_that("PublicationBias adapter is conditional", {
  skip_if_not_installed("PublicationBias")
  fit <- apm_fit(agri_effects_benchmark)
  z <- apm_bias(fit, methods="svalue")
  expect_true("svalue" %in% names(z$results))
})
