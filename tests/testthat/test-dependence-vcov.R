test_that("apm_vcov matches metafor vcalc for shared controls", {
  x <- maize_n_shared[1:6,]
  es <- apm_effect_size(x,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_vcov(es,cluster=experiment_id,shared_control=TRUE)
  b <- metafor::vcalc(vi=es$vi,cluster=es$experiment_id,grp1=es$treatment,grp2=es$control,w1=es$n_t,w2=es$n_c)
  expect_equal(as.matrix(a),as.matrix(b),tolerance=1e-10)
  expect_equal(diag(a),es$vi,tolerance=1e-10)
  expect_equal(a,t(a),tolerance=1e-12)
})

test_that("correlation assumptions are recorded", {
  x <- soil_management_multiresponse
  es <- apm_effect_size(x,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_vcov(es,cluster=study_id,type=outcome,rho=.5,shared_control=FALSE)
  expect_equal(attr(a,"apm_meta")$rho,.5)
})
