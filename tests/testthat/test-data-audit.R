test_that("shared controls are detected without deleting rows", {
  a <- apm_audit(maize_n_shared,"full")
  expect_true(any(a$issues$code=="shared_control")); expect_equal(nrow(a$data),nrow(maize_n_shared))
})
