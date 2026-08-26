test_that("contour funnel is a ggplot", {
  fit <- apm_fit(agri_effects_benchmark)
  p <- apm_funnel_contour(fit)
  expect_s3_class(p, "ggplot")
  expect_true(!is.null(attr(p,"apm_plot_data")))
})
