test_that("MetaForest screening is explicitly exploratory", {
  skip_if_not_installed("metaforest")
  z <- apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop, seed=1, tune=FALSE)
  expect_s3_class(z, "apm_moderator_screen")
  expect_true(z$exploratory)
  expect_true(is.data.frame(z$importance))
})
