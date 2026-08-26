test_that("orchard plot shows pooled uncertainty", {
  fit <- apm_fit(agri_effects_benchmark)
  p <- apm_orchard(fit, transform="percent")
  expect_s3_class(p, "ggplot")
  expect_true(!is.null(attr(p,"apm_plot_data")))
})
