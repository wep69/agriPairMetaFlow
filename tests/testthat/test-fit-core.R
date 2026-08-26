test_that("apm_fit matches rma.uni", {
  a <- apm_fit(agri_effects_benchmark)
  b <- metafor::rma.uni(yi,vi,data=agri_effects_benchmark,method="REML",test="z")
  expect_equal(coef(a),coef(b),tolerance=1e-8); expect_equal(a$backend_fit$tau2,b$tau2,tolerance=1e-8); expect_equal(a$backend_fit$QE,b$QE,tolerance=1e-8)
})
