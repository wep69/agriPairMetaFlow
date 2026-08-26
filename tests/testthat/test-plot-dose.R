test_that("apm_dose_plot uses model-stored predictions", {
  d <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="linear",method="fixed")
  p <- apm_dose_plot(d,transform="none")
  expect_s3_class(p,"ggplot")
  pd <- attr(p,"apm_plot_data")
  expect_equal(pd$prediction$pred,d$prediction_grid$pred,tolerance=1e-12)
  expect_equal(nrow(pd$observed),nrow(fertilizer_dose_response))
})
