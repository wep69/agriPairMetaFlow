test_that("capability registry is deterministic and exposes core/optional status", {
  x <- apm_capabilities(installed=FALSE,detail="full")
  expect_s3_class(x,"apm_capabilities")
  expect_true(all(c("feature","backend","package","core","validation_tier","status") %in% names(x)))
  expect_true(any(x$feature=="effect-sizes" & x$core))
  expect_true(any(x$feature=="bayesian" & !x$core))
  expect_true(all(is.na(x$installed)))
})

test_that("capability filtering does not silently partially match", {
  x <- apm_capabilities("dose-response",installed=FALSE,detail="full")
  expect_equal(unique(x$feature),"dose-response")
  expect_error(apm_capabilities("dose",installed=FALSE),"Unknown capability")
})

test_that("installed core metafor capability respects declared version policy", {
  x <- apm_capabilities("effect-sizes",installed=TRUE,detail="full")
  expect_true(x$installed)
  expect_true(x$version_ok)
  expect_identical(x$status,"AVAILABLE")
})
