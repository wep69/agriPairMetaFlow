test_that("shared controls are detected exactly", {
  a <- apm_shared_control(maize_n_shared, study=experiment_id, control_id=control, treatment_id=treatment)
  expect_s3_class(a,"apm_shared_control")
  expect_equal(a$summary$n_shared_control_groups,8)
  expect_equal(a$summary$max_multiplicity,3)
  expect_equal(a$summary$n_conflicts,0)
})

test_that("conflicting duplicated control summaries are flagged", {
  x <- maize_n_shared[1:3,]; x$mean_c[2] <- x$mean_c[2] + .2
  a <- apm_shared_control(x,study=experiment_id,control_id=control)
  expect_gt(a$summary$n_conflicts,0)
})
