\name{apm_dose_response}
\alias{apm_dose_response}
\title{Fit correlated agronomic dose-response meta-analysis}
\description{Fits a true multi-dose treatment-control synthesis while respecting within-study covariance created by doses sharing a common reference. Random coefficient dose-response models use the optional \code{dosresmeta} backend. If it is unavailable, only the fixed-effect generalized least-squares route is provided through \code{metafor}; a random-intercept model is deliberately not presented as an equivalent substitute for random dose-response curves.}
\usage{apm_dose_response(data, effect, dose, study, V = NULL, form = c("linear", "quadratic", "ns"), df = 3, method = "reml", covariance = c("auto", "user"), reference = 0, moderators = NULL, ...)}
\arguments{
  \item{data}{Data frame or \code{apm_effects} containing effect sizes.}
  \item{effect}{Effect-size column, typically \code{yi} or \code{lnRR}.}
  \item{dose}{Quantitative dose column.}
  \item{study}{Study identifier.}
  \item{V}{Optional sampling covariance matrix corresponding to all input rows, all complete rows, or retained non-reference rows.}
  \item{form}{Dose-response form: linear, quadratic, or natural spline.}
  \item{df}{Natural-spline degrees of freedom.}
  \item{method}{\code{"reml"}, \code{"ml"}, or \code{"fixed"}.}
  \item{covariance}{\code{"auto"} reconstructs covariance from shared-arm metadata; \code{"user"} requires \code{V}.}
  \item{reference}{Reference dose, usually zero.}
  \item{moderators}{Optional study-level meta-regression formula for the \code{dosresmeta} backend.}
  \item{...}{Additional arguments passed to the selected backend.}
}
\value{An \code{apm_dose} object with covariance provenance, dose basis, original reference/analysis row indices, predictions, diagnostics, and backend object.}
\examples{
# Example 1: random-effects linear nitrogen curve when dosresmeta is available.
if (requireNamespace("dosresmeta", quietly=TRUE))
  apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
    study=study_id,form="linear")
# Example 2: fixed quadratic GLS preserving shared-control covariance.
apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
  study=study_id,form="quadratic",method="fixed")
# Example 3: flexible curve with a study-level moderator.
if (requireNamespace("dosresmeta", quietly=TRUE))
  apm_dose_response(fertilizer_dose_response,effect=lnRR,dose=N_rate,
    study=study_id,form="ns",df=3,moderators=~soil_texture)
}
\keyword{meta}
