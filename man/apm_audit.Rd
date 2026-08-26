\name{apm_audit}
\alias{apm_audit}
\title{Audit agronomic meta-analysis data and design semantics}
\description{Audit agronomic meta-analysis data and design semantics. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_audit(data, plan = NULL, level = c("basic", "full"), repair = FALSE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: detect shared controls in nitrogen experiments.
apm_audit(maize_n_shared, level = "full")
# Example 2: identify heterogeneous uncertainty reporting.
apm_audit(agri_uncertainty_mixed, level = "full")
# Example 3: audit multiresponse soil-management summaries.
apm_audit(soil_management_multiresponse, level = "basic")
}
