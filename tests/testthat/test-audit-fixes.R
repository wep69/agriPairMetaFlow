test_that("seed arguments do not hijack the global RNG", {
  pr <- apm_prior(effect = list(dist = "normal", mean = 0, sd = .2),
                  tau = list(dist = "halfnormal", scale = .1))
  fs <- list(
    workflow    = function() apm_workflow(covercrop_variability, measure = "lnRR", seed = 1),
    prior_check = function() apm_prior_check(pr, measure = "lnRR", draws = 100, seed = 1, plot = FALSE))
  for (f in fs) {
    set.seed(123); antes <- .Random.seed
    invisible(suppressWarnings(f()))
    expect_identical(antes, .Random.seed)
    set.seed(7); a <- { suppressWarnings(f()); runif(3) }
    set.seed(9); b <- { suppressWarnings(f()); runif(3) }
    expect_false(isTRUE(all.equal(a, b)))
  }
})

test_that("apm_rho_sensitivity actually fits the grid", {
  ef <- apm_effect_size(maize_n_shared, measure = "lnRR", m_t = mean_t, sd_t = sd_t,
                        n_t = n_t, m_c = mean_c, sd_c = sd_c, n_c = n_c)
  rs <- apm_rho_sensitivity(ef, rho = c(0, 0.5),
    build_vcov = function(effects, rho)
      apm_vcov(effects, cluster = maize_n_shared$study_id, rho = rho))
  expect_equal(rs$n_fail, 0L)
  expect_true(all(rs$results$ok))
  expect_true(all(is.finite(rs$results$estimate)))
  expect_length(rs$V, 2L)
})

test_that("apm_moderator_screen works with its documented defaults", {
  skip_if_not_installed("metaforest")
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  expect_s3_class(apm_moderator_screen(ef, moderators = ~ dose + rainfall, cv = 3),
                  "apm_moderator_screen")
  expect_s3_class(apm_moderator_screen(ef, moderators = ~ dose + rainfall, cv = 3,
                                       cluster = agri_effects_benchmark$study_id),
                  "apm_moderator_screen")
})

test_that("fitted objects keep a re-evaluable call", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  for (m in list(apm_fit(ef), apm_metareg(ef, moderators = ~ dose))) {
    cl <- m$backend_fit$call
    expect_true(is.name(cl[[1]]) || is.call(cl[[1]]))
    expect_false(is.function(cl[[1]]))
  }
})

test_that("apm_wild_bootstrap runs end to end", {
  skip_if_not_installed("wildmeta")
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  mr <- apm_metareg(ef, moderators = ~ dose)
  w  <- apm_wild_bootstrap(mr, cluster = agri_effects_benchmark$study_id, R = 99, seed = 1)
  expect_s3_class(w, "apm_wild")
  expect_true(is.finite(w$p_value))
})

test_that("sparse covariance is usable downstream", {
  ef <- apm_effect_size(maize_n_shared, measure = "lnRR", m_t = mean_t, sd_t = sd_t,
                        n_t = n_t, m_c = mean_c, sd_c = sd_c, n_c = n_c)
  Vd <- apm_vcov(ef, cluster = maize_n_shared$study_id, rho = .5)
  Vs <- expect_no_warning(apm_vcov(ef, cluster = maize_n_shared$study_id,
                                   rho = .5, sparse = TRUE))
  expect_true(isS4(Vs))
  expect_false(is.null(attr(Vs, "apm_meta", exact = TRUE)))
  bare <- function(m) { attributes(m) <- attributes(m)[c("dim", "dimnames")]; unname(m) }
  expect_equal(bare(as.matrix(Vs)), bare(as.matrix(Vd)))
  expect_equal(coef(apm_fit(ef, V = Vs)), coef(apm_fit(ef, V = Vd)))
})

test_that("robust row of apm_compare_inference is complete", {
  skip_if_not_installed("clubSandwich")
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  m  <- apm_fit(ef)
  rb <- apm_robust(m, cluster = agri_effects_benchmark$study_id)
  tb <- apm_compare_inference(m, robust = rb, methods = c("model", "CR2"))$table
  r  <- tb[tb$method != "model", ]
  expect_true(all(is.finite(c(r$estimate, r$ci_lower, r$ci_upper))))
  expect_equal(r$estimate[1], unname(rb$coefficients$beta[1]))
})

test_that("apm_forest handles repeated slabs and subgroups", {
  ef <- apm_effect_size(maize_n_shared, measure = "lnRR", m_t = mean_t, sd_t = sd_t,
                        n_t = n_t, m_c = mean_c, sd_c = sd_c, n_c = n_c)
  expect_s3_class(apm_forest(apm_fit(ef)), "ggplot")
  ef2 <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  expect_s3_class(apm_forest(apm_fit(ef2), subgroup = agri_effects_benchmark$crop),
                  "ggplot")
})

test_that("baujat and radial are reachable from the defaults", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  m  <- apm_fit(ef)
  for (tp in c("baujat", "radial"))
    expect_s3_class(apm_influence(m, plot_type = tp)$plot, "ggplot")
})

test_that("default argument combinations are reachable", {
  ef  <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  cur <- apm_metareg_curve(ef, x = dose, form = "quadratic")
  expect_s3_class(apm_curve_features(cur), "apm_curve_features")
  mri <- apm_metareg(ef, moderators = ~ dose + crop)
  expect_s3_class(apm_marginal_effects(mri), "apm_marginal")
})

test_that("apm_predict_context returns the threshold probability", {
  ef  <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  mri <- apm_metareg(ef, moderators = ~ dose + crop)
  r <- expect_no_warning(
    apm_predict_context(mri, newdata = data.frame(dose = 150, crop = "maize"),
                        threshold = 0.05))
  expect_true(is.finite(r$probability_above_threshold[1]))
  expect_true(r$probability_above_threshold[1] >= 0 &&
              r$probability_above_threshold[1] <= 1)
})

test_that("refusal messages are emittable", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  pr <- apm_prior(effect = list(dist = "normal", mean = 0, sd = .3),
                  tau = list(dist = "halfnormal", scale = .2),
                  model_probability = 0.5)
  expect_error(apm_bayes(ef, prior = pr, backend = "bayesmeta"),
               regexp = "model probabilit")
})

test_that("apm_capabilities has a single class entry", {
  cl <- class(apm_capabilities())
  expect_equal(sum(cl == "apm_capabilities"), 1L)
})

test_that("tidy.apm_model exposes statistic and p.value", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  td <- generics::tidy(apm_fit(ef))
  expect_true(all(c("statistic", "p.value") %in% names(td)))
  expect_true(all(is.finite(td$statistic)))
})

test_that("confint.apm_model defaults to coefficients", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  ci <- confint(apm_fit(ef))
  expect_equal(nrow(ci), 1L)
  expect_true(all(is.finite(ci)))
})

test_that("as.data.frame works for apm_data", {
  f <- system.file("extdata", "agri_uncertainty_mixed.csv", package = "agriPairMetaFlow")
  d <- apm_read(f)
  expect_s3_class(d, "apm_data")
  expect_identical(as.data.frame(d), as.data.frame(d$data))
})

test_that("sparse subgroups warn without dropping levels", {
  ef <- apm_effect_size(agri_effects_benchmark, measure = "GEN", yi = yi, vi = vi)
  expect_warning(s <- apm_subgroup(ef, subgroup = crop, min_studies = 99L),
                 regexp = "Sparse subgroup")
  expect_equal(nrow(s$subgroup_estimates), nlevels(factor(agri_effects_benchmark$crop)))
})

test_that("multilevel fit does not leak the struct warning", {
  es <- apm_effect_size(maize_n_shared, "lnRR", m_t = mean_t, sd_t = sd_t,
                        n_t = n_t, m_c = mean_c, sd_c = sd_c, n_c = n_c)
  V <- apm_vcov(es, cluster = experiment_id)
  w <- NULL
  withCallingHandlers(
    apm_multilevel(es, random = ~ 1 | study_id / experiment_id, V = V),
    warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") })
  expect_false(any(grepl("struct", w)))
})

test_that("apm_prediction only supports the model method", {
  m <- apm_fit(agri_effects_benchmark, yi = yi, vi = vi)
  expect_error(apm_prediction(m, method = "HTS"))
  expect_s3_class(apm_prediction(m, method = "model"), "apm_prediction")
})

test_that("figure export honours height quietly", {
  p <- apm_forest(apm_fit(agri_effects_benchmark))
  png_dim <- function(path) {
    con <- file(path, "rb"); on.exit(close(con))
    hdr <- readBin(con, "raw", n = 33L)
    c(width = readBin(hdr[17:20], "integer", size = 4, endian = "big"),
      height = readBin(hdr[21:24], "integer", size = 4, endian = "big"))
  }
  f1 <- tempfile(fileext = ".png"); f2 <- tempfile(fileext = ".png")
  m <- NULL
  withCallingHandlers({
    apm_export(p, f1, format = "png", overwrite = TRUE)
    apm_export(p, f2, format = "png", height = 9, overwrite = TRUE)
  }, message = function(x) { m <<- c(m, conditionMessage(x)); invokeRestart("muffleMessage") })
  expect_false(any(grepl("translated", m)))
  d1 <- png_dim(f1); d2 <- png_dim(f2)
  expect_equal(unname(d1[["width"]]), unname(d2[["width"]]))
  expect_equal(unname(d2[["height"]]), 9 * 600)
  expect_true(unname(d2[["height"]]) > unname(d1[["height"]]))
})

test_that("bayesmeta PPC runs outside the standard library path", {
  skip_if_not_installed("bayesmeta")
  b <- apm_bayes(agri_effects_benchmark, backend = "bayesmeta")
  d <- apm_bayes_diagnostics(b, checks = "ppc", plot = FALSE)
  expect_true(is.null(d$ppc) || inherits(d$ppc, "htest"))
  expect_false(any(grepl("package.*not found|cluster", d$warnings, ignore.case = TRUE)))
})
