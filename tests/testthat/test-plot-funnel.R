test_that("funnel plot data match yi and vi", {
  m <- apm_fit(agri_effects_benchmark); p <- apm_funnel(m); pd <- attr(p,"apm_plot_data"); expect_equal(pd$effect,m$data$yi); expect_equal(pd$se,sqrt(m$data$vi))
})
