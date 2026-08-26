test_that("apm_marginal_effects equals manual standardized prediction", {
  es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~crop+site,test="z")
  z <- apm_marginal_effects(m,variables="crop",transform="none")
  expect_s3_class(z,"apm_marginal")
  expect_equal(sort(unique(as.character(z$table$crop))),sort(unique(es$crop)))
  expect_true(all(z$table$ci_lower <= z$table$pred & z$table$pred <= z$table$ci_upper))
  expect_equal(length(unique(z$table$crop)),nrow(z$table))
})
