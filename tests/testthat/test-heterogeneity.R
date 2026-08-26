test_that("heterogeneity fields match metafor", {
  a <- apm_heterogeneity(apm_fit(agri_effects_benchmark),ci=FALSE)$table
  b <- metafor::rma.uni(yi,vi,data=agri_effects_benchmark)
  expect_equal(a$tau2,b$tau2,tolerance=1e-8); expect_equal(a$I2,b$I2,tolerance=1e-8); expect_equal(a$H2,b$H2,tolerance=1e-8); expect_equal(a$Q,b$QE,tolerance=1e-8)
})
