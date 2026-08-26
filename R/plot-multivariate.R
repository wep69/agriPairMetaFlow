# Multivariate visualization ----------------------------------------------

#' Plot a multivariate agronomic meta-analysis
#' @param model An `apm_multivariate` object.
#' @param type Outcome forest, between-outcome correlation, or prediction summary.
#' @param transform Output transformation.
#' @param interactive Convert to plotly when available.
#' @return A ggplot object or plotly widget.
#' @export
#' @examples
#' mv <- apm_multivariate(soil_management_multiresponse,outcome=outcome,study=mv_study_id,V=diag(soil_management_multiresponse$vi))
#' p1 <- apm_multivariate_plot(mv,type="outcome_forest",transform="percent")
#' p2 <- apm_multivariate_plot(mv,type="correlation")
#' p3 <- apm_multivariate_plot(mv,type="prediction",interactive=FALSE)
apm_multivariate_plot <- function(model, type = c("outcome_forest", "correlation", "prediction"),
                                  transform = c("auto", "none", "exp", "percent"), interactive = FALSE) {
  if(!inherits(model,"apm_multivariate")) .apm_abort("{.arg model} must be an apm_multivariate object.")
  type<-match.arg(type);transform<-match.arg(transform)
  if(type%in%c("outcome_forest","prediction")) {
    d<-model$outcome_estimates
    d$estimate_plot<-.apm_transform_vector(d$estimate,model$measure,transform)
    if (type == "prediction") {
      if (!all(c("pi_lower","pi_upper") %in% names(d)) || any(!is.finite(d$pi_lower) | !is.finite(d$pi_upper)))
        .apm_abort("Outcome-specific prediction intervals are not identified for this multivariate fit. Use type='outcome_forest' or inspect the fitted covariance structure.")
      d$lower_plot<-.apm_transform_vector(d$pi_lower,model$measure,transform)
      d$upper_plot<-.apm_transform_vector(d$pi_upper,model$measure,transform)
      ttl <- "Outcome-specific between-study prediction intervals"
    } else {
      d$lower_plot<-.apm_transform_vector(d$ci_lower,model$measure,transform)
      d$upper_plot<-.apm_transform_vector(d$ci_upper,model$measure,transform)
      ttl <- "Outcome-specific pooled effects"
    }
    g<-ggplot2::ggplot(d,ggplot2::aes(y=.data$outcome,x=.data$estimate_plot,xmin=.data$lower_plot,xmax=.data$upper_plot)) + ggplot2::geom_vline(xintercept=if(transform%in%c("exp","auto")&&model$measure%in%.apm_log_measures)1 else 0,lty=2) + ggplot2::geom_errorbarh(height=.15) + ggplot2::geom_point() + ggplot2::labs(x=if(transform=="percent")"Treatment effect (%)" else "Treatment effect",y=NULL,title=ttl)
    attr(g,"apm_plot_data")<-d
  } else {
    if(is.null(model$between_cor)) .apm_abort("No estimable between-outcome correlation matrix is available for this model.")
    C<-model$between_cor; rn<-rownames(C)%||%model$outcomes;cn<-colnames(C)%||%model$outcomes
    d<-expand.grid(outcome1=rn,outcome2=cn,stringsAsFactors=FALSE);d$correlation<-as.vector(C)
    g<-ggplot2::ggplot(d,ggplot2::aes(x=.data$outcome1,y=.data$outcome2,fill=.data$correlation)) + ggplot2::geom_tile() + ggplot2::geom_text(ggplot2::aes(label=round(.data$correlation,2))) + ggplot2::labs(x=NULL,y=NULL,title="Between-outcome heterogeneity correlation")
    attr(g,"apm_plot_data")<-d
  }
  if(isTRUE(interactive)) { .apm_require("plotly","interactive multivariate plots"); return(plotly::ggplotly(g)) }
  g
}
