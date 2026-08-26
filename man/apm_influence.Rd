\name{apm_influence}
\alias{apm_influence}
\title{Diagnose influential effects or studies}
\description{Development-snapshot manual for apm_influence. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_influence(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: Baujat diagnostic for independent agronomic studies.
apm_influence(apm_fit(agri_effects_benchmark), plot_type="baujat")
# Example 2: classical influence diagnostics.
apm_influence(apm_fit(agri_effects_benchmark), plot_type="influence")
# Example 3: radial diagnostic for the same fitted evidence base.
apm_influence(apm_fit(agri_effects_benchmark), metrics=c("cook","leverage"), plot_type="radial")
}
