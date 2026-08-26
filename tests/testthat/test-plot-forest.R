test_that("forest plot is ggplot and retains input effects", {
  m <- apm_fit(agri_effects_benchmark); p <- apm_forest(m,transform="none"); expect_s3_class(p,"ggplot")
  pd <- attr(p,"apm_plot_data"); expect_equal(sort(pd$estimate),sort(m$data$yi),tolerance=1e-12)
})
