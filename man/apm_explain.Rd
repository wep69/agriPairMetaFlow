\name{apm_explain}
\alias{apm_explain}
\title{Explain agriPairMetaFlow results with deterministic scientific rules}
\description{Development-snapshot manual for apm_explain. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_explain(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: scientific interpretation of pooled yield response.
apm_explain(apm_fit(agri_effects_benchmark), audience="scientific", transform="percent")
# Example 2: teaching interpretation of heterogeneity.
apm_explain(apm_heterogeneity(apm_fit(agri_effects_benchmark)), audience="teaching")
# Example 3: extension-oriented wording without hiding uncertainty.
apm_explain(apm_fit(agri_effects_benchmark), audience="extension", transform="percent")
}
