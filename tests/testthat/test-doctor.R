test_that("doctor performs non-mutating core inspection", {
  x <- apm_doctor(full=FALSE,check_backends=FALSE,check_render=FALSE,check_examples=FALSE)
  expect_s3_class(x,"apm_doctor")
  expect_false(x$mutated_environment)
  expect_true(all(c("check","status","scope","detail","remediation") %in% names(x$checks)))
  expect_true(any(x$checks$check=="R version"))
  expect_true(any(x$checks$status=="NOT RUN"))
})

test_that("doctor reports optional backends without making them core failures", {
  x <- apm_doctor(check_backends=TRUE,check_render=FALSE,check_examples=FALSE)
  opt <- x$checks[x$checks$scope=="optional-backend",,drop=FALSE]
  expect_gt(nrow(opt),0)
  expect_false(any(opt$status=="FAIL"))
})

test_that("full doctor records reproducibility environment", {
  x <- apm_doctor(full=TRUE,check_backends=FALSE,check_render=FALSE,check_examples=FALSE)
  expect_true(all(c("locale","platform","temporary directory") %in% x$checks$check))
})
