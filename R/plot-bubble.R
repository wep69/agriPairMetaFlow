#' Draw a meta-regression bubble plot
#'
#' Uses observed effect sizes for points and model-derived marginal predictions
#' for the fitted relationship. Point size represents the declared weighting
#' rule rather than a plotting smoother.
#'
#' @param model An `apm_metareg` or `apm_curve` model.
#' @param x Quantitative fitted moderator.
#' @param size Point-size rule: model weight, inverse sampling variance, or equal.
#' @param transform Output transformation.
#' @param prediction Show prediction band when available.
#' @param interactive Return a plotly object.
#' @return A `ggplot` or `plotly` object.
#' @export
#' @examples
#' # Example 1: rainfall bubble plot on the percent-change scale.
#' irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
#'   n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' irr_m <- apm_metareg(irr_es,~rainfall)
#' apm_bubble(irr_m,rainfall,transform="percent")
#' # Example 2: soil organic matter as moderator with dependent maize effects.
#' mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
#'   m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' mz_V <- apm_vcov(mz_es,cluster=experiment_id)
#' mz_m <- apm_metareg(mz_es,~N_rate+soil_texture,V=mz_V,random=~1|study_id/effect_id)
#' apm_bubble(mz_m,N_rate,size="precision")
#' # Example 3: interactive rainfall curve when plotly is installed.
#' if(requireNamespace("plotly",quietly=TRUE)) apm_bubble(irr_m,rainfall,interactive=TRUE)
apm_bubble <- function(model, x, size = c("weight", "precision", "equal"), transform = c("auto", "none", "exp", "percent"), prediction = TRUE, interactive = FALSE) {
  if(!inherits(model,"apm_metareg")) .apm_abort("{.arg model} must inherit from apm_metareg.")
  size<-match.arg(size);transform<-match.arg(transform);qx<-rlang::enquo(x);xn<-.apm_name_quo(qx)
  source<-model$source_data%||%model$data
  if(!xn%in%names(source)) .apm_abort("Moderator {.field {xn}} is not present in the fitted source data.")
  xv<-.apm_pull_quo(source,qx,"x",TRUE);.apm_check_numeric(xv,"x")
  if(!inherits(model,"apm_curve")&&!xn%in%model$moderator_info$variables) .apm_abort("{.field {xn}} is not a fitted moderator in this meta-regression.")
  if(inherits(model,"apm_curve")&&xn!=model$curve_info$x_name) .apm_abort("An apm_curve bubble plot must use its fitted quantitative moderator.")
  ps<-switch(size,
    weight=tryCatch(as.numeric(stats::weights(model$backend_fit)),error=function(e)1/source$vi),
    precision=1/source$vi,
    equal=rep(1,nrow(source)))
  if(length(ps)!=nrow(source)||any(!is.finite(ps)))ps<-1/source$vi
  obs<-data.frame(x=xv,effect=.apm_transform_vector(source$yi,model$measure,transform),point_size=ps,study=if("study_id"%in%names(source))source$study_id else seq_len(nrow(source)))
  if(inherits(model,"apm_curve")) {
    raw<-model$prediction_grid;pd<-data.frame(x=raw[[model$curve_info$x_name]],pred=raw$pred,ci_lower=raw$ci_lower,ci_upper=raw$ci_upper,pi_lower=raw$pi_lower,pi_upper=raw$pi_upper)
    for(nm in c("pred","ci_lower","ci_upper","pi_lower","pi_upper"))pd[[nm]]<-.apm_transform_vector(pd[[nm]],model$measure,transform)
  } else {
    gx<-seq(min(xv),max(xv),length.out=100L);mg<-apm_marginal_effects(model,at=setNames(list(gx),xn),transform=transform)
    pd<-data.frame(x=mg$table[[xn]],pred=mg$table$pred,ci_lower=mg$table$ci_lower,ci_upper=mg$table$ci_upper,pi_lower=mg$table$pi_lower,pi_upper=mg$table$pi_upper)
  }
  p<-ggplot2::ggplot(obs,ggplot2::aes(x=x,y=effect,size=point_size))+ggplot2::geom_point(alpha=.65)+ggplot2::geom_ribbon(data=pd,ggplot2::aes(x=x,ymin=ci_lower,ymax=ci_upper),inherit.aes=FALSE,alpha=.18)+ggplot2::geom_line(data=pd,ggplot2::aes(x=x,y=pred),inherit.aes=FALSE)+ggplot2::theme_minimal()+ggplot2::labs(x=xn,y=.apm_axis_label(model$measure,transform),size=switch(size,weight="Model weight",precision="Precision (1/vi)",equal="Equal"))
  if(isTRUE(prediction)&&any(is.finite(pd$pi_lower))&&any(is.finite(pd$pi_upper)))p<-p+ggplot2::geom_ribbon(data=pd,ggplot2::aes(x=x,ymin=pi_lower,ymax=pi_upper),inherit.aes=FALSE,alpha=.08)
  attr(p,"apm_plot_data")<-list(observed=obs,prediction=pd,size_rule=size)
  if(isTRUE(interactive)){.apm_require("plotly","interactive meta-regression bubble plots");return(plotly::ggplotly(p,tooltip=c("x","y","size")))}
  p
}
