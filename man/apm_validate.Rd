\name{apm_validate}
\alias{apm_validate}
\title{Validate study summaries, binary data, or precomputed effects}
\description{Validate study summaries, binary data, or precomputed effects. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_validate(data, schema = c("summary", "binary", "effect"), roles = NULL, strict = TRUE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: continuous treatment-control summaries.
apm_validate(maize_n_shared, schema = "summary", strict = FALSE)
# Example 2: binary pest-suppression data.
apm_validate(pest_suppression_binary, schema = "binary", strict = FALSE)
# Example 3: precomputed effect sizes.
apm_validate(agri_effects_benchmark, schema = "effect", strict = FALSE)
}
