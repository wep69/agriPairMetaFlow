# Exploratory moderator screening ---------------------------------------

.apm_mf_minimal_depth <- function(forest) {
  if (!requireNamespace("ranger",quietly=TRUE)) return(NULL)
  nt <- forest$num.trees %||% 0L; if(nt<1L) return(NULL)
  acc <- list()
  for(i in seq_len(nt)) {
    tr <- tryCatch(ranger::treeInfo(forest,tree=i),error=function(e) NULL); if(is.null(tr)) next
    depth <- setNames(rep(NA_integer_,nrow(tr)),as.character(tr$nodeID)); depth["0"]<-0L
    pending <- TRUE
    while(pending) {
      pending<-FALSE
      for(j in seq_len(nrow(tr))) {
        id<-as.character(tr$nodeID[j]); if(is.na(depth[id])) next
        for(ch in c("leftChild","rightChild")) if(ch%in%names(tr)) {
          kid<-tr[[ch]][j]; if(!is.na(kid) && as.character(kid)%in%names(depth) && is.na(depth[as.character(kid)])) {depth[as.character(kid)]<-depth[id]+1L;pending<-TRUE}
        }
      }
    }
    ok<-!is.na(tr$splitvarName) & nzchar(tr$splitvarName)
    if(any(ok)) for(v in unique(tr$splitvarName[ok])) acc[[v]]<-c(acc[[v]],min(depth[as.character(tr$nodeID[ok & tr$splitvarName==v])],na.rm=TRUE))
  }
  if(!length(acc)) return(NULL)
  data.frame(moderator=names(acc),importance=vapply(acc,mean,numeric(1),na.rm=TRUE),metric="minimal_depth",stringsAsFactors=FALSE)
}

#' Exploratory screening of many agronomic moderators with MetaForest
#'
#' @param effects Effect-size data containing `yi` and `vi`.
#' @param moderators One-sided additive moderator formula.
#' @param method Screening backend; currently MetaForest.
#' @param cluster Optional cluster/study vector or column name for dependent effects.
#' @param seed Reproducibility seed.
#' @param tune Request cross-validated tuning when `caret` is available.
#' @param cv Number of cross-validation folds.
#' @param importance Variable-importance measure.
#' @param ... Additional arguments to MetaForest.
#' @return An `apm_moderator_screen` explicitly labeled exploratory.
#' @export
#' @examples
#' # Example 1: climatic moderator screening.
#' if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop+soil_texture, seed=1, tune=FALSE)
#' # Example 2: permutation importance.
#' if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop, importance="permutation", seed=2, tune=FALSE)
#' # Example 3: minimal-depth summary when ranger exposes tree structure.
#' if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+soil_texture, importance="minimal_depth", seed=3, tune=FALSE)
apm_moderator_screen <- function(effects, moderators, method = c("metaforest"), cluster = NULL,
                                 seed = NULL, tune = TRUE, cv = 10,
                                 importance = c("permutation", "minimal_depth"), ...) {
  method<-match.arg(method); importance<-match.arg(importance); .apm_require("metaforest","exploratory moderator screening")
  dat<-.apm_df(effects); if(!all(c("yi","vi")%in%names(dat))) .apm_abort("{.arg effects} must contain yi and vi.")
  if(!inherits(moderators,"formula")||length(moderators)!=2L) .apm_abort("{.arg moderators} must be a one-sided formula.")
  vars<-all.vars(moderators); miss<-setdiff(vars,names(dat)); if(length(miss)) .apm_abort("Moderator variables not found: {paste(miss,collapse=', ')}")
  if(length(vars)<1L) .apm_abort("At least one moderator is required.")
  keep<-is.finite(dat$yi)&is.finite(dat$vi)&dat$vi>0&stats::complete.cases(dat[,vars,drop=FALSE]); dat<-dat[keep,,drop=FALSE]
  for(v in vars) if(is.character(dat[[v]])) dat[[v]] <- factor(dat[[v]])
  clname<-NULL
  if(!is.null(cluster)) {
    if(is.character(cluster)&&length(cluster)==1L&&cluster%in%names(dat)) clname<-cluster else {
      if(length(cluster)!=sum(keep) && length(cluster)!=length(keep)) .apm_abort("{.arg cluster} must match the effect rows or name a column.")
      cvv<-if(length(cluster)==length(keep)) cluster[keep] else cluster; dat$.apm_cluster<-as.factor(cvv);clname<-".apm_cluster"
    }
  } else if("study_id"%in%names(dat) && anyDuplicated(dat$study_id)) clname<-"study_id"
  nunits<-if(is.null(clname)) nrow(dat) else length(unique(dat[[clname]])); if(nunits<max(8L,2L*length(vars))) .apm_abort("Too few independent study units for exploratory screening relative to the number of moderators.")
  f<-stats::as.formula(paste("yi ~",paste(vars,collapse=" + ")))
  tuning<-list(requested=isTRUE(tune),performed=FALSE,cv=cv,best=NULL)
  fit_bundle <- .apm_seeded(seed,function(clname_=clname, tune_=tune){
    tun <- tuning
    study_val <- clname_
    bt <- NULL
    if(isTRUE(tune_) && requireNamespace("caret",quietly=TRUE) && length(vars)>1L) {
      k<-min(as.integer(cv),nunits); if(k<2L) k<-2L
      idx<-if(!is.null(study_val)) caret::groupKFold(dat[[study_val]],k=k) else caret::createFolds(dat$yi,k=k,returnTrain=TRUE)
      x<-dat[,vars,drop=FALSE];x$vi<-dat$vi;if(!is.null(study_val))x[[study_val]]<-dat[[study_val]]
      ctrl<-caret::trainControl(method="cv",index=idx)
      mtry_grid<-unique(pmax(1L,pmin(length(vars),c(1L,floor(sqrt(length(vars))),length(vars)))))
      grid<-expand.grid(whichweights="random",mtry=mtry_grid,min.node.size=c(2L,4L),stringsAsFactors=FALSE)
      args<-list(y=dat$yi,x=x,method=metaforest::ModelInfo_mf(),trControl=ctrl,tuneGrid=grid)
      if(!is.null(study_val))args$study<-study_val
      cvfit<-do.call(caret::train,args); tun$performed<-TRUE;tun$best<-cvfit$bestTune
      bt<-cvfit$bestTune
    }
    if(isTRUE(tune_) && !requireNamespace("caret",quietly=TRUE)) .apm_warn("caret is not installed; MetaForest tuning was skipped and the documented default fit is returned.")
    # NB: our `importance` argument selects the post-fit summary metric only and
    # is never forwarded: the unclustered backend duplicates a forwarded
    # `importance` into its ranger call, while the forest always uses
    # permutation importance internally (the clustered backend enforces this).
    mf_args<-list(formula=f,data=dat,vi="vi",
      whichweights=if(is.null(bt)) "random" else as.character(bt$whichweights)[1L])
    if(!is.null(study_val)) mf_args$study<-study_val
    if(!is.null(bt)) { mf_args$mtry<-suppressWarnings(as.integer(bt$mtry)[1L]); mf_args$min.node.size<-suppressWarnings(as.integer(bt$min.node.size)[1L]) }
    fit1<-do.call(metaforest::MetaForest,c(mf_args,list(...)))
    list(fit=fit1,tuning=tun)
  })
  fit <- fit_bundle$fit; tuning <- fit_bundle$tuning
  imp<-if(importance=="permutation") {
    z<-fit$forest$variable.importance %||% numeric(); data.frame(moderator=names(z),importance=as.numeric(z),metric="permutation",stringsAsFactors=FALSE)
  } else .apm_mf_minimal_depth(fit$forest)
  if(is.null(imp)) .apm_abort("Requested importance metric could not be extracted from the fitted MetaForest backend.")
  imp<-imp[order(if(importance=="minimal_depth")imp$importance else -imp$importance),,drop=FALSE]
  out<-list(backend_fit=fit,importance=imp,tuning=tuning,formula=f,moderators=vars,cluster=clname,seed=seed,n_units=nunits,
    data=dat,method=method,exploratory=TRUE,caution="MetaForest is exploratory moderator screening. Confirm scientific hypotheses with prespecified meta-regression and appropriate uncertainty analysis.",backend_version=.apm_backend_version("metaforest"))
  class(out)<-"apm_moderator_screen";out
}
