\name{apm_bias}
\alias{apm_bias}
\title{Diagnose small-study effects and publication-bias sensitivity}
\description{Development-snapshot manual for apm_bias. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_bias(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: funnel-asymmetry diagnostics.
apm_bias(apm_fit(agri_effects_benchmark), methods=c("egger","rank"))
# Example 2: two sensitivity models, without treating either as truth.
apm_bias(apm_fit(agri_effects_benchmark), methods=c("trimfill","selection"))
# Example 3: S-value when PublicationBias is installed.
if (requireNamespace("PublicationBias",quietly=TRUE)) apm_bias(apm_fit(agri_effects_benchmark), methods="svalue", q=0, favor="positive")
}
