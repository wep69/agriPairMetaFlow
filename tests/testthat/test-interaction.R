test_that("apm_interaction returns auditable simple effects and Wald test", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~rainfall*climate_zone,center=FALSE,test="z")
  a <- apm_interaction(m,"rainfall:climate_zone",at=list(rainfall=c(700,1000)))
  expect_s3_class(a,"apm_interaction")
  expect_true(nrow(a$table) >= 2)
  expect_true(all(is.finite(a$table$estimate)))
  expect_true(all(c("statistic","df1","df2","distribution","p_value") %in% names(a$joint_test)))
})
