print.apm_data <- function(x, ...) { cat("<apm_data>\n",nrow(x$data)," rows x ",ncol(x$data)," columns\n",sep=""); cat("source:",x$provenance$path,"\n"); invisible(x) }
print.apm_validation <- function(x, ...) { cat("<apm_validation>",if(x$ok)"PASS" else "FAIL","\n"); if(nrow(x$issues)) print(x$issues,row.names=FALSE); invisible(x) }
print.apm_audit <- function(x, ...) { cat("<apm_audit>\n"); if(nrow(x$issues)) print(x$issues,row.names=FALSE) else cat("No audit issues detected.\n"); invisible(x) }
print.apm_plan <- function(x, ...) { cat("<apm_plan>\ndesign:",x$design,"\nshared controls:",x$dependence$n_shared,"\n"); if(length(x$recommendations)) cat(paste0("- ",x$recommendations,collapse="\n"),"\n"); invisible(x) }
print.apm_uncertainty <- function(x, ...) { cat("<apm_uncertainty>\n"); print(table(x$derivations$method,useNA="ifany")); invisible(x) }
print.apm_effects <- function(x, ...) { cat("<apm_effects>",nrow(x)," effects; measure=",attr(x,"measure"),"; design=",attr(x,"design"),"\n",sep=""); print(utils::head(as.data.frame(x)[intersect(c("yi","vi","sei"),names(x))],6),row.names=FALSE); invisible(x) }
print.apm_model <- function(x, ...) { cat("<apm_model> measure=",x$measure,", model=",x$settings$model,", method=",x$settings$method,"\n",sep=""); print(stats::coef(x$backend_fit)); invisible(x) }
print.apm_subgroup <- function(x, ...) { cat("<apm_subgroup>\n"); print(x$subgroup_estimates,row.names=FALSE); if(!is.null(x$omnibus_test)) {cat("Omnibus subgroup test:\n");print(x$omnibus_test,row.names=FALSE)}; invisible(x) }
print.apm_heterogeneity <- function(x, ...) { cat("<apm_heterogeneity>\n"); print(x$table,row.names=FALSE); invisible(x) }
print.apm_prediction <- function(x, ...) { cat("<apm_prediction> transform=",x$transform,"\n",sep=""); print(x$table,row.names=FALSE); invisible(x) }
print.apm_threshold <- function(x, ...) { cat("<apm_threshold>\nthreshold:",x$threshold,"[",x$scale,"]\nCI:",x$ci_relation,"\nPI:",x$pi_relation,"\nprobability:",format(x$probability,digits=3),"\n"); invisible(x) }

print.apm_shared_control <- function(x, ...) {
  cat("<apm_shared_control>\n")
  print(x$summary, row.names=FALSE)
  if(nrow(x$conflicts)) cat("control-summary conflicts:", nrow(x$conflicts), "\n")
  cat(x$recommendation, "\n")
  invisible(x)
}
print.apm_vcov <- function(x, ...) {
  meta <- attr(x,"apm_meta")
  cat("<apm_vcov>", nrow(x), "x", ncol(x), "\n")
  if(!is.null(meta)) cat("backend:", meta$backend %||% "unknown", " | PSD:", meta$positive_semidefinite %||% NA, "\n")
  invisible(x)
}
print.apm_dependence_audit <- function(x, ...) {
  cat("<apm_dependence_audit>\n"); print(x$sources,row.names=FALSE)
  cat("V supplied:",x$V_supplied," | unresolved sources:",nrow(x$unresolved),"\n")
  cat(x$recommendation,"\n"); invisible(x)
}
print.apm_sensitivity <- function(x, ...) {
  cat("<apm_sensitivity>\n"); print(x$results,row.names=FALSE)
  if(!is.null(x$n_fail)&&x$n_fail) cat("failed fits:",x$n_fail,"\n")
  invisible(x)
}
print.apm_multilevel <- function(x, ...) {
  cat("<apm_multilevel> measure=", x$measure, "\n", sep="")
  print(data.frame(term=names(x$coefficients),estimate=as.numeric(x$coefficients)),row.names=FALSE)
  if(length(x$backend_fit$sigma2)) cat("sigma2:",paste(signif(x$backend_fit$sigma2,4),collapse=", "),"\n")
  invisible(x)
}
print.apm_variance_components <- function(x, ...) {
  cat("<apm_variance_components>\n"); print(x$table,row.names=FALSE); invisible(x)
}
print.apm_robust <- function(x, ...) {
  cat("<apm_robust>",x$type,"clusters=",x$n_clusters,"\n"); print(x$coefficients,row.names=FALSE)
  if(!is.null(x$joint)) { cat("Joint test:\n"); print(x$joint,row.names=FALSE) }
  invisible(x)
}
print.apm_wild <- function(x, ...) {
  cat("<apm_wild>",x$type,"R=",x$R,"clusters=",x$n_clusters,"\n"); print(x$test,row.names=FALSE)
  cat("Monte Carlo SE:",signif(x$mcse,4),"\n"); invisible(x)
}
print.apm_inference_comparison <- function(x, ...) {
  cat("<apm_inference_comparison> transform=",x$transform,"\n",sep=""); print(x$table,row.names=FALSE); invisible(x)
}
print.apm_metareg <- function(x, ...) {
  cat("<apm_metareg> measure=",x$measure," | backend=",x$settings$backend,"\n",sep="")
  print(data.frame(term=names(x$coefficients),estimate=as.numeric(x$coefficients)),row.names=FALSE)
  cat("Residual QE:",signif(x$heterogeneity$QE,5)," | meta-R2 (%):",signif(x$heterogeneity$meta_R2_percent,5),"\n")
  invisible(x)
}
print.apm_marginal <- function(x, ...) { cat("<apm_marginal> weights=",x$weights," | transform=",x$transform,"\n",sep=""); print(x$table,row.names=FALSE); invisible(x) }
print.apm_interaction <- function(x, ...) { cat("<apm_interaction> ",x$term," | contrast=",x$contrast,"\n",sep=""); print(x$table,row.names=FALSE); cat("Joint interaction test:\n"); print(x$joint_test,row.names=FALSE); invisible(x) }
print.apm_curve_features <- function(x, ...) {
  cat("<apm_curve_features>\n")
  if(!is.null(x$turning_point)){cat("Turning points:\n");print(x$turning_point,row.names=FALSE)}
  if(!is.null(x$threshold_crossing)){cat("Threshold crossings:\n");print(x$threshold_crossing,row.names=FALSE)}
  if(!is.null(x$slope)) cat("Slope grid:",nrow(x$slope),"locations\n")
  cat(x$caution,"\n"); invisible(x)
}
print.apm_model_comparison <- function(x, ...) { cat("<apm_model_comparison> criterion=",x$criterion,"\n",sep=""); print(x$table,row.names=FALSE); invisible(x) }
print.apm_dose <- function(x, ...) {
  cat("<apm_dose> form=",x$dose_info$form," | backend=",x$settings$backend," | covariance=",x$covariance$source,"\n",sep="")
  print(data.frame(term=names(x$coefficients),estimate=as.numeric(x$coefficients)),row.names=FALSE)
  invisible(x)
}

# 0.4.0 multivariate and Bayesian classes --------------------------------
print.apm_multivariate <- function(x, ...) {
  cat("<apm_multivariate> outcomes=", length(x$outcomes), " | backend=", x$backend,
      " | structure=", x$settings$structure, "\n", sep="")
  print(x$outcome_estimates, row.names=FALSE)
  if (!is.null(x$between_cor)) cat("Between-outcome correlation matrix available.\n")
  invisible(x)
}
print.apm_prior <- function(x, ...) {
  cat("<apm_prior> scale=", x$scale, "\n", sep="")
  cat("effect:", x$effect$dist, " | tau:", x$tau$dist, "\n")
  if (!is.null(x$moderators)) cat("moderator priors:", length(x$moderators), "\n")
  invisible(x)
}
print.apm_prior_check <- function(x, ...) {
  cat("<apm_prior_check> draws=", nrow(x$draws), " | measure=", x$measure, "\n", sep="")
  print(x$summary, row.names=FALSE)
  if (!is.null(x$thresholds) && nrow(x$thresholds)) { cat("Threshold implications:\n"); print(x$thresholds, row.names=FALSE) }
  invisible(x)
}
print.apm_bayes <- function(x, ...) {
  cat("<apm_bayes> backend=", x$backend_detail, " | measure=", x$measure, "\n", sep="")
  if (nrow(x$posterior_summary)) print(x$posterior_summary, row.names=FALSE)
  cat("Run apm_bayes_diagnostics() before substantive interpretation.\n")
  invisible(x)
}
print.apm_bayes_prediction <- function(x, ...) {
  cat("<apm_bayes_prediction> target=", x$target, " | transform=", x$transform, "\n", sep="")
  print(x$table, row.names=FALSE); invisible(x)
}
print.apm_bayes_threshold <- function(x, ...) {
  cat("<apm_bayes_threshold> probability=", format(x$probability, digits=4),
      " | threshold=", x$threshold, " [", x$scale, "]\n", sep="")
  if (!is.na(x$rope_probability)) cat("ROPE probability:", format(x$rope_probability, digits=4), "\n")
  cat(x$interpretation, "\n"); invisible(x)
}
print.apm_bayes_diagnostics <- function(x, ...) {
  cat("<apm_bayes_diagnostics> backend=", x$backend,
      " | verified=", x$diagnostics_verified,
      " | severe failure=", x$severe_failure, "\n", sep="")
  if (nrow(x$table)) print(x$table, row.names=FALSE)
  if (length(x$warnings)) cat(paste0("- ", x$warnings, collapse="\n"), "\n")
  invisible(x)
}
print.apm_bayes_comparison <- function(x, ...) {
  cat("<apm_bayes_comparison> criterion=", x$criterion, "\n", sep="")
  print(x$table, row.names=FALSE)
  cat(x$caution, "\n"); invisible(x)
}


# 0.5.0 diagnostics, sensitivity, and communication classes ----------------
print.apm_influence <- function(x, ...) { cat("<apm_influence> unit=",x$unit," | plot=",x$plot_type,"\n",sep=""); print(utils::head(x$diagnostics,10),row.names=FALSE); cat(x$caution,"\n"); invisible(x) }
print.apm_gosh <- function(x, ...) { cat("<apm_gosh> subsets=",nrow(x$results)," | seed=",x$seed %||% "not supplied","\n",sep=""); print(utils::head(x$results,10),row.names=FALSE); invisible(x) }
print.apm_bias <- function(x, ...) { cat("<apm_bias>\n"); print(x$summary,row.names=FALSE); cat(x$caution,"\n"); invisible(x) }
print.apm_moderator_screen <- function(x, ...) { cat("<apm_moderator_screen> exploratory=TRUE | units=",x$n_units,"\n",sep=""); print(x$importance,row.names=FALSE); cat(x$caution,"\n"); invisible(x) }
print.apm_report <- function(x, ...) { cat("<apm_report>\nfile:",x$file,"\nsource:",x$source_template,"\nobject hash:",x$object_hash,"\n"); invisible(x) }


# 1.0 integration and release-readiness classes -----------------------------
print.apm_workflow <- function(x, ...) {
  cat("<apm_workflow> measure=",x$settings$measure,
      " | dependence=",x$settings$dependence,
      " | model=",x$settings$model,"\n",sep="")
  cat("effects:",nrow(x$effects),"| data hash:",x$data_hash,"\n")
  if(nrow(x$routing_log)) print(x$routing_log,row.names=FALSE)
  invisible(x)
}
print.apm_capabilities <- function(x, ...) {
  cat("<apm_capabilities>\n")
  NextMethod("print",x,row.names=FALSE)
  invisible(x)
}
print.apm_doctor <- function(x, ...) {
  cat("<apm_doctor>",if(isTRUE(x$ok))"CORE PASS" else "CORE FAIL","\n")
  print(x$checks,row.names=FALSE)
  cat("Environment mutated:",isTRUE(x$mutated_environment),"\n")
  invisible(x)
}
