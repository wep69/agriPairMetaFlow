test_that("apm_bayes_predict returns mean and predictive bayesmeta summaries", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  m <- apm_bayes_predict(b,predictive=FALSE,transform="none")
  p <- apm_bayes_predict(b,predictive=TRUE,transform="none")
  expect_s3_class(p,"apm_bayes_prediction")
  expect_true(all(c("q0.025","q0.5","q0.975") %in% names(p$table)))
  expect_true((p$raw$q0.975-p$raw$q0.025) >= (m$raw$q0.975-m$raw$q0.025))
})

test_that("apm_bayes_predict supports bmr contexts", {
  skip_if_not_installed("bayesmeta")
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); es$rainfall<-irrigation_climate$rainfall
  b <- apm_bayes(es,mods=~rainfall,backend="bayesmeta")
  p <- apm_bayes_predict(b,newdata=data.frame(rainfall=c(700,1000)),predictive=TRUE)
  expect_equal(nrow(p$table),2)
})

test_that("apm_bayes_predict validates probabilities", {
  b <- structure(list(),class="apm_bayes")
  expect_error(apm_bayes_predict(b,probs=c(0,.5,.95)),"strictly")
})
