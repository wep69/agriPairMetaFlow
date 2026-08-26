# Orchard-style plots ----------------------------------------------------

#' Draw orchard-style summaries of agronomic meta-analysis
#'
#' @param model An `apm_model` or `apm_metareg`.
#' @param moderator Optional fitted categorical moderator.
#' @param transform Output transformation.
#' @param raw_effects Display observed effect sizes.
#' @param prediction Display prediction intervals when identified.
#' @param interactive Convert the ggplot to plotly.
#' @return A ggplot or plotly object with model-derived plot data attached.
#' @export
#' @examples
#' # Example 1: overall yield response on the percentage scale.
#' apm_orchard(apm_fit(agri_effects_benchmark), transform="percent")
#' # Example 2: raw-effect display can be disabled.
#' apm_orchard(apm_fit(agri_effects_benchmark), raw_effects=FALSE)
#' # Example 3: retain CIs while suppressing prediction intervals.
#' apm_orchard(apm_fit(agri_effects_benchmark), prediction=FALSE)
apm_orchard <- function(model, moderator = NULL,
                        transform = c("auto", "none", "exp", "percent"),
                        raw_effects = TRUE, prediction = TRUE, interactive = FALSE) {
  if (!inherits(model,"apm_model")) .apm_abort("{.arg model} must inherit from apm_model.")
  transform <- match.arg(transform); dat <- model$data
  if (is.null(moderator)) {
    pr <- stats::predict(model$backend_fit)
    raw <- data.frame(group="Overall",pred=as.numeric(pr$pred[1]),ci_lower=as.numeric(pr$ci.lb[1]),ci_upper=as.numeric(pr$ci.ub[1]),
      pi_lower=if(!is.null(pr$pi.lb))as.numeric(pr$pi.lb[1]) else NA_real_,pi_upper=if(!is.null(pr$pi.ub))as.numeric(pr$pi.ub[1]) else NA_real_,stringsAsFactors=FALSE)
    eff_group <- rep("Overall",nrow(dat))
  } else {
    if(!inherits(model,"apm_metareg")) .apm_abort("{.arg moderator} requires an apm_metareg object.")
    if(!moderator %in% model$moderator_info$variables) .apm_abort("Moderator {.field {moderator}} was not fitted in the model.")
    sup<-model$moderator_info$support[[moderator]]
    if(!identical(sup$type,"factor")) .apm_abort("apm_orchard() summarizes categorical moderators; use apm_metareg_curve() for quantitative moderators.")
    mg<-apm_marginal_effects(model,variables=moderator,transform="none")$raw
    raw<-data.frame(group=as.character(mg[[moderator]]),pred=mg$pred,ci_lower=mg$ci_lower,ci_upper=mg$ci_upper,pi_lower=mg$pi_lower,pi_upper=mg$pi_upper,stringsAsFactors=FALSE)
    eff_group<-as.character((model$source_data %||% dat)[[moderator]])
  }
  tab<-raw; for(nm in c("pred","ci_lower","ci_upper","pi_lower","pi_upper")) tab[[nm]]<-.apm_transform_vector(tab[[nm]],model$measure,transform)
  effects<-data.frame(group=eff_group,effect=.apm_transform_vector(dat$yi,model$measure,transform),stringsAsFactors=FALSE)
  p<-ggplot2::ggplot(tab,ggplot2::aes(y=group,x=pred))
  if(isTRUE(raw_effects)) p<-p+ggplot2::geom_jitter(data=effects,ggplot2::aes(y=group,x=effect),inherit.aes=FALSE,height=.10,alpha=.35)
  if(isTRUE(prediction) && any(is.finite(tab$pi_lower))) p<-p+ggplot2::geom_errorbarh(ggplot2::aes(xmin=pi_lower,xmax=pi_upper),height=.16,linewidth=1.2)
  p<-p+ggplot2::geom_errorbarh(ggplot2::aes(xmin=ci_lower,xmax=ci_upper),height=.08,linewidth=.7)+ggplot2::geom_point(size=2.6)+
    ggplot2::theme_minimal()+ggplot2::labs(x=paste0("Effect (",transform,")"),y=NULL,caption="Thin interval: confidence interval; wider interval: prediction interval when identifiable.")
  attr(p,"apm_plot_data")<-list(summary=tab,effects=effects)
  if(interactive){.apm_require("plotly","interactive orchard plots");return(plotly::ggplotly(p))};p
}
