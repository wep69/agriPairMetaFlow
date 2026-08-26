test_that("paired design is not inferred from labels alone", {
  p <- apm_plan(maize_n_shared,study=study_id,treatment=treatment,control=control,response=mean_t)
  expect_equal(p$design,"independent")
  expect_error(apm_plan(maize_n_shared,study=study_id,treatment=treatment,control=control,response=mean_t,design="paired"),"pairing key")
})
