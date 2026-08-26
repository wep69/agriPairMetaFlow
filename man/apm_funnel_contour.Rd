\name{apm_funnel_contour}
\alias{apm_funnel_contour}
\title{Draw a contour-enhanced funnel plot}
\description{Development-snapshot manual for apm_funnel_contour. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_funnel_contour(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: conventional 90/95/99 percent contours.
apm_funnel_contour(apm_fit(agri_effects_benchmark))
# Example 2: focus on the 95 percent reference contour.
apm_funnel_contour(apm_fit(agri_effects_benchmark), levels=.95)
# Example 3: label studies for a diagnostic review.
apm_funnel_contour(apm_fit(agri_effects_benchmark), label=TRUE)
}
