test_that("apm_bayes_threshold calculates posterior agronomic probability", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  x <- apm_bayes_threshold(b,5,scale="percent")
  expect_s3_class(x,"apm_bayes_threshold"); expect_true(x$probability>=0 && x$probability<=1)
})

test_that("apm_bayes_threshold predictive probability is explicit", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  x <- apm_bayes_threshold(b,10,scale="percent",predictive=TRUE)
  expect_true(x$predictive)
})

test_that("apm_bayes_threshold validates ROPE", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
  expect_error(apm_bayes_threshold(b,0,rope=1),"two finite")
})
