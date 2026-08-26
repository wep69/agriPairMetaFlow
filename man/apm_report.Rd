\name{apm_report}
\alias{apm_report}
\title{Render a reproducible meta-analysis report without refitting the model}
\description{Development-snapshot manual for apm_report. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_report(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: HTML report from a fitted agronomic meta-analysis.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html")
# Example 2: reduced section inventory.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html", sections=c("model","prediction","plots"))
# Example 3: explicit title and reproducibility seed.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), title="Agronomic treatment-control synthesis", seed=2026)
}
