test_that("lnRR equals metafor ROM", {
  x <- maize_n_shared[1:4,]
  a <- apm_effect_size(x,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
  b <- metafor::escalc(measure="ROM",m1i=x$mean_t,sd1i=x$sd_t,n1i=x$n_t,m2i=x$mean_c,sd2i=x$sd_c,n2i=x$n_c,correct=TRUE,vtype="LS")
  expect_equal(a$yi,b$yi,tolerance=1e-10); expect_equal(a$vi,b$vi,tolerance=1e-10)
})

test_that("paired lnRR equals ROMC", {
  x <- wheat_paired_blocks[1:4,]
  a <- apm_effect_size(x,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
  b <- metafor::escalc(measure="ROMC",m1i=x$mean_t,sd1i=x$sd_t,m2i=x$mean_c,sd2i=x$sd_c,ri=x$r_tc,ni=x$n_pairs,correct=TRUE,vtype="LS")
  expect_equal(a$yi,b$yi,tolerance=1e-10); expect_equal(a$vi,b$vi,tolerance=1e-10)
})
