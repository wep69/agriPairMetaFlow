#' Create standardized analysis tables
#'
#' @param x agriPairMetaFlow object.
#' @param component Component to tabulate.
#' @param transform Output transformation.
#' @param digits Presentation rounding digits.
#' @param format `data.frame`, `gt`, or `flextable`.
#' @param ... Reserved formatting arguments.
#' @return A numeric-preserving data frame or an optional formatted table.
#' @export
#' @examples
#' # Example 1: effect-size table.
#' ee <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
#' apm_table(ee, component="effects")
#' # Example 2: pooled model table as percent change.
#' apm_table(apm_fit(agri_effects_benchmark), component="model", transform="percent")
#' # Example 3: heterogeneity table, optionally formatted with gt.
#' hh <- apm_heterogeneity(apm_fit(agri_effects_benchmark))
#' if (requireNamespace("gt", quietly=TRUE)) apm_table(hh, format="gt")
apm_table <- function(x, component = c("auto", "effects", "model", "heterogeneity", "metareg", "dose", "robust", "bayes", "sensitivity", "bias", "influence"), transform = c("auto", "none", "exp", "percent"), digits = 3, format = c("data.frame", "gt", "flextable"), ...) {
  component<-match.arg(component); transform<-match.arg(transform); format<-match.arg(format)
  if(component=="auto") component<-if(inherits(x,"apm_effects"))"effects" else if(inherits(x,"apm_dose"))"dose" else if(inherits(x,"apm_metareg"))"metareg" else if(inherits(x,"apm_heterogeneity"))"heterogeneity" else if(inherits(x,"apm_robust"))"robust" else if(inherits(x,"apm_bayes"))"bayes" else if(inherits(x,"apm_bias"))"bias" else if(inherits(x,"apm_influence"))"influence" else if(inherits(x,"apm_model"))"model" else .apm_abort("Could not infer table component from this object.")
  raw<-switch(component,
    effects={ if(!inherits(x,"apm_effects")&&!is.data.frame(x)) .apm_abort("effects component requires effect-size data."); d<-as.data.frame(x); keep<-intersect(c("study_id","experiment_id","crop","treatment","control","dose","yi","vi","sei"),names(d)); d[,keep,drop=FALSE]},
    model={ if(!inherits(x,"apm_model")) .apm_abort("model component requires apm_model."); cf<-stats::coef(x$backend_fit); se<-sqrt(diag(stats::vcov(x$backend_fit))); lo<-x$backend_fit$ci.lb %||% (as.numeric(cf)-stats::qnorm(.975)*se); hi<-x$backend_fit$ci.ub %||% (as.numeric(cf)+stats::qnorm(.975)*se); data.frame(term=names(cf),estimate=as.numeric(cf),se=se,ci_lower=as.numeric(lo),ci_upper=as.numeric(hi),stringsAsFactors=FALSE)},
    heterogeneity={ if(!inherits(x,"apm_heterogeneity")) .apm_abort("heterogeneity component requires apm_heterogeneity."); x$table},
    metareg={ if(!inherits(x,"apm_metareg")) .apm_abort("metareg component requires apm_metareg."); cf<-stats::coef(x$backend_fit); se<-sqrt(diag(stats::vcov(x$backend_fit))); lo<-x$backend_fit$ci.lb %||% (as.numeric(cf)-stats::qnorm(.975)*se); hi<-x$backend_fit$ci.ub %||% (as.numeric(cf)+stats::qnorm(.975)*se); data.frame(term=names(cf),estimate=as.numeric(cf),se=se,ci_lower=as.numeric(lo),ci_upper=as.numeric(hi),stringsAsFactors=FALSE)},
    dose={ if(!inherits(x,"apm_dose")) .apm_abort("dose component requires apm_dose."); cf<-x$coefficients; se<-sqrt(diag(x$vcov)); z<-stats::qnorm(.975); data.frame(term=names(cf),estimate=as.numeric(cf),se=se,ci_lower=as.numeric(cf)-z*se,ci_upper=as.numeric(cf)+z*se,stringsAsFactors=FALSE)},
    robust={ if(!inherits(x,"apm_robust")) .apm_abort("robust component requires apm_robust."); x$coefficients},
    bayes={ if(!inherits(x,"apm_bayes")) .apm_abort("bayes component requires apm_bayes."); x$posterior_summary},
    sensitivity={ if(inherits(x,"apm_inference_comparison")) x$table else if(inherits(x,"apm_sensitivity")) x$results else .apm_abort("sensitivity component requires apm_sensitivity or apm_inference_comparison.")},
    bias={ if(!inherits(x,"apm_bias")) .apm_abort("bias component requires apm_bias."); x$summary},
    influence={ if(!inherits(x,"apm_influence")) .apm_abort("influence component requires apm_influence."); x$diagnostics},
    .apm_abort("Unsupported table component {.val {component}}.")
  )
  measure<-if(inherits(x,"apm_model"))x$measure else if(inherits(x,"apm_effects"))attr(x,"measure") else "GEN"
  if(component%in%c("effects","model","metareg","dose","bayes")) for(nm in intersect(c("yi","estimate","ci_lower","ci_upper"),names(raw))) raw[[nm]]<-.apm_transform_vector(raw[[nm]],measure,transform)
  attr(raw,"apm_unrounded")<-raw; shown<-raw; num<-vapply(shown,is.numeric,logical(1)); shown[num]<-lapply(shown[num],round,digits=digits)
  if(format=="data.frame") return(shown)
  if(format=="gt"){.apm_require("gt","gt tables");return(gt::gt(shown))}
  .apm_require("flextable","flextable output"); flextable::flextable(shown)
}
