test_that("RDS export preserves the object", {
  fit <- apm_fit(agri_effects_benchmark)
  tf <- tempfile(fileext=".rds")
  out <- apm_export(fit, tf, format="rds", overwrite=TRUE)
  expect_true(file.exists(out))
  re <- readRDS(out)
  expect_s3_class(re,"apm_model")
})

test_that("CSV export is numeric preserving", {
  fit <- apm_fit(agri_effects_benchmark)
  tf <- tempfile(fileext=".csv")
  apm_export(fit, tf, format="csv", overwrite=TRUE)
  re <- utils::read.csv(tf)
  expect_true(is.numeric(re$estimate))
})
