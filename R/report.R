# Reproducible reporting -------------------------------------------------

.apm_report_payload <- function(x, sections, title) {
  payload<-list(title=title,sections=sections,generated=as.character(Sys.time()),object_class=class(x)[1],object_hash=.apm_hash_object(x),explanation=NULL,model_table=NULL,heterogeneity=NULL,prediction=NULL,plot=NULL)
  payload$explanation<-tryCatch(apm_explain(x,audience="scientific",transform="auto"),error=function(e) character())
  if(inherits(x,"apm_model")) {
    if("model"%in%sections) payload$model_table<-tryCatch(apm_table(x,component="model"),error=function(e)NULL)
    if("heterogeneity"%in%sections) payload$heterogeneity<-tryCatch(apm_heterogeneity(x)$table,error=function(e)NULL)
    if("prediction"%in%sections) payload$prediction<-tryCatch(apm_prediction(x)$table,error=function(e)NULL)
    if("plots"%in%sections) payload$plot<-tryCatch(apm_forest(x),error=function(e)NULL)
  } else if(inherits(x,"apm_bias")&&"sensitivity"%in%sections) payload$model_table<-x$summary
  else if(inherits(x,"apm_influence")&&"diagnostics"%in%sections) payload$model_table<-x$diagnostics
  payload
}

#' Render a reproducible meta-analysis report without refitting the model
#'
#' @param x agriPairMetaFlow result object.
#' @param file Output filename.
#' @param format HTML, DOCX, or PDF.
#' @param sections Report sections.
#' @param title Optional report title.
#' @param bibliography Optional bibliography file.
#' @param seed Seed recorded in report provenance.
#' @return An `apm_report` with output/source paths, hashes and section inventory.
#' @export
#' @examples
#' # Example 1: HTML report from a fitted agronomic meta-analysis.
#' if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html")
#' # Example 2: reduced section inventory.
#' if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html", sections=c("model","prediction","plots"))
#' # Example 3: explicit title and reproducibility seed.
#' if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), title="Agronomic treatment-control synthesis", seed=2026)
apm_report <- function(x, file, format = c("html", "docx", "pdf"),
                       sections = c("data", "effects", "model", "heterogeneity", "prediction", "diagnostics", "sensitivity", "plots"),
                       title = NULL, bibliography = NULL, seed = NULL) {
  .apm_require("rmarkdown","analysis-report rendering");format<-match.arg(format)
  allowed<-c("data","effects","model","heterogeneity","prediction","diagnostics","sensitivity","plots");bad<-setdiff(sections,allowed);if(length(bad)) .apm_abort("Unknown report sections: {paste(bad,collapse=', ')}")
  if(!is.character(file)||length(file)!=1L||!nzchar(file)) .apm_abort("{.arg file} must be a path.")
  if(!is.null(bibliography)&&!file.exists(bibliography)) .apm_abort("{.arg bibliography} does not exist.")
  title<-title%||%"agriPairMetaFlow analysis report";dir.create(dirname(file),recursive=TRUE,showWarnings=FALSE)
  payload<-.apm_report_payload(x,sections,title);payload$seed<-seed;payload$package_version<-tryCatch(as.character(utils::packageVersion("agriPairMetaFlow")),error=function(e)"development source tree")
  stem<-sub("\\.[^.]+$","",basename(file));source_path<-file.path(dirname(file),paste0(stem,".source.Rmd"));payload_path<-file.path(dirname(file),paste0(stem,".payload.rds"));saveRDS(payload,payload_path,version=2)
  yaml<-c("---",paste0('title: "',gsub('"','\\\\"',title),'"'),paste0("output: ",switch(format,html="html_document",docx="word_document",pdf="pdf_document")))
  if(!is.null(bibliography)) yaml<-c(yaml,paste0('bibliography: "',normalizePath(bibliography,winslash="/",mustWork=TRUE),'"'))
  yaml<-c(yaml,"---","")
  pp<-normalizePath(payload_path,winslash="/",mustWork=TRUE)
  body<-c(
    "```{r setup, include=FALSE}",paste0("payload <- readRDS(",deparse(pp),")"),"knitr::opts_chunk$set(echo=FALSE, comment='#>')","```","",
    "# Provenance","", "This report summarizes an existing agriPairMetaFlow object. It does not refit the statistical model or change analysis defaults.","",
    "```{r provenance}","cat('Object class:', payload$object_class, '\\n')","cat('Object hash:', payload$object_hash, '\\n')","cat('Generated:', payload$generated, '\\n')","cat('Recorded seed:', ifelse(is.null(payload$seed), 'not supplied', payload$seed), '\\n')","cat('Package version:', payload$package_version, '\\n')","cat('R version:', R.version.string, '\\n')","```","",
    "# Interpretation","","```{r interpretation, results='asis'}","if(length(payload$explanation)) cat(paste(payload$explanation, collapse='\\n\\n'))","```","",
    "# Model summary","","```{r model-table, results='asis'}","if(!is.null(payload$model_table)) print(knitr::kable(payload$model_table)) else cat('No model table was supplied for this object/section.')","```","",
    "# Heterogeneity","","```{r heterogeneity, results='asis'}","if(!is.null(payload$heterogeneity)) print(knitr::kable(payload$heterogeneity)) else cat('Not supplied. Diagnostic analyses are not recomputed automatically.')","```","",
    "# Prediction","","```{r prediction, results='asis'}","if(!is.null(payload$prediction)) print(knitr::kable(payload$prediction)) else cat('Not supplied or not applicable.')","```","",
    "# Figure","","```{r figure, fig.width=7, fig.height=5}","if(!is.null(payload$plot)) print(payload$plot)","```","",
    "# Reproducibility","","```{r session-info}","sessionInfo()","```"
  )
  writeLines(c(yaml,body),source_path,useBytes=TRUE)
  outfmt<-switch(format,html="html_document",docx="word_document",pdf="pdf_document")
  rendered<-rmarkdown::render(source_path,output_format=outfmt,output_file=basename(file),output_dir=dirname(file),quiet=TRUE,envir=new.env(parent=globalenv()))
  out<-list(file=normalizePath(rendered,winslash="/",mustWork=TRUE),source_template=normalizePath(source_path,winslash="/",mustWork=TRUE),payload=normalizePath(payload_path,winslash="/",mustWork=TRUE),sections=sections,title=title,seed=seed,object_hash=payload$object_hash,file_md5=unname(tools::md5sum(rendered)),source_md5=unname(tools::md5sum(source_path)),payload_md5=unname(tools::md5sum(payload_path)))
  class(out)<-"apm_report";out
}
