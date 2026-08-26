test_that("apm_model_compare computes AICc from model likelihood quantities", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_metareg(es,~rainfall,center=FALSE,test="z")
  b <- apm_metareg(es,~rainfall+mean_temp,center=FALSE,test="z")
  cc <- apm_model_compare(a,b,criterion="AICc",refit_ml=TRUE)
  expect_s3_class(cc,"apm_model_comparison")
  expect_equal(sum(cc$table$weight),1,tolerance=1e-12)
  expect_true(all(cc$table$delta >= -1e-12))
  expect_true(cc$fixed_design_changed)
})

test_that("model comparison fingerprints the design matrix rather than coefficient labels", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  q <- stats::quantile(irrigation_climate$rainfall,c(.25,.50,.75),names=FALSE)
  a <- apm_metareg_curve(es,rainfall,"ns",df=3,knots=q[2])
  b <- apm_metareg_curve(es,rainfall,"ns",df=3,knots=q[1])
  expect_identical(names(coef(a)),names(coef(b)))
  cc <- apm_model_compare(a,b,criterion="AIC",refit_ml=TRUE)
  expect_true(cc$fixed_design_changed)
  expect_false(identical(unname(cc$design_hashes[1]),unname(cc$design_hashes[2])))
  expect_true(cc$refit_ml)
})

test_that("likelihood criteria refuse REML comparison when fixed designs differ and ML refit is disabled", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_metareg(es,~rainfall,center=FALSE,test="z")
  b <- apm_metareg(es,~rainfall+mean_temp,center=FALSE,test="z")
  expect_error(apm_model_compare(a,b,criterion="AIC",refit_ml=FALSE),"requires ML")
  expect_error(apm_model_compare(a,b,criterion="LRT",refit_ml=FALSE),"requires ML")
})

test_that("model comparison distinguishes absent and explicit random structures", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_metareg(es,~rainfall,test="z")
  b <- apm_metareg(es,~rainfall,random=~1|study_id,test="z")
  expect_error(apm_model_compare(a,b),"same random-effects structure")
})
