test_that("paired covariance has exact diagonal and compound correlations", {
  x <- wheat_paired_blocks[1:6,]
  es <- apm_effect_size(x,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
  # make two observations per dependency block to test off-diagonal covariance
  es$pair <- rep(1:3,each=2)
  a <- apm_pair_vcov(es,pair_id=pair,r=.6)
  expect_equal(diag(a),es$vi,tolerance=1e-12)
  expect_equal(a[1,2],.6*sqrt(es$vi[1]*es$vi[2]),tolerance=1e-12)
  expect_equal(a[1,3],0,tolerance=1e-12)
})

test_that("invalid paired correlations fail", {
  es <- agri_effects_benchmark[1:4,]
  expect_error(apm_pair_vcov(es,pair_id=study_id,r=1))
})
