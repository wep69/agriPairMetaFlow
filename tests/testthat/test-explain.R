test_that("scientific explanation is deterministic and cautious", {
  fit <- apm_fit(agri_effects_benchmark)
  a <- apm_explain(fit, audience="scientific")
  b <- apm_explain(fit, audience="scientific")
  expect_identical(a,b)
  expect_true(is.character(a))
})
