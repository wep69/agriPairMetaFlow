test_that("core S3 extractors delegate without refitting", {
  m <- apm_fit(agri_effects_benchmark); expect_equal(coef(m),coef(m$backend_fit)); expect_equal(vcov(m),vcov(m$backend_fit)); expect_s3_class(predict(m),"apm_prediction")
})
