test_that("effect variance must be positive", {
  x <- agri_effects_benchmark; x$vi[1] <- -1
  v <- apm_validate(x,"effect",strict=FALSE)
  expect_false(v$ok); expect_true(any(v$issues$code=="nonpositive_vi"))
})
