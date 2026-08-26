test_that("uncertainty recovery uses closed-form identities", {
  d <- data.frame(mu=10,n=4,se=1,cv=20,mse=9)
  a <- apm_recover_uncertainty(d,mean=mu,n=n,se=se,method="se")
  expect_equal(a$data$.apm_sd,2,tolerance=1e-12)
  b <- apm_recover_uncertainty(d,mean=mu,n=n,cv=cv,method="cv")
  expect_equal(b$data$.apm_sd,2,tolerance=1e-12)
  c <- apm_recover_uncertainty(d,mean=mu,n=n,mse=mse,method="mse")
  expect_equal(c$data$.apm_sd,3,tolerance=1e-12)
})
