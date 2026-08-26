test_that("comparison preserves model-based inference", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  fit <- apm_fit(es,mods=~rainfall)
  a <- apm_compare_inference(fit,methods="model",transform="none")
  expect_equal(a$table$estimate,as.numeric(coef(fit)),tolerance=1e-12)
  expect_equal(a$table$se,sqrt(diag(vcov(fit))),tolerance=1e-12)
})

test_that("incompatible robust objects are rejected", {
  skip_if_not_installed("clubSandwich")
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  fit <- apm_fit(es)
  cr <- apm_robust(fit,cluster=study_id)
  other <- apm_fit(agri_effects_benchmark)
  expect_error(apm_compare_inference(other,robust=cr))
})
