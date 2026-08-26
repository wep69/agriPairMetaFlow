test_that("apm_multilevel matches metafor rma.mv", {
  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  V <- apm_vcov(es,cluster=experiment_id)
  a <- apm_multilevel(es,random=~1|study_id/effect_id,V=V,test="z")
  b <- metafor::rma.mv(yi=es$yi,V=as.matrix(V),random=~1|study_id/effect_id,data=es,method="REML",test="z",dfs="contain")
  expect_equal(coef(a),coef(b),tolerance=1e-8)
  expect_equal(a$backend_fit$sigma2,b$sigma2,tolerance=1e-8)
  expect_equal(as.numeric(logLik(a$backend_fit)),as.numeric(logLik(b)),tolerance=1e-8)
})
