test_that("report payload does not refit the model", {
  skip_if_not_installed("rmarkdown")
  fit <- apm_fit(agri_effects_benchmark)
  before <- fit$data_hash
  tf <- tempfile(fileext=".html")
  z <- apm_report(fit, tf, format="html", sections=c("model","prediction"))
  expect_s3_class(z, "apm_report")
  expect_identical(fit$data_hash, before)
  expect_true(file.exists(z$file))
})
