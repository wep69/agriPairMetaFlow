\name{apm_dose_plot}
\alias{apm_dose_plot}
\title{Plot an agronomic dose-response meta-analysis}
\description{Draws the fitted dose-response curve together with observed effects, the confidence band, an optional prediction band when estimable, and a rug that makes the observed dose support explicit.}
\usage{apm_dose_plot(model, transform = c("auto", "none", "exp", "percent"), observed = TRUE, prediction = TRUE, rug = TRUE, interactive = FALSE)}
\arguments{
  \item{model}{An `apm_dose` object.}
  \item{transform}{Output transformation.}
  \item{observed}{Show observed study-level effects.}
  \item{prediction}{Show prediction interval when available.}
  \item{rug}{Show observed dose support on the x axis.}
  \item{interactive}{Return a plotly object.}
}
\value{A `ggplot` or `plotly` object with `apm_plot_data` attached.}
\examples{
# Example 1: nitrogen response expressed as percent change.
d1 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
study=study_id,form="linear",method="fixed")
apm_dose_plot(d1,transform="percent")
# Example 2: quadratic curve with the prediction band when identifiable.
d2 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
study=study_id,form="quadratic",method="fixed")
apm_dose_plot(d2,prediction=TRUE)
# Example 3: interactive natural-spline display when plotly is available.
if(requireNamespace("plotly",quietly=TRUE)) {
d3 <- apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
study=study_id,form="ns",df=3,method="fixed")
apm_dose_plot(d3,interactive=TRUE)
}
}
\keyword{meta}
