# GOSH diagnostics -------------------------------------------------------

#' Explore heterogeneity across model subsets with GOSH diagnostics
#'
#' @param model An `apm_model` or subclass.
#' @param subsets Number of random subsets when exhaustive enumeration is not used.
#' @param seed Reproducibility seed.
#' @param parallel Allow backend parallelization for supported univariate fits.
#' @param plot Return a ggplot summary.
#' @param cluster Optional cluster vector or fitted-data column name. When supplied,
#'   random subsets are sampled at cluster level and refitted natively.
#' @return An `apm_gosh` object containing subset results, inclusion information,
#'   seed and sampling provenance.
#' @export
#' @examples
#' # Example 1: lightweight pedagogical GOSH run.
#' apm_gosh(apm_fit(agri_effects_benchmark), subsets=100, seed=1, plot=FALSE)
#' # Example 2: visual subset exploration.
#' apm_gosh(apm_fit(agri_effects_benchmark), subsets=120, seed=2, plot=TRUE)
#' # Example 3: another reproducible subset sample.
#' apm_gosh(apm_fit(agri_effects_benchmark), subsets=80, seed=3, plot=FALSE)
apm_gosh <- function(model, subsets = 10000, seed = NULL, parallel = FALSE, plot = TRUE, cluster = NULL) {
  .apm_require("metafor", "GOSH diagnostics")
  if (!inherits(model,"apm_model")) .apm_abort("{.arg model} must inherit from apm_model.")
  if (!is.numeric(subsets) || length(subsets)!=1L || subsets < 1 || !is.finite(subsets)) .apm_abort("{.arg subsets} must be a positive integer.")
  subsets <- as.integer(subsets); fit <- model$backend_fit
  cl <- if(is.null(cluster)) NULL else .apm_resolve_cluster(model,cluster,required=TRUE)
  backend_object <- NULL; incl <- NULL

  if (is.null(cl) && inherits(fit,"rma.uni")) {
    backend_object <- .apm_seeded(seed, function() metafor::gosh(fit, subsets=subsets,
      progbar=FALSE, parallel=if(isTRUE(parallel)) if(.Platform$OS.type=="windows") "snow" else "multicore" else "no"))
    res <- as.data.frame(backend_object$res); incl <- backend_object$incl
    source <- "metafor::gosh"
  } else {
    if (is.null(cl)) cl <- .apm_resolve_cluster(model,NULL,required=TRUE)
    groups <- unique(as.character(cl)); ng <- length(groups)
    if (ng < 3L) .apm_abort("Cluster-respecting GOSH requires at least three independent clusters.")
    draw_one <- function(b) {
      m <- sample.int(ng-1L,1L)+1L
      chosen <- sample(groups,m,replace=FALSE)
      keep <- as.character(cl) %in% chosen
      ans <- tryCatch(.apm_fit_summary_row(.apm_refit_subset(model,keep),b,model$measure), error=function(e) .apm_failed_refit_row(b,e))
      ans$n_effects <- sum(keep); ans$n_clusters <- length(chosen); ans$included <- paste(sort(chosen),collapse="|")
      ans
    }
    rows <- .apm_seeded(seed,function() lapply(seq_len(subsets),draw_one))
    res <- do.call(rbind,rows); source <- "cluster-respecting-random-subsets"
  }
  p <- NULL
  if (isTRUE(plot)) {
    estnm <- intersect(c("estimate","intrcpt"),names(res))[1]
    hetnm <- intersect(c("tau2","I2","QE","heterogeneity_variance"),names(res))[1]
    if (is.na(estnm) || is.na(hetnm)) .apm_abort("GOSH result does not contain plottable effect/heterogeneity coordinates.")
    pd <- data.frame(estimate=res[[estnm]],heterogeneity=res[[hetnm]])
    p <- ggplot2::ggplot(pd,ggplot2::aes(x=estimate,y=heterogeneity)) + ggplot2::geom_point(alpha=.35) +
      ggplot2::theme_minimal() + ggplot2::labs(x="Subset estimate",y=hetnm,caption="Multimodality or clusters can signal heterogeneity structure; inspect study characteristics before drawing conclusions.")
  }
  out <- list(results=res,inclusion=incl,backend_object=backend_object,subsets=subsets,
    seed=seed,parallel=parallel,cluster=cl,sampling_design=source,plot=p,
    model_hash=model$data_hash,heavy=TRUE)
  class(out)<-"apm_gosh"; out
}
