test_that("quadratic apm_metareg_curve matches direct metafor basis", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  a <- apm_metareg_curve(es,rainfall,form="quadratic")
  cc <- mean(es$rainfall); z <- es$rainfall-cc
  b <- metafor::rma.uni(yi=es$yi,vi=es$vi,mods=~z+I(z^2),method="REML")
  expect_equal(as.numeric(coef(a)),as.numeric(coef(b)),tolerance=1e-8)
  expect_equal(a$curve_info$center,cc,tolerance=1e-12)
  expect_equal(nrow(a$prediction_grid),100)
})
