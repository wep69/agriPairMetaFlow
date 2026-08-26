\name{apm_gosh}
\alias{apm_gosh}
\title{Explore heterogeneity across model subsets with GOSH diagnostics}
\description{Development-snapshot manual for apm_gosh. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_gosh(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: lightweight pedagogical GOSH run.
apm_gosh(apm_fit(agri_effects_benchmark), subsets=100, seed=1, plot=FALSE)
# Example 2: visual subset exploration.
apm_gosh(apm_fit(agri_effects_benchmark), subsets=120, seed=2, plot=TRUE)
# Example 3: another reproducible subset sample.
apm_gosh(apm_fit(agri_effects_benchmark), subsets=80, seed=3, plot=FALSE)
}
