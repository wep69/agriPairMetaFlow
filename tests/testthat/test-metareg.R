test_that("apm_metareg matches direct metafor meta-regression", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_metareg(es,~rainfall+mean_temp,center=FALSE,test="z")
  b <- metafor::rma.uni(yi=es$yi,vi=es$vi,mods=~rainfall+mean_temp,data=es,method="REML",test="z")
  expect_equal(coef(a),coef(b),tolerance=1e-8)
  expect_equal(vcov(a),vcov(b),tolerance=1e-8)
  expect_equal(a$heterogeneity$QE,b$QE,tolerance=1e-8)
  expect_equal(a$joint_test$QM,b$QM,tolerance=1e-8)
})

test_that("multilevel meta-regression rejects univariate-only inference labels", {
  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  V <- apm_vcov(es,cluster=experiment_id)
  expect_error(apm_metareg(es,~N_rate,V=V,random=~1|study_id/effect_id,test="knha"),"test='z' or test='t'")
  expect_error(apm_metareg(es,~N_rate,V=V,random=~1|study_id/effect_id,test="hksj"),"test='z' or test='t'")
})
