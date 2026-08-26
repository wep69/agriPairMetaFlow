test_that("subgroup estimates agree with explicit fits", {
  s <- apm_subgroup(agri_effects_benchmark,crop,test="z")
  g <- levels(factor(agri_effects_benchmark$crop))[1]
  d <- subset(agri_effects_benchmark,crop==g)
  b <- metafor::rma.uni(yi,vi,data=d,method="REML",test="z")
  expect_equal(s$subgroup_estimates$estimate[s$subgroup_estimates$subgroup==g],as.numeric(coef(b)),tolerance=1e-8)
})
