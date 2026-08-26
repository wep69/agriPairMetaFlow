#' Draw standard or contour-enhanced funnel plots
#'
#' @param model An `apm_model`.
#' @param yaxis Vertical precision metric.
#' @param contour Draw contour-enhanced (tunnel-style) reference bands.
#' @param levels Two-sided confidence contour levels.
#' @param label Add study labels.
#' @param interactive Return plotly when installed.
#' @return A `ggplot` or optional `plotly` object with funnel data attached.
#' @export
#' @examples
#' # Example 1: standard funnel plot.
#' apm_funnel(apm_fit(agri_effects_benchmark))
#' # Example 2: contour-enhanced funnel plot.
#' apm_funnel(apm_fit(agri_effects_benchmark), contour=TRUE)
#' # Example 3: precision-axis interactive plot when plotly is available.
#' if (requireNamespace("plotly", quietly=TRUE)) apm_funnel(apm_fit(agri_effects_benchmark), yaxis="precision", interactive=TRUE)
apm_funnel <- function(model, yaxis = c("se", "vi", "precision", "n"), contour = FALSE, levels = c(0.90, 0.95, 0.99), label = FALSE, interactive = FALSE) {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an apm_model."); yaxis<-match.arg(yaxis); dat<-model$data; if(!all(c("yi","vi")%in%names(dat))) .apm_abort("Funnel plot requires yi and vi.")
  se<-sqrt(dat$vi); y<-switch(yaxis,se=se,vi=dat$vi,precision=1/se,n=if("n"%in%names(dat))dat$n else if(all(c("n_t","n_c")%in%names(dat)))dat$n_t+dat$n_c else .apm_abort("No sample-size field is available for yaxis='n'."))
  pd<-data.frame(effect=dat$yi,se=se,y=y,label=if("study_id"%in%names(dat))as.character(dat$study_id) else seq_len(nrow(dat)))
  p<-ggplot2::ggplot(pd,ggplot2::aes(x=effect,y=y))+ggplot2::geom_point()+ggplot2::geom_vline(xintercept=as.numeric(stats::coef(model$backend_fit)[1]),linetype=2)+ggplot2::theme_minimal()+ggplot2::labs(x=paste0("Effect (",model$measure,")"),y=yaxis,caption="Funnel asymmetry is not by itself evidence of publication bias.")
  if(yaxis%in%c("se","vi")) p<-p+ggplot2::scale_y_reverse()
  if(label) p<-p+ggplot2::geom_text(ggplot2::aes(label=label),check_overlap=TRUE,nudge_x=.02)
  if(contour){ if(any(levels<=0|levels>=1)) .apm_abort("Contour levels must lie strictly between 0 and 1."); mug<-as.numeric(stats::coef(model$backend_fit)[1]); gridse<-seq(min(se,na.rm=TRUE),max(se,na.rm=TRUE),length.out=100); cont<-do.call(rbind,lapply(levels,function(lv){ z<-stats::qnorm(1-(1-lv)/2); data.frame(level=factor(lv),se=gridse,lower=mug-z*gridse,upper=mug+z*gridse) })); if(yaxis=="se") { p<-p+ggplot2::geom_line(data=cont,ggplot2::aes(x=lower,y=se,group=level),inherit.aes=FALSE,linetype=3)+ggplot2::geom_line(data=cont,ggplot2::aes(x=upper,y=se,group=level),inherit.aes=FALSE,linetype=3) } else .apm_warn("Contour reference lines are currently drawn only when yaxis='se'.") }
  attr(p,"apm_plot_data")<-pd; if(interactive){.apm_require("plotly","interactive funnel plots");return(plotly::ggplotly(p))}; p
}


#' Draw a contour-enhanced funnel plot
#'
#' Convenience wrapper around [apm_funnel()] with contour bands enabled.
#'
#' @param model An `apm_model`.
#' @param levels Two-sided reference-contour confidence levels.
#' @param yaxis Precision axis; contour bands are defined on the SE scale.
#' @param label Label studies.
#' @param interactive Convert to plotly.
#' @return A contour-enhanced ggplot or plotly object.
#' @export
#' @examples
#' # Example 1: conventional 90/95/99 percent contours.
#' apm_funnel_contour(apm_fit(agri_effects_benchmark))
#' # Example 2: focus on the 95 percent reference contour.
#' apm_funnel_contour(apm_fit(agri_effects_benchmark), levels=.95)
#' # Example 3: label studies for a diagnostic review.
#' apm_funnel_contour(apm_fit(agri_effects_benchmark), label=TRUE)
apm_funnel_contour <- function(model, levels=c(.90,.95,.99), yaxis="se", label=FALSE, interactive=FALSE) {
  if(!identical(yaxis,"se")) .apm_warn("Contour boundaries are defined on the standard-error scale; non-SE axes are shown without contour curves.")
  apm_funnel(model,yaxis=yaxis,contour=TRUE,levels=levels,label=label,interactive=interactive)
}
