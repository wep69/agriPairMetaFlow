test_that("workflow auto-routing is auditable and equals manual shared-control fit", {
  wf <- apm_workflow(maize_n_shared, measure="lnRR", dependence="shared_control", model="multilevel")
  expect_s3_class(wf,"apm_workflow")
  expect_identical(wf$settings$dependence,"shared_control")
  expect_identical(wf$settings$model,"multilevel")
  expect_s3_class(wf$V,"apm_vcov")
  expect_true(all(c("step","decision","reason","source") %in% names(wf$routing_log)))

  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  V <- apm_vcov(es,cluster=experiment_id,shared_control=TRUE)
  manual <- apm_multilevel(es,random=~1|study_id/experiment_id/effect_id,V=V)
  expect_equal(unname(coef(wf$fit$backend_fit)),unname(coef(manual$backend_fit)),tolerance=1e-10)
})

test_that("workflow routes moderators and agronomic threshold without hiding choices", {
  wf <- apm_workflow(irrigation_climate,measure="lnRR",moderators=~rainfall+mean_temp,threshold=5)
  expect_s3_class(wf$fit,"apm_metareg")
  expect_s3_class(wf$diagnostics$threshold,"apm_threshold")
  expect_true(any(wf$routing_log$step=="moderators"))
  expect_true(any(wf$routing_log$step=="threshold"))
})

test_that("paired workflow requires explicit pairing information", {
  wf <- apm_workflow(wheat_paired_blocks,measure="lnRR",dependence="paired",model="random")
  expect_identical(attr(wf$effects,"design"),"paired")
  expect_identical(wf$settings$dependence,"paired")
  bad <- wheat_paired_blocks; bad$r_tc <- NULL
  expect_error(apm_workflow(bad,measure="lnRR",dependence="paired"),"paired")
})

test_that("robust workflow remains optional", {
  skip_if_not_installed("clubSandwich")
  wf <- apm_workflow(maize_n_shared,measure="lnRR",dependence="shared_control",model="multilevel",robust=TRUE)
  expect_s3_class(wf$sensitivities$robust,"apm_robust")
})
