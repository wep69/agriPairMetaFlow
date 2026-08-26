\name{apm_threshold}
\alias{apm_threshold}
\title{Evaluate a user-defined agronomic relevance threshold}
\description{Evaluate a user-defined agronomic relevance threshold. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_threshold(model, threshold, scale = c("model", "ratio", "percent", "absolute"), direction = c("greater", "less", "two-sided"), prediction = TRUE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: at least five percent improvement.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=5, scale="percent")
# Example 2: ratio of means at least 1.10.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=1.10, scale="ratio", direction="greater")
# Example 3: a model-scale threshold in the adverse direction.
apm_threshold(apm_fit(agri_effects_benchmark), threshold=0, scale="model", direction="less")
}
