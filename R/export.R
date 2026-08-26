# Export scientific outputs ---------------------------------------------

.apm_export_table <- function(x) {
  if(is.data.frame(x)) return(x)
  if(inherits(x,"apm_effects")) return(as.data.frame(x))
  if(inherits(x,c("apm_model","apm_heterogeneity","apm_robust","apm_sensitivity","apm_inference_comparison","apm_bayes"))) return(apm_table(x))
  if(inherits(x,"apm_bias")) return(x$summary)
  if(inherits(x,"apm_influence")) return(x$diagnostics)
  .apm_abort("This object does not have a tabular export representation.")
}

#' Export tables, models, figures, and reproducible objects
#'
#' @param x Object to export.
#' @param path Destination path.
#' @param format CSV, XLSX, RDS, JSON, PNG, SVG, TIFF, or HTML.
#' @param dpi Raster-figure resolution; defaults to 600 dpi.
#' @param width,height Figure dimensions in inches.
#' @param overwrite Allow replacement of an existing file.
#' @return Invisibly, the normalized output path with checksum/provenance attributes.
#' @export
#' @examples
#' # Example 1: reproducible model object.
#' apm_export(apm_fit(agri_effects_benchmark), tempfile(fileext=".rds"), format="rds", overwrite=TRUE)
#' # Example 2: numeric-preserving CSV table.
#' apm_export(apm_table(apm_fit(agri_effects_benchmark)), tempfile(fileext=".csv"), format="csv", overwrite=TRUE)
#' # Example 3: publication-resolution forest figure.
#' apm_export(apm_forest(apm_fit(agri_effects_benchmark)), tempfile(fileext=".tiff"), format="tiff", dpi=600, overwrite=TRUE)
apm_export <- function(x, path, format = c("csv", "xlsx", "rds", "json", "png", "svg", "tiff", "html"),
                       dpi = 600, width = NULL, height = NULL, overwrite = FALSE) {
  format<-match.arg(format); if(!is.character(path)||length(path)!=1L||!nzchar(path)) .apm_abort("{.arg path} must be a non-empty file path.")
  path<-path.expand(path); if(file.exists(path)&&!isTRUE(overwrite)) .apm_abort("Output already exists. Set {.arg overwrite=TRUE} to replace it.")
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  if(format=="rds") saveRDS(x,path,version=2)
  else if(format=="csv") utils::write.csv(.apm_export_table(x),path,row.names=FALSE,na="")
  else if(format=="xlsx") { .apm_require("openxlsx2","XLSX export"); openxlsx2::write_xlsx(.apm_export_table(x),file=path,overwrite=overwrite) }
  else if(format=="json") { .apm_require("jsonlite","JSON export"); jsonlite::write_json(.apm_export_table(x),path,pretty=TRUE,na="null",auto_unbox=TRUE) }
  else if(format %in% c("png","svg","tiff")) {
    if(!inherits(x,"ggplot")) .apm_abort("Graphical export requires a ggplot object.")
    if(!is.numeric(dpi)||length(dpi)!=1L||dpi<=0) .apm_abort("{.arg dpi} must be positive.")
    width<-width%||%7;height<-height%||%5
    ggplot2::ggsave(filename=path,plot=x,width=width,height=height,units="in",dpi=dpi,device=format)
  } else {
    if(inherits(x,"htmlwidget")) { .apm_require("htmlwidgets","HTML widget export"); htmlwidgets::saveWidget(x,path,selfcontained=TRUE) }
    else if(inherits(x,"ggplot")) { .apm_require("plotly","HTML plot export"); .apm_require("htmlwidgets","HTML plot export"); htmlwidgets::saveWidget(plotly::ggplotly(x),path,selfcontained=TRUE) }
    else .apm_abort("HTML export currently supports ggplot or htmlwidget objects.")
  }
  if(!file.exists(path)) .apm_abort("Export backend returned without creating the requested file.")
  ans<-normalizePath(path,winslash="/",mustWork=TRUE); attr(ans,"md5")<-unname(tools::md5sum(path));attr(ans,"format")<-format;attr(ans,"source_class")<-class(x)[1]
  invisible(ans)
}
