test_that("apm_prior supplies inspectable defaults", {
  p <- apm_prior(); expect_s3_class(p,"apm_prior")
  expect_equal(p$effect$dist,"normal"); expect_equal(p$tau$dist,"halfnormal")
})

test_that("apm_prior validates agronomic coefficient priors", {
  p <- apm_prior(effect=list(dist="normal",mean=0,sd=.2), moderators=list(rainfall=list(dist="normal",mean=0,sd=.001)))
  expect_equal(names(p$moderators),"rainfall")
  expect_error(apm_prior(tau=list(dist="halfnormal",scale=-1)),"positive")
})

test_that("apm_prior stores model-probability declarations without normalizing silently", {
  p <- apm_prior(model_probability=list(effect=.5,heterogeneity=.5))
  expect_equal(unlist(p$model_probability),c(effect=.5,heterogeneity=.5))
})
