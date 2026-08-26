test_that("percent and ratio thresholds map exactly to log scale", {
  m <- apm_fit(agri_effects_benchmark)
  a <- apm_threshold(m,5,"percent"); b <- apm_threshold(m,1.05,"ratio")
  expect_equal(a$threshold_model,log(1.05),tolerance=1e-12); expect_equal(a$threshold_model,b$threshold_model,tolerance=1e-12)
})
