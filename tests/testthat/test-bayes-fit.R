test_that("apm_bayes bayesmeta intercept agrees with direct backend", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  expect_s3_class(b,"apm_bayes"); expect_equal(b$backend,"bayesmeta")
  expect_true(inherits(b$backend_fit,"bayesmeta"))
})

test_that("apm_bayes uses bmr for moderators", {
  skip_if_not_installed("bayesmeta")
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  es$rainfall <- irrigation_climate$rainfall
  b <- apm_bayes(es,mods=~rainfall,backend="bayesmeta")
  expect_true(inherits(b$backend_fit,"bmr"))
})

test_that("bayesmeta backend refuses clustered dependence", {
  skip_if_not_installed("bayesmeta")
  expect_error(apm_bayes(agri_effects_benchmark,cluster=study_id,backend="bayesmeta"),"does not represent")
})
