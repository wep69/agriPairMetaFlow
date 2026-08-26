test_that("apm_multivariate_plot creates outcome forest", {
  skip_if_not_installed("metafor")
  d<-soil_management_multiresponse; if(!"yi"%in%names(d))d$yi<-d$lnRR
  m<-apm_multivariate(d,outcome=outcome,study=mv_study_id,V=diag(d$vi))
  p<-apm_multivariate_plot(m,type="outcome_forest")
  expect_s3_class(p,"ggplot")
})

test_that("apm_multivariate_plot creates correlation tiles when available", {
  skip_if_not_installed("metafor")
  d<-soil_management_multiresponse;if(!"yi"%in%names(d))d$yi<-d$lnRR
  m<-apm_multivariate(d,outcome=outcome,study=mv_study_id,V=diag(d$vi))
  if(!is.null(m$between_cor)) expect_s3_class(apm_multivariate_plot(m,"correlation"),"ggplot")
})

test_that("autoplot dispatches multivariate objects", {
  skip_if_not_installed("metafor")
  d<-biochar_multiresponse;d$yi<-d$lnRR
  m<-apm_multivariate(d,outcome=outcome,study=study_id,V=diag(d$vi))
  expect_s3_class(ggplot2::autoplot(m),"ggplot")
})
