test_that("table formatting preserves an unrounded source", {
  m <- apm_fit(agri_effects_benchmark); t <- apm_table(m,"model",digits=2,transform="none"); u <- attr(t,"apm_unrounded")
  expect_true(is.data.frame(t)); expect_equal(u$estimate,as.numeric(coef(m)),tolerance=1e-12)
})

test_that("apm_table supports 0.3 meta-regression and dose objects", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~rainfall,test="z")
  tm <- apm_table(m,component="metareg",transform="none")
  expect_true(all(c("term","estimate","se") %in% names(tm)))
  d <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="linear",method="fixed")
  td <- apm_table(d,component="dose",transform="none")
  expect_true(all(c("term","estimate","se") %in% names(td)))
})
