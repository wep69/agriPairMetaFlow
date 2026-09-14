\name{apm_prediction}
\alias{apm_prediction}
\title{Obtain confidence and prediction intervals}
\description{Obtain confidence and prediction intervals. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_prediction(model, newdata = NULL, level = 0.95, method = c("model"), transform = c("auto", "none", "exp", "percent"), threshold = NULL, ...)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: pooled prediction expressed as percent change.
apm_prediction(apm_fit(agri_effects_benchmark), transform="percent")
# Example 2: rainfall-specific predictions.
fm <- apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed")
apm_prediction(fm, newdata=data.frame(rainfall=c(600,900,1200)))
# Example 3: ratio-scale prediction.
apm_prediction(apm_fit(agri_effects_benchmark), transform="exp")
}
