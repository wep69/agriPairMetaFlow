# End-to-end orchestration -------------------------------------------------

.apm_workflow_role <- function(dat, candidates) {
  hit <- candidates[candidates %in% names(dat)]
  if(length(hit)) hit[1L] else NA_character_
}

.apm_workflow_log_row <- function(step, decision, reason, source=c("auto","user","derived")) {
  source <- match.arg(source)
  data.frame(step=step,decision=as.character(decision),reason=as.character(reason),source=source,stringsAsFactors=FALSE)
}

.apm_workflow_make_plan <- function(dat, dependence) {
  study <- .apm_workflow_role(dat,c("study_id","study","paper_id"))
  trt <- .apm_workflow_role(dat,c("treatment","treatment_id"))
  ctl <- .apm_workflow_role(dat,c("control","control_id"))
  if(anyNA(c(study,trt,ctl))) return(NULL)
  response <- .apm_workflow_role(dat,c("mean_t","yi","response"))
  experiment <- .apm_workflow_role(dat,c("experiment_id","experiment"))
  effect <- .apm_workflow_role(dat,c("effect_id"))
  dose <- .apm_workflow_role(dat,c("dose","N_rate","rate"))
  site <- .apm_workflow_role(dat,c("site","location"))
  year <- .apm_workflow_role(dat,c("year"))
  outcome <- .apm_workflow_role(dat,c("outcome","response_name"))
  block <- .apm_workflow_role(dat,c("block_id","block"))
  time <- .apm_workflow_role(dat,c("time","time_month"))
  dsgn <- if(identical(dependence,"paired")) "paired" else "auto"
  args <- list(data=dat, study=rlang::sym(study), treatment=rlang::sym(trt), control=rlang::sym(ctl), design=dsgn)
  optional <- list(response=response,experiment=experiment,effect_id=effect,dose=dose,site=site,year=year,outcome=outcome,block=block,time=time)
  for(nm in names(optional)) if(!is.na(optional[[nm]])) args[[nm]] <- rlang::sym(optional[[nm]])
  rlang::inject(apm_plan(!!!args))
}

.apm_workflow_effects <- function(dat, measure, dependence) {
  if(all(c("yi","vi") %in% names(dat)) && identical(measure,"GEN"))
    return(apm_effect_size(dat,measure="GEN",yi=yi,vi=vi))
  design <- if(identical(dependence,"paired")) "paired" else "independent"
  if(measure %in% c("RR","OR","RD")) {
    req <- c("event_t","event_c","n_t","n_c")
    if(!all(req %in% names(dat))) .apm_abort("Workflow measure {.val {measure}} requires columns event_t, event_c, n_t, and n_c, or precompute effects with apm_effect_size().")
    return(apm_effect_size(dat,measure=measure,design=design,event_t=event_t,event_c=event_c,n_t=n_t,n_c=n_c))
  }
  if(identical(measure,"ZCOR")) {
    if(!all(c("r","n_t")%in%names(dat))) .apm_abort("Workflow ZCOR routing requires columns r and n_t.")
    return(apm_effect_size(dat,measure="ZCOR",r=r,n_t=n_t))
  }
  nt <- if("n_t"%in%names(dat)) "n_t" else if("n_pairs"%in%names(dat)) "n_pairs" else NA_character_
  nc <- if("n_c"%in%names(dat)) "n_c" else if("n_pairs"%in%names(dat)) "n_pairs" else NA_character_
  rr <- if("r_tc"%in%names(dat)) "r_tc" else if("r"%in%names(dat)) "r" else NA_character_
  req <- c("mean_t","sd_t","mean_c","sd_c")
  if(!all(req%in%names(dat)) || is.na(nt) || is.na(nc))
    .apm_abort("Workflow continuous-effect routing requires mean_t, sd_t, treatment n, mean_c, sd_c, and control n. Otherwise precompute apm_effect_size() and call downstream functions directly.")
  args <- list(data=dat,measure=measure,design=design,m_t=rlang::sym("mean_t"),sd_t=rlang::sym("sd_t"),n_t=rlang::sym(nt),m_c=rlang::sym("mean_c"),sd_c=rlang::sym("sd_c"),n_c=rlang::sym(nc))
  if(identical(design,"paired")) {
    if(is.na(rr)) .apm_abort("Paired workflow routing requires r_tc or r. Treatment-control labeling alone is not pairing.")
    args$r <- rlang::sym(rr)
  }
  rlang::inject(apm_effect_size(!!!args))
}

.apm_workflow_random <- function(dat) {
  if(all(c("study_id","experiment_id","effect_id")%in%names(dat))) return(~1|study_id/experiment_id/effect_id)
  if(all(c("study_id","experiment_id")%in%names(dat))) return(~1|study_id/experiment_id)
  if(all(c("study_id","effect_id")%in%names(dat))) return(~1|study_id/effect_id)
  if("study_id"%in%names(dat)) return(~1|study_id)
  NULL
}

#' Run an auditable end-to-end agronomic meta-analysis workflow
#'
#' @param data Raw treatment-control summaries or an `apm_effects` object.
#' @param plan Optional `apm_plan`. Supply a plan when column roles are not named
#'   using the package's conventional teaching-data names.
#' @param measure Effect measure passed to `apm_effect_size()`.
#' @param dependence Dependence routing. `"auto"` detects shared controls and
#'   recognizes a paired design only when paired summaries/correlation are explicit.
#' @param model Model routing.
#' @param moderators Optional one-sided moderator formula.
#' @param robust Request CR2 cluster-robust inference when a study cluster is available.
#' @param bayes Request an additional Bayesian fit through `apm_bayes()`.
#' @param threshold Optional agronomic relevance threshold. For lnRR this is
#'   interpreted as percent change; otherwise it is on the model scale.
#' @param seed Optional reproducibility seed for stochastic downstream backends.
#' @param ... Additional arguments passed to the selected frequentist fitting function.
#' @return An `apm_workflow` containing audit, plan, effects, covariance,
#'   fitted model, diagnostics, sensitivity objects, tables metadata, and a routing log.
#' @export
#' @examples
#' # Example 1: maize nitrogen contrasts sharing the same zero-N control.
#' if (requireNamespace("clubSandwich", quietly=TRUE)) {
#'   apm_workflow(maize_n_shared, measure="lnRR", dependence="shared_control",
#'     model="multilevel", robust=TRUE)
#' }
#' # Example 2: irrigation response explained by rainfall and temperature.
#' apm_workflow(irrigation_climate, measure="lnRR",
#'   moderators=~rainfall+mean_temp, threshold=5)
#' # Example 3: genuinely paired wheat treatment-control summaries.
#' apm_workflow(wheat_paired_blocks, measure="lnRR", dependence="paired",
#'   model="random")
apm_workflow <- function(data, plan = NULL, measure = "lnRR",
                         dependence = c("auto", "independent", "shared_control", "paired"),
                         model = c("auto", "random", "multilevel"), moderators = NULL,
                         robust = FALSE, bayes = FALSE, threshold = NULL, seed = NULL, ...) {
  dependence <- match.arg(dependence); model <- match.arg(model)
  dat <- .apm_df(data); route <- list(); nr <- 0L
  logit <- function(step,decision,reason,source="auto") { nr <<- nr+1L; route[[nr]] <<- .apm_workflow_log_row(step,decision,reason,source) }
  if(!is.null(seed)) {
    if(length(seed)!=1L||!is.finite(seed)) .apm_abort("{.arg seed} must be one finite number.")
    had_seed <- exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
    if(had_seed) old_seed <- get(".Random.seed", envir=.GlobalEnv, inherits=FALSE)
    on.exit({ if(had_seed) assign(".Random.seed", old_seed, envir=.GlobalEnv) else if(exists(".Random.seed", envir=.GlobalEnv, inherits=FALSE)) rm(".Random.seed", envir=.GlobalEnv) }, add=TRUE)
    set.seed(as.integer(seed)); logit("seed",seed,"User supplied reproducibility seed.","user")
  }

  audit <- apm_audit(dat,plan=plan,level="full")
  if(any(audit$issues$severity=="error")) .apm_abort("Workflow audit found error-level data issues. Resolve them before fitting; inspect apm_audit(data, level='full').")

  if(is.null(plan)) {
    plan <- .apm_workflow_make_plan(dat,dependence)
    logit("plan",if(is.null(plan))"not constructed" else "auto plan","Conventional role names were inspected; no scientific role was invented.","auto")
  } else {
    if(!inherits(plan,"apm_plan")) .apm_abort("{.arg plan} must be NULL or an apm_plan object.")
    if(!identical(plan$data_hash,.apm_hash_data(dat))) .apm_abort("The supplied {.arg plan} was created from different data. Rebuild apm_plan() for the current data.")
    logit("plan","user plan","User supplied an explicit apm_plan object.","user")
  }

  dep <- dependence
  if(dep=="auto") {
    shared <- if(!is.null(plan)) plan$dependence$n_shared>0 else FALSE
    paired_explicit <- all(c("n_pairs","r_tc")%in%names(dat)) || (!is.null(plan) && identical(plan$requested_design,"paired"))
    dep <- if(shared) "shared_control" else if(paired_explicit) "paired" else "independent"
    logit("dependence",dep,if(shared)"Reused control arms detected." else if(paired_explicit)"Explicit paired sample size/correlation information detected." else "No explicit dependence source requiring a sampling covariance model was detected.","auto")
  } else logit("dependence",dep,"User override.","user")
  if(dep=="paired" && !all(c("n_pairs","r_tc")%in%names(dat)) && (is.null(plan)||!identical(plan$requested_design,"paired")))
    .apm_abort("dependence='paired' requires explicit paired information (for example n_pairs and r_tc) or an explicit paired apm_plan().")

  effects <- .apm_workflow_effects(dat,measure,dep)
  logit("effect_size",measure,paste("Computed using design",attr(effects,"design"),"and backend measure",attr(effects,"backend_measure")),"derived")

  V <- NULL
  if(dep=="shared_control") {
    cluster_name <- .apm_workflow_role(as.data.frame(effects),c("experiment_id","study_id"))
    if(is.na(cluster_name)) .apm_abort("Shared-control workflow requires experiment_id or study_id to define independent covariance blocks.")
    V <- rlang::inject(apm_vcov(effects,cluster=!!rlang::sym(cluster_name),shared_control=TRUE))
  } else if(dep=="paired") {
    logit("sampling_covariance","paired variance encoded in vi","The treatment-control correlation is already used by the paired effect-size variance. No between-effect covariance is invented.","derived")
  }
  if(!is.null(V)) logit("sampling_covariance","shared-control V","Reused arms induce covariance among contrasts and are retained explicitly.","derived")

  model_route <- model
  if(model_route=="auto") {
    model_route <- if(dep=="shared_control") "multilevel" else "random"
    logit("model",model_route,if(dep=="shared_control")"Shared-control effects require dependence-aware synthesis; multilevel routing selected." else "Random-effects synthesis selected as the default cross-study model.","auto")
  } else logit("model",model_route,"User override.","user")

  dots <- list(...); random_formula <- .apm_workflow_random(as.data.frame(effects))
  if(!is.null(moderators)) {
    if(!inherits(moderators,"formula")||length(moderators)!=2L) .apm_abort("{.arg moderators} must be a one-sided formula.")
    if(model_route=="multilevel") {
      if(is.null(random_formula)) .apm_abort("Multilevel meta-regression requires identifiable study/experiment hierarchy columns.")
      fit <- rlang::exec(apm_metareg,effects=effects,moderators=moderators,V=V,random=random_formula,!!!dots)
    } else fit <- rlang::exec(apm_metareg,effects=effects,moderators=moderators,V=V,!!!dots)
    logit("moderators",paste(deparse(moderators),collapse=" "),"Meta-regression requested by the user.","user")
  } else if(model_route=="multilevel") {
    if(is.null(random_formula)) .apm_abort("model='multilevel' requires identifiable study/experiment hierarchy columns or use apm_multilevel() directly with an explicit random formula.")
    fit <- rlang::exec(apm_multilevel,effects=effects,random=random_formula,V=V,!!!dots)
  } else {
    fit <- rlang::exec(apm_fit,effects=effects,V=V,model="random",!!!dots)
  }

  dep_audit <- if("study_id"%in%names(effects)) rlang::inject(apm_dependence_audit(effects,V=V,cluster=!!rlang::sym("study_id"))) else apm_dependence_audit(effects,V=V)
  heterogeneity <- tryCatch(apm_heterogeneity(fit),error=function(e) e)
  prediction <- tryCatch(apm_prediction(fit,transform=if(toupper(measure)=="LNRR")"percent" else "none"),error=function(e) e)
  threshold_obj <- NULL
  if(!is.null(threshold)) {
    threshold_obj <- tryCatch(apm_threshold(fit,threshold=threshold,scale=if(toupper(measure)=="LNRR")"percent" else "model"),error=function(e)e)
    logit("threshold",threshold,paste("Practical threshold evaluated on",if(toupper(measure)=="LNRR")"percent" else "model","scale."),"user")
  }

  robust_obj <- NULL
  if(isTRUE(robust)) {
    if(!"study_id"%in%names(fit$data)) .apm_abort("robust=TRUE requires study_id in the fitted data. Fit apm_robust() manually with an explicit cluster otherwise.")
    robust_obj <- rlang::inject(apm_robust(fit,cluster=!!rlang::sym("study_id"),vcov="CR2"))
    logit("robust","CR2","Cluster-robust inference requested; study_id used as independent cluster.","user")
  }

  bayes_obj <- NULL
  if(isTRUE(bayes)) {
    if(dep=="shared_control") .apm_abort("bayes=TRUE is not automatically routed for shared-control effects because the current Bayesian adapters do not accept the full sampling covariance V. Fit and validate a dependence-aware Bayesian model explicitly rather than dropping covariance.")
    bmods <- moderators %||% ~1
    if(model_route=="multilevel"&&"study_id"%in%names(effects)) bayes_obj <- rlang::inject(apm_bayes(effects,mods=bmods,cluster=!!rlang::sym("study_id"),backend="auto",seed=seed))
    else bayes_obj <- apm_bayes(effects,mods=bmods,backend="auto",seed=seed)
    logit("bayes",bayes_obj$backend_detail,"Additional Bayesian sensitivity fit requested.","user")
  }

  diagnostics <- list(dependence=dep_audit,heterogeneity=heterogeneity,prediction=prediction,threshold=threshold_obj)
  sensitivities <- list(robust=robust_obj,bayesian=bayes_obj)
  route_df <- do.call(rbind,route); rownames(route_df)<-NULL
  out <- list(audit=audit,plan=plan,effects=effects,V=V,fit=fit,diagnostics=diagnostics,sensitivities=sensitivities,
              tables=list(model=tryCatch(apm_table(fit),error=function(e)NULL)),plots_metadata=list(forest="apm_forest(fit)",funnel="apm_funnel(fit)",orchard="apm_orchard(fit)"),
              routing_log=route_df,settings=list(measure=measure,dependence=dep,model=model_route,moderators=moderators,robust=robust,bayes=bayes,threshold=threshold,seed=seed),
              data_hash=.apm_hash_data(dat),package_version=as.character(utils::packageVersion("agriPairMetaFlow")),call=match.call())
  class(out)<-"apm_workflow"; out
}
