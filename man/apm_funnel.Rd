\name{apm_funnel}
\alias{apm_funnel}
\title{Draw standard or contour-enhanced funnel plots}
\description{Draw standard or contour-enhanced funnel plots. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_funnel(model, yaxis = c("se", "vi", "precision", "n"), contour = FALSE, levels = c(0.90, 0.95, 0.99), label = FALSE, interactive = FALSE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: standard funnel plot.
apm_funnel(apm_fit(agri_effects_benchmark))
# Example 2: contour-enhanced funnel plot.
apm_funnel(apm_fit(agri_effects_benchmark), contour=TRUE)
# Example 3: precision-axis interactive plot when plotly is available.
if (requireNamespace("plotly", quietly=TRUE)) apm_funnel(apm_fit(agri_effects_benchmark), yaxis="precision", interactive=TRUE)
}
