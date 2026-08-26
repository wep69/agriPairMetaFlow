test_that("dependence audit does not equate diagonal V with independence", {
  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_dependence_audit(es,V=diag(es$vi),cluster=study_id)
  expect_s3_class(a,"apm_dependence_audit")
  expect_true(nrow(a$unresolved)>0)
  expect_true(a$V_diagonal)
})

test_that("non-diagonal V resolves registered dependency sources", {
  es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  V <- apm_vcov(es,cluster=experiment_id)
  a <- apm_dependence_audit(es,V=V,cluster=study_id)
  expect_false(any(a$unresolved$source %in% c("shared_control","repeated_outcome","repeated_time")))
  expect_true(any(a$unresolved$source == "repeated_cluster"))
})
