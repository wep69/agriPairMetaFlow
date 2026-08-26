\name{apm_orchard}
\alias{apm_orchard}
\title{Draw orchard-style summaries of agronomic meta-analysis}
\description{Development-snapshot manual for apm_orchard. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_orchard(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: overall yield response on the percentage scale.
apm_orchard(apm_fit(agri_effects_benchmark), transform="percent")
# Example 2: raw-effect display can be disabled.
apm_orchard(apm_fit(agri_effects_benchmark), raw_effects=FALSE)
# Example 3: retain CIs while suppressing prediction intervals.
apm_orchard(apm_fit(agri_effects_benchmark), prediction=FALSE)
}
