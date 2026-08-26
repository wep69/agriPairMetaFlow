# Small-study effects and publication-bias sensitivity ------------------

.apm_bias_applicable_univariate <- function(model, method) {
  fit <- model$backend_fit
  ok <- inherits(fit,"rma.uni")
  if (method %in% c("rank","trimfill") && length(stats::coef(fit)) != 1L) ok <- FALSE
  ok
}

#' Diagnose small-study effects and publication-bias sensitivity
#'
#' Runs prespecified diagnostic and sensitivity methods while keeping their
#' assumptions separate. Funnel asymmetry is never labeled as proof of
#' publication bias, and corrected estimates are not automatically preferred.
#'
#' @param model An `apm_model`.
#' @param methods One or more methods: `egger`, `rank`, `trimfill`, `selection`,
#'   `svalue`, `selection_ratio`, `copas`, or `limit`.
#' @param favor Direction assumed to be favored by selective publication.
#' @param q Target effect for S-value sensitivity, on the fitted model scale.
#' @param selection_ratio Optional publication-probability ratio for
#'   `PublicationBias::pubbias_meta()`.
#' @param robust Use robust clustered PublicationBias calculations when possible.
#' @param ... Additional method-specific arguments.
#' @return An `apm_bias` object with method-specific results, applicability,
#'   assumptions, failures and a compact cross-method summary.
#' @export
#' @examples
#' # Example 1: funnel-asymmetry diagnostics.
#' apm_bias(apm_fit(agri_effects_benchmark), methods=c("egger","rank"))
#' # Example 2: two sensitivity models, without treating either as truth.
#' apm_bias(apm_fit(agri_effects_benchmark), methods=c("trimfill","selection"))
#' # Example 3: S-value when PublicationBias is installed.
#' if (requireNamespace("PublicationBias",quietly=TRUE)) apm_bias(apm_fit(agri_effects_benchmark), methods="svalue", q=0, favor="positive")
apm_bias <- function(model, methods = c("egger", "rank", "trimfill", "selection", "svalue"),
                     favor = c("positive", "negative"), q = 0, selection_ratio = NULL,
                     robust = FALSE, ...) {
  .apm_require("metafor", "small-study-effect diagnostics")
  if (!inherits(model,"apm_model")) .apm_abort("{.arg model} must inherit from apm_model.")
  favor <- match.arg(favor); methods <- unique(tolower(as.character(methods)))
  allowed <- c("egger","rank","trimfill","selection","svalue","selection_ratio","copas","limit")
  bad <- setdiff(methods,allowed); if(length(bad)) .apm_abort("Unsupported bias method(s): {paste(bad,collapse=', ')}")
  fit <- model$backend_fit; dat <- model$data
  if (!all(c("yi","vi") %in% names(dat))) .apm_abort("Bias diagnostics require fitted yi and vi values.")
  results <- list(); status <- vector("list",length(methods)); names(status)<-methods
  add_status <- function(m,ok,msg,backend) data.frame(method=m,applicable=ok,message=msg,backend=backend,stringsAsFactors=FALSE)

  for (m in methods) {
    val <- tryCatch({
      if (m=="egger") {
        z <- metafor::regtest(fit, model="rma", predictor="sei")
        list(result=z, status=add_status(m,TRUE,"Regression test for funnel asymmetry; asymmetry has multiple possible causes.","metafor::regtest"))
      } else if (m=="rank") {
        if(!.apm_bias_applicable_univariate(model,m)) stop("Rank test requires an univariate model without moderators.")
        z <- metafor::ranktest(fit)
        list(result=z, status=add_status(m,TRUE,"Rank correlation is an asymmetry diagnostic, not a publication-bias diagnosis.","metafor::ranktest"))
      } else if (m=="trimfill") {
        if(!.apm_bias_applicable_univariate(model,m)) stop("Trim-and-fill requires an rma.uni model without moderators.")
        side <- if(favor=="positive") "left" else "right"
        z <- metafor::trimfill(fit,side=side)
        list(result=z, status=add_status(m,TRUE,"Trim-and-fill is a sensitivity analysis under a specific missingness mechanism, not a corrected truth.","metafor::trimfill"))
      } else if (m=="selection") {
        if(!inherits(fit,"rma.uni")) stop("Selection models currently require an rma.uni backend fit.")
        z <- metafor::selmodel(fit,type="stepfun",steps=c(.025,.10,.50),alternative=if(favor=="positive")"greater" else "less")
        list(result=z, status=add_status(m,TRUE,"Step-function selection model; interpret relative to its explicit selection assumptions.","metafor::selmodel"))
      } else if (m %in% c("svalue","selection_ratio")) {
        .apm_require("PublicationBias",paste0(m," publication-bias sensitivity"))
        cl <- if ("study_id" %in% names(dat)) dat$study_id else seq_len(nrow(dat))
        mtype <- if(isTRUE(robust)) "robust" else "fixed"
        if (m=="svalue") z <- PublicationBias::pubbias_svalue(yi=dat$yi,vi=dat$vi,cluster=cl,q=q,model_type=mtype,favor_positive=favor=="positive",small=TRUE)
        else {
          if(is.null(selection_ratio)||!is.numeric(selection_ratio)||length(selection_ratio)!=1L||selection_ratio<1) stop("selection_ratio must be a scalar >= 1.")
          z <- PublicationBias::pubbias_meta(yi=dat$yi,vi=dat$vi,cluster=cl,selection_ratio=selection_ratio,model_type=mtype,favor_positive=favor=="positive",small=TRUE)
        }
        list(result=z, status=add_status(m,TRUE,"Sensitivity to an explicitly specified selective-publication mechanism.",paste0("PublicationBias::pubbias_",if(m=="svalue")"svalue" else "meta")))
      } else {
        .apm_require("meta",paste0(m," adapter")); .apm_require("metasens",paste0(m," adapter"))
        mm <- meta::metagen(TE=dat$yi,seTE=sqrt(dat$vi),studlab=if("study_id"%in%names(dat))dat$study_id else seq_len(nrow(dat)),common=FALSE,random=TRUE,method.tau=model$settings$method %||% "REML")
        z <- if(m=="copas") metasens::copas(mm) else metasens::limitmeta(mm)
        list(result=z, status=add_status(m,TRUE,"Sensitivity model from metasens; compare assumptions and estimates rather than selecting by significance.",paste0("metasens::",if(m=="copas")"copas" else "limitmeta")))
      }
    }, error=function(e) list(result=e, status=add_status(m,FALSE,conditionMessage(e),NA_character_)))
    results[[m]] <- val$result
    status[[m]] <- val$status
  }
  status_df <- do.call(rbind,status)
  summary_rows <- lapply(methods,function(m){
    z<-results[[m]]
    if(inherits(z,"error")) return(data.frame(method=m,estimate=NA_real_,p_value=NA_real_,note=conditionMessage(z)))
    est <- if(m=="trimfill") as.numeric(stats::coef(z)[1]) else if(m=="selection") as.numeric(stats::coef(z)[1]) else if(m=="egger") z$zval %||% z$tval %||% NA_real_ else if(m=="rank") z$tau %||% NA_real_ else if(m %in% c("svalue","selection_ratio")) {
      st<-z$stats; if(is.data.frame(st)&&"estimate"%in%names(st)) as.numeric(st$estimate[1]) else if(is.data.frame(st)&&"sval_est"%in%names(st)) as.numeric(st$sval_est[1]) else NA_real_
    } else NA_real_
    pv <- if(m=="egger") z$pval %||% NA_real_ else if(m=="rank") z$pval %||% NA_real_ else if(m=="selection") z$LRTp %||% NA_real_ else NA_real_
    data.frame(method=m,estimate=est,p_value=pv,note=status_df$message[match(m,status_df$method)],stringsAsFactors=FALSE)
  })
  out <- list(results=results,status=status_df,summary=do.call(rbind,summary_rows),favor=favor,q=q,
    selection_ratio=selection_ratio,robust=robust,measure=model$measure,model_hash=model$data_hash,
    caution="Small-study effects and funnel asymmetry have multiple causes. No bias-adjusted result is automatically preferred over the primary model.")
  class(out)<-"apm_bias"; out
}
