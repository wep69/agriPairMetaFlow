\name{apm_export}
\alias{apm_export}
\title{Export tables, models, figures, and reproducible objects}
\description{Development-snapshot manual for apm_export. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_export(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: reproducible model object.
apm_export(apm_fit(agri_effects_benchmark), tempfile(fileext=".rds"), format="rds", overwrite=TRUE)
# Example 2: numeric-preserving CSV table.
apm_export(apm_table(apm_fit(agri_effects_benchmark)), tempfile(fileext=".csv"), format="csv", overwrite=TRUE)
# Example 3: publication-resolution forest figure.
apm_export(apm_forest(apm_fit(agri_effects_benchmark)), tempfile(fileext=".tiff"), format="tiff", dpi=600, overwrite=TRUE)
}
