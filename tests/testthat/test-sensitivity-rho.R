test_that("rho sensitivity equals direct V plus fit at each rho", {
  x <- soil_management_multiresponse
  es <- apm_effect_size(x,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_rho_sensitivity(es,rho=c(.25,.5),build_vcov=list(cluster="study_id",type="outcome"))
  V <- apm_vcov(es,cluster=study_id,type=outcome,rho=.25,shared_control=FALSE)
  b <- apm_fit(es,V=V)
  expect_equal(unname(a$results$estimate[1]),unname(as.numeric(coef(b)[1])),tolerance=1e-8)
  expect_equal(unname(a$results$se[1]),unname(sqrt(diag(vcov(b)))[1]),tolerance=1e-8)
})
