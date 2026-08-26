test_that("apm_bayes_compare blocks incompatible datasets", {
  a <- structure(list(measure="ROM",data_hash="a",backend="brms"),class="apm_bayes")
  b <- structure(list(measure="ROM",data_hash="b",backend="brms"),class="apm_bayes")
  expect_error(apm_bayes_compare(a,b,criterion="loo"),"same analysis dataset")
})

test_that("apm_bayes_compare blocks incompatible measures", {
  a <- structure(list(measure="ROM",data_hash="a",backend="brms"),class="apm_bayes")
  b <- structure(list(measure="SMD",data_hash="a",backend="brms"),class="apm_bayes")
  expect_error(apm_bayes_compare(a,b,criterion="loo"),"common effect measure")
})

test_that("apm_bayes_compare requires RoBMA for model-probability ensembles", {
  a <- structure(list(measure="ROM",data_hash="a",backend="bayesmeta",backend_fit=list()),class="apm_bayes")
  expect_error(apm_bayes_compare(a,criterion="model_probability"),"RoBMA")
})
