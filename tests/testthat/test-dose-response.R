test_that("apm_dose_response preserves shared-control covariance", {
  d <- fertilizer_dose_response
  a <- apm_dose_response(d,effect=lnRR,dose=N_rate,study=study_id,form="quadratic",method="fixed")
  V <- apm_vcov(d,cluster=study_id,shared_control=TRUE)
  expect_s3_class(a,"apm_dose")
  expect_equal(as.matrix(a$V),as.matrix(V),tolerance=1e-10)
  expect_equal(diag(a$V),d$vi,tolerance=1e-10)
  expect_equal(a$dose_info$reference,0)
  expect_true(a$settings$backend %in% c("dosresmeta","metafor-fixed-gls"))
})

test_that("explicit reference rows retain auditable original row provenance", {
  d <- fertilizer_dose_response
  refs <- do.call(rbind,lapply(split(d,d$study_id),function(z){
    r <- z[1,,drop=FALSE]
    r$N_rate <- 0
    r$lnRR <- 0
    r$vi <- 0
    r$sei <- 0
    r$treatment <- r$control
    r$treatment_id <- r$control_id
    r$dose_id <- paste0(r$study_id,"_D0")
    r$effect_id <- paste0(r$study_id,"_REF")
    r
  }))
  x <- rbind(refs,d)
  a <- apm_dose_response(x,effect=lnRR,dose=N_rate,study=study_id,form="linear",method="fixed")
  expect_equal(length(a$row_provenance$reference_rows),length(unique(d$study_id)))
  expect_equal(sort(a$row_provenance$reference_rows),seq_len(nrow(refs)))
  expect_equal(sort(a$row_provenance$analysis_rows),seq.int(nrow(refs)+1L,nrow(x)))
  expect_equal(nrow(a$data),nrow(d))
})

test_that("a generic yi column is not silently relabeled as lnRR", {
  d <- fertilizer_dose_response
  d$yi <- d$lnRR
  d$lnRR <- NULL
  d$measure <- NULL
  a <- apm_dose_response(d,effect=yi,dose=N_rate,study=study_id,form="linear",method="fixed")
  expect_identical(a$measure,"GEN")
})

test_that("each study must identify every dose-basis coefficient", {
  d <- fertilizer_dose_response[fertilizer_dose_response$N_rate %in% c(40,80),]
  expect_error(
    apm_dose_response(d,effect=lnRR,dose=N_rate,study=study_id,form="ns",df=3,method="fixed"),
    "identify all"
  )
})

test_that("random dose-response models do not use a random-intercept fallback", {
  if (requireNamespace("dosresmeta", quietly=TRUE)) skip("dosresmeta is installed; fallback guard is not applicable")
  expect_error(
    apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,study=study_id,form="linear",method="reml"),
    "requires optional package 'dosresmeta'"
  )
})

test_that("dosresmeta route agrees with a direct user-covariance fit", {
  skip_if_not_installed("dosresmeta")
  d <- fertilizer_dose_response
  a <- apm_dose_response(d,effect=lnRR,dose=N_rate,study=study_id,form="linear")
  expect_identical(a$settings$backend,"dosresmeta")
  dd <- a$data
  ids <- unique(dd$.apm_study)
  refrows <- lapply(ids,function(id){
    z <- dd[which(dd$.apm_study==id)[1],,drop=FALSE]
    z$.apm_y <- 0; z$.apm_vi <- 0; z$.apm_dose <- 0; z$.apm_d1 <- 0; z
  })
  aug <- do.call(rbind,lapply(ids,function(id) rbind(refrows[[match(id,ids)]],dd[dd$.apm_study==id,,drop=FALSE])))
  b <- dosresmeta::dosresmeta(.apm_y ~ .apm_d1,id=aug$.apm_study,v=aug$.apm_vi,
    data=aug,intercept=FALSE,center=FALSE,covariance="user",method="reml",Slist=a$Slist)
  expect_equal(unname(coef(a)),unname(coef(b)),tolerance=1e-8)
  expect_equal(unname(vcov(a)),unname(vcov(b)),tolerance=1e-8)
})
