#' Draw a publication-quality forest plot
#'
#' @param model An `apm_model`.
#' @param data Optional metadata data frame; defaults to the fitted data.
#' @param slab Optional labels.
#' @param transform Effect-scale transformation.
#' @param sort Optional column name used for ordering.
#' @param subgroup Optional fitted-data column name or one grouping value per effect.
#' @param prediction Show pooled prediction interval.
#' @param columns Optional metadata columns retained in plot data.
#' @param interactive Return a plotly object when available.
#' @param theme Theme name; currently `"agri"` uses a clean ggplot theme.
#' @return A `ggplot` or optional `plotly` object with plot data attached.
#' @export
#' @examples
#' # Example 1: percent-change forest plot with crop metadata.
#' apm_forest(apm_fit(agri_effects_benchmark), transform="percent", columns=c("crop","dose"))
#' # Example 2: forest plot with soil-texture grouping metadata.
#' apm_forest(apm_fit(agri_effects_benchmark), subgroup="soil_texture", prediction=TRUE)
#' # Example 3: interactive forest plot when plotly is installed.
#' if (requireNamespace("plotly", quietly=TRUE)) apm_forest(apm_fit(agri_effects_benchmark), interactive=TRUE)
apm_forest <- function(model, data = NULL, slab = NULL, transform = c("auto", "none", "exp", "percent"), sort = NULL, subgroup = NULL, prediction = TRUE, columns = NULL, interactive = FALSE, theme = "agri") {
  if(!inherits(model,"apm_model")) .apm_abort("{.arg model} must be an apm_model."); transform<-match.arg(transform); dat<-data %||% model$data
  if(!all(c("yi","vi")%in%names(dat))) .apm_abort("Forest plot requires yi and vi in the fitted data.")
  lab<-if(is.null(slab)) if("study_id"%in%names(dat)) as.character(dat$study_id) else paste0("Effect ",seq_len(nrow(dat))) else as.character(slab)
  if(anyDuplicated(lab)) lab<-make.unique(lab,sep=" #")
  pd<-data.frame(label=lab,estimate=dat$yi,se=sqrt(dat$vi),ci_lower=dat$yi-stats::qnorm(.975)*sqrt(dat$vi),ci_upper=dat$yi+stats::qnorm(.975)*sqrt(dat$vi),stringsAsFactors=FALSE)
  if(!is.null(columns)){ miss<-setdiff(columns,names(dat)); if(length(miss)) .apm_abort("Unknown metadata column(s): {paste(miss,collapse=', ')}"); pd<-cbind(pd,dat[columns]) }
  has_sub<-!is.null(subgroup)&&length(subgroup)>0L
  if(has_sub) {
    if(length(subgroup)==1L&&is.character(subgroup)&&subgroup%in%names(dat)) pd$.subgroup<-dat[[subgroup]]
    else if(length(subgroup)==nrow(dat)) pd$.subgroup<-subgroup
    else .apm_abort("{.arg subgroup} must be one fitted-data column name or one value per effect ({nrow(dat)}).")
    pd$.subgroup<-factor(pd$.subgroup)
  }
  if(!is.null(sort)){ if(!sort%in%names(dat)) .apm_abort("Unknown sort column {.val {sort}}."); ord<-order(dat[[sort]],na.last=TRUE); pd<-pd[ord,,drop=FALSE] }
  for(nm in c("estimate","ci_lower","ci_upper")) pd[[nm]]<-.apm_transform_vector(pd[[nm]],model$measure,transform)
  pd$label<-factor(pd$label,levels=rev(unique(pd$label)))
  p<-ggplot2::ggplot(pd,ggplot2::aes(x=estimate,y=label))+ggplot2::geom_errorbarh(ggplot2::aes(xmin=ci_lower,xmax=ci_upper),height=.18)+ggplot2::geom_point()+ggplot2::theme_minimal()+ggplot2::labs(x=.apm_axis_label(model$measure,transform),y=NULL)
  pr<-apm_prediction(model,transform=transform); pooled<-pr$table[1,,drop=FALSE]
  p<-p+ggplot2::geom_vline(xintercept=pooled$pred,linetype=2)
  if(prediction && is.finite(pooled$pi_lower)&&is.finite(pooled$pi_upper)) p<-p+ggplot2::geom_vline(xintercept=c(pooled$pi_lower,pooled$pi_upper),linetype=3)
  attr(p,"apm_plot_data")<-pd
  if(interactive){ .apm_require("plotly","interactive forest plots"); return(plotly::ggplotly(p,tooltip=c("x","y"))) }
  p
}

.apm_axis_label <- function(measure, transform){ if(transform=="percent")"Effect (% change)" else if(transform=="exp" || (transform=="auto" && measure%in%.apm_log_measures))"Effect ratio" else paste0("Effect (",measure,")") }
