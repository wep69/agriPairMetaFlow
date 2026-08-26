test_that("prediction equals metafor predict", {
  m <- apm_fit(agri_effects_benchmark); a <- apm_prediction(m,transform="none")$raw; b <- predict(m$backend_fit)
  expect_equal(a$pred,as.numeric(b$pred),tolerance=1e-8); expect_equal(a$ci_lower,as.numeric(b$ci.lb),tolerance=1e-8); expect_equal(a$pi_lower,as.numeric(b$pi.lb),tolerance=1e-8)
})
