test_that("wild bootstrap records reproducibility metadata", {
  skip_if_not_installed("wildmeta"); skip_if_not_installed("clubSandwich")
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  fit <- apm_fit(es,mods=~rainfall)
  a <- apm_wild_bootstrap(fit,cluster=study_id,constraints=2,R=99,seed=42)
  expect_s3_class(a,"apm_wild")
  expect_equal(a$seed,42); expect_equal(a$R,99)
  expect_true(is.finite(a$mcse) || is.na(a$mcse))
})
