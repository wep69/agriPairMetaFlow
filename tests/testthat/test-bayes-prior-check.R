test_that("apm_prior_check is reproducible with a seed", {
  p <- apm_prior(effect=list(dist="normal",mean=0,sd=.2),tau=list(dist="halfnormal",scale=.2))
  a <- apm_prior_check(p,"lnRR",draws=500,seed=123,plot=FALSE)
  b <- apm_prior_check(p,"lnRR",draws=500,seed=123,plot=FALSE)
  expect_equal(a$draws,b$draws)
})

test_that("apm_prior_check reports natural lnRR implications", {
  a <- apm_prior_check(apm_prior(effect=list(dist="normal",mean=0,sd=.2)),"lnRR",draws=500,seed=1,plot=FALSE)
  expect_true(all(c("model","ratio","percent") %in% names(a$transformed)))
})

test_that("apm_prior_check evaluates moderator contexts", {
  p <- apm_prior(moderators=list(rainfall=list(dist="normal",mean=0,sd=.0002)))
  a <- apm_prior_check(p,"lnRR",x=data.frame(rainfall=c(600,1200)),draws=500,seed=1,plot=FALSE)
  expect_equal(length(a$context_draws),2)
})
