# Influence diagnostics --------------------------------------------------

.apm_capture_metafor_plot_data <- function(fun) {
  tf <- tempfile(fileext=".pdf")
  grDevices::pdf(tf)
  on.exit({try(grDevices::dev.off(), silent=TRUE); unlink(tf)}, add=TRUE)
  fun()
}

#' Diagnose influential effects or studies
#'
#' @param model An `apm_model` or subclass.
#' @param cluster Optional study/cluster vector or fitted-data column name.
#' @param unit Diagnose independent studies/clusters or individual effects.
#' @param metrics Requested influence metrics.
#' @param plot_type Influence, Baujat, or radial display.
#' @param plot Return a diagnostic ggplot.
#' @return An `apm_influence` object. No observation is removed automatically.
#' @export
#' @examples
#' # Example 1: Baujat diagnostic for independent agronomic studies.
#' apm_influence(apm_fit(agri_effects_benchmark), plot_type="baujat")
#' # Example 2: classical influence diagnostics.
#' apm_influence(apm_fit(agri_effects_benchmark), plot_type="influence")
#' # Example 3: radial diagnostic for the same fitted evidence base.
#' apm_influence(apm_fit(agri_effects_benchmark), metrics=c("cook","leverage"), plot_type="radial")
apm_influence <- function(model, cluster = NULL, unit = c("study", "effect"),
                          metrics = c("cook", "dfbetas", "leverage", "tau2_change"),
                          plot_type = c("influence", "baujat", "radial"), plot = TRUE) {
  .apm_require("metafor", "influence diagnostics")
  if (!inherits(model,"apm_model")) .apm_abort("{.arg model} must inherit from apm_model.")
  unit <- match.arg(unit); plot_type <- match.arg(plot_type)
  allowed <- c("cook","dfbetas","leverage","tau2_change")
  if (!length(metrics) || any(!metrics %in% allowed)) .apm_abort("{.arg metrics} contains unsupported diagnostics.")
  fit <- model$backend_fit; dat <- model$data
  cl <- if (unit=="study") .apm_resolve_cluster(model, cluster, required=TRUE) else NULL
  ids <- if (unit=="study") unique(as.character(cl)) else as.character(seq_len(nrow(dat)))
  diagnostics <- data.frame(unit=ids, stringsAsFactors=FALSE)
  source <- "metafor"
  dfb <- NULL

  if (inherits(fit,"rma.uni") && unit=="effect") {
    inf <- tryCatch(stats::influence(fit), error=function(e) metafor::influence(fit))
    idf <- as.data.frame(inf$inf)
    diagnostics <- cbind(unit=ids, idf, stringsAsFactors=FALSE)
    dfb <- tryCatch(as.data.frame(inf$dfbs), error=function(e) NULL)
  } else if (inherits(fit,"rma.mv")) {
    cook <- tryCatch(stats::cooks.distance(fit, cluster=cl), error=function(e) rep(NA_real_,length(ids)))
    dmat <- tryCatch(as.data.frame(stats::dfbetas(fit, cluster=cl)), error=function(e) NULL)
    lev0 <- tryCatch(stats::hatvalues(fit), error=function(e) rep(NA_real_,nrow(dat)))
    lev <- if(unit=="study") vapply(ids,function(g) sum(lev0[as.character(cl)==g],na.rm=TRUE),numeric(1)) else lev0
    diagnostics$cook <- as.numeric(cook); diagnostics$leverage <- as.numeric(lev); dfb <- dmat
  } else {
    loo <- apm_leave_one_out(model, unit="study", cluster=cl, transform="none")
    fullvar <- tryCatch(as.numeric(stats::vcov(fit)[1,1]), error=function(e) NA_real_)
    diagnostics$cook_proxy <- (loo$raw$estimate_change^2) / fullvar
    diagnostics$tau2_change <- loo$raw$heterogeneity_change
    lev0 <- tryCatch(stats::hatvalues(fit), error=function(e) rep(NA_real_,nrow(dat)))
    diagnostics$leverage <- vapply(ids,function(g) sum(lev0[as.character(cl)==g],na.rm=TRUE),numeric(1))
    source <- "cluster-refit-proxy"
  }

  if ("tau2_change" %in% metrics && !"tau2_change" %in% names(diagnostics)) {
    loo <- apm_leave_one_out(model, unit=unit, cluster=if(unit=="study")cl else NULL, transform="none")
    diagnostics$tau2_change <- loo$raw$heterogeneity_change
  }
  if (!is.null(dfb) && nrow(dfb)==nrow(diagnostics)) {
    names(dfb) <- paste0("dfbeta_", make.names(names(dfb)))
    diagnostics <- cbind(diagnostics, dfb)
  }

  pd <- diagnostics; p <- NULL
  if (isTRUE(plot)) {
    if (plot_type=="baujat") {
      if (!inherits(fit,"rma.uni") || unit!="effect") .apm_abort("Baujat plotting currently requires an rma.uni-backed effect-level model.")
      bd <- .apm_capture_metafor_plot_data(function() metafor::baujat(fit, symbol=19))
      pd <- as.data.frame(bd)
      p <- ggplot2::ggplot(pd, ggplot2::aes(x=x,y=y)) + ggplot2::geom_point() +
        ggplot2::theme_minimal() + ggplot2::labs(x="Contribution to heterogeneity", y="Influence on fitted value", caption="Baujat diagnostics identify influential patterns; they do not define exclusion rules.")
    } else if (plot_type=="radial") {
      if (!inherits(fit,"rma.uni") || unit!="effect") .apm_abort("Radial plotting currently requires an rma.uni-backed effect-level model.")
      rd <- .apm_capture_metafor_plot_data(function() metafor::radial(fit))
      pd <- as.data.frame(rd)
      p <- ggplot2::ggplot(pd, ggplot2::aes(x=x,y=y)) + ggplot2::geom_point() +
        ggplot2::geom_hline(yintercept=0,linetype=2) + ggplot2::theme_minimal() +
        ggplot2::labs(x="Precision coordinate", y="Standardized effect coordinate")
    } else {
      cooknm <- intersect(c("cook.d","cook","cook_proxy"),names(diagnostics))[1]
      levnm <- intersect(c("hat","leverage"),names(diagnostics))[1]
      if (is.na(cooknm) || is.na(levnm)) .apm_abort("Cook/leverage information is unavailable for this model.")
      pd$x <- diagnostics[[levnm]]; pd$y <- diagnostics[[cooknm]]
      p <- ggplot2::ggplot(pd,ggplot2::aes(x=x,y=y)) + ggplot2::geom_point() +
        ggplot2::theme_minimal() + ggplot2::labs(x="Leverage",y="Cook-type influence",caption="Use substantive judgment; diagnostic cutoffs are not automatic deletion rules.")
    }
  }
  out <- list(diagnostics=diagnostics, dfbetas=dfb, metrics=metrics, unit=unit,
    cluster=cl, plot_type=plot_type, plot=p, plot_data=pd, backend_source=source, source=source,
    model_hash=model$data_hash, caution="No observation is removed automatically by apm_influence().")
  class(out) <- "apm_influence"
  out
}
