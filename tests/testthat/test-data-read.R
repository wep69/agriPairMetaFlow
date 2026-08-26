test_that("apm_read preserves rows and provenance", {
  f <- system.file("extdata","maize_n_shared.csv",package="agriPairMetaFlow")
  x <- apm_read(f)
  expect_s3_class(x,"apm_data"); expect_equal(nrow(x$data),nrow(maize_n_shared)); expect_true(nzchar(x$source_hash))
})
