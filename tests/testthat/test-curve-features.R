test_that("apm_curve_features returns derivative-based curve summaries", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  c1 <- apm_metareg_curve(es,rainfall,"quadratic")
  f <- apm_curve_features(c1,c("slope","turning_point"))
  expect_s3_class(f,"apm_curve_features")
  expect_true(nrow(f$slope) >= 200)
  expect_true(all(is.finite(f$slope$slope)))
  expect_match(f$caution,"not automatically causal")
})
