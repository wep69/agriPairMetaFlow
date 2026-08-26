test_that("variance components reproduce backend and proportions sum to one", {
  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  ml <- apm_multilevel(es,random=~1|study_id/effect_id,V=apm_vcov(es,cluster=experiment_id),test="z")
  a <- apm_variance_components(ml)
  expect_equal(a$table$variance,ml$backend_fit$sigma2,tolerance=1e-10)
  if(a$total_heterogeneity>0) expect_equal(sum(a$table$proportion),1,tolerance=1e-12)
})
