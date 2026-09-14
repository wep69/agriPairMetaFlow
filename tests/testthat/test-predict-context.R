test_that("apm_predict_context matches metafor prediction for centered moderator", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~rainfall,center=TRUE,test="z")
  nd <- data.frame(rainfall=c(700,1000))
  a <- apm_predict_context(m,nd,transform="none")
  newmods <- matrix(nd$rainfall-mean(es$rainfall),ncol=1)
  b <- predict(m$backend_fit,newmods=newmods)
  expect_equal(a$raw$pred,as.numeric(b$pred),tolerance=1e-8)
  expect_equal(a$raw$ci_lower,as.numeric(b$ci.lb),tolerance=1e-8)
  expect_length(a$extrapolated,0)
})

test_that("predictive threshold probability is not guessed for multiple heterogeneity components", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~rainfall,center=TRUE,test="z")
  # Emulate an rma.mv-style fit exposing multiple identifiable heterogeneity
  # components while retaining a valid backend prediction object.
  m$backend_fit$sigma2 <- c(0.01,0.02)
  a <- apm_predict_context(m,data.frame(rainfall=800),threshold=0,transform="none",prediction=TRUE)
  expect_true(is.na(a$table$probability_above_threshold))
  expect_match(a$probability_basis,"multiple heterogeneity components")
})

test_that("threshold probability uses a normal approximation on the prediction distribution", {
  es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  m <- apm_metareg(es,~rainfall,center=TRUE,test="z")
  nd <- data.frame(rainfall=c(700,1000))
  a <- expect_no_warning(apm_predict_context(m,nd,threshold=0,transform="none",prediction=TRUE))
  pr <- a$raw
  sd_pred <- sqrt(pr$se^2 + m$backend_fit$tau2)
  expect_equal(a$table$probability_above_threshold,stats::pnorm((pr$pred-0)/sd_pred),tolerance=1e-10)
  expect_identical(a$probability_basis,"normal approximation on the prediction distribution")
})
