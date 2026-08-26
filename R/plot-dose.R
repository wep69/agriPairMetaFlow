#' Plot an agronomic dose-response meta-analysis
#'
#' Draws the fitted dose-response curve together with observed effects, the
#' confidence band, an optional prediction band when estimable, and a rug that
#' makes the observed dose support explicit.
#'
#' @param model An `apm_dose` object.
#' @param transform Output transformation.
#' @param observed Show observed study-level effects.
#' @param prediction Show prediction interval when available.
#' @param rug Show observed dose support on the x axis.
#' @param interactive Return a plotly object.
#' @return A `ggplot` or `plotly` object with `apm_plot_data` attached.
#' @export
#' @examples
#' # Example 1: nitrogen response expressed as percent change.
#' d1 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'   study=study_id,form="linear",method="fixed")
#' apm_dose_plot(d1,transform="percent")
#' # Example 2: quadratic curve with the prediction band when identifiable.
#' d2 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'   study=study_id,form="quadratic",method="fixed")
#' apm_dose_plot(d2,prediction=TRUE)
#' # Example 3: interactive natural-spline display when plotly is available.
#' if(requireNamespace("plotly",quietly=TRUE)) {
#'   d3 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
#'     study=study_id,form="ns",df=3,method="fixed")
#'   apm_dose_plot(d3,interactive=TRUE)
#' }
apm_dose_plot <- function(model, transform = c("auto", "none", "exp", "percent"), observed = TRUE, prediction = TRUE, rug = TRUE, interactive = FALSE) {
  if(!inherits(model,"apm_dose")) .apm_abort("{.arg model} must be an apm_dose object.")
  transform<-match.arg(transform); pg<-model$prediction_grid
  if(is.null(pg)||!nrow(pg)) .apm_abort("This dose-response model does not carry a one-dimensional prediction grid. For models with study-level moderators, predict explicit contexts before plotting.")
  pd<-pg
  for(nm in c("pred","ci_lower","ci_upper","pi_lower","pi_upper"))pd[[nm]]<-.apm_transform_vector(pd[[nm]],model$measure,transform)
  obs<-data.frame(dose=model$data$.apm_dose,effect=.apm_transform_vector(model$data$.apm_y,model$measure,transform),vi=model$data$.apm_vi,study=model$data$.apm_study,stringsAsFactors=FALSE)
  p<-ggplot2::ggplot(pd,ggplot2::aes(x=dose,y=pred))+ggplot2::geom_ribbon(ggplot2::aes(ymin=ci_lower,ymax=ci_upper),alpha=.18)+ggplot2::geom_line()+ggplot2::theme_minimal()+ggplot2::labs(x=model$dose_info$dose_name,y=.apm_axis_label(model$measure,transform))
  if(isTRUE(prediction)&&any(is.finite(pd$pi_lower))&&any(is.finite(pd$pi_upper))) p<-p+ggplot2::geom_ribbon(ggplot2::aes(ymin=pi_lower,ymax=pi_upper),alpha=.08)
  if(isTRUE(observed)) p<-p+ggplot2::geom_point(data=obs,ggplot2::aes(x=dose,y=effect,size=1/vi),inherit.aes=FALSE,alpha=.65)+ggplot2::guides(size=ggplot2::guide_legend(title="Precision (1/vi)"))
  if(isTRUE(rug)) p<-p+ggplot2::geom_rug(data=obs,ggplot2::aes(x=dose),inherit.aes=FALSE,sides="b",alpha=.5)
  attr(p,"apm_plot_data")<-list(prediction=pd,observed=obs)
  if(isTRUE(interactive)){.apm_require("plotly","interactive dose-response plots");return(plotly::ggplotly(p,tooltip=c("x","y")))}
  p
}
