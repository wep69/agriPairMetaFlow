\name{apm_curve_features}
\alias{apm_curve_features}
\title{Extract interpretable features from quantitative moderator curves}
\description{Computes local slopes, within-support turning points, and practical-threshold crossings from an `apm_curve`. These are descriptive meta-regression features; they are not presented as causal agronomic optima unless the underlying evidence and design justify that interpretation.}
\usage{apm_curve_features(curve, features = c("slope", "turning_point", "threshold_crossing"), threshold = NULL, interval = TRUE, level = 0.95)}
\arguments{
  \item{curve}{An `apm_curve`.}
  \item{features}{Any of `"slope"`, `"turning_point"`, and `"threshold_crossing"`.}
  \item{threshold}{Threshold on the model/effect-size scale, required for threshold crossings.}
  \item{interval}{Include uncertainty descriptors.}
  \item{level}{Confidence level.}
}
\value{An `apm_curve_features` object.}
\examples{
# Example 1: slopes and turning point of a quadratic rainfall curve.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irrig_quad <- apm_metareg_curve(irr_es,rainfall,"quadratic")
apm_curve_features(irrig_quad,c("slope","turning_point"))
# Example 2: N rate where the fitted effect crosses a 5% benefit threshold.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
maize_ns <- apm_metareg_curve(mz_es,N_rate,"ns",df=3)
apm_curve_features(maize_ns,"threshold_crossing",threshold=log(1.05))
# Example 3: local slope pattern for a natural-spline rainfall model.
irrig_ns <- apm_metareg_curve(irr_es,rainfall,"ns",df=3)
apm_curve_features(irrig_ns,"slope")
}
\keyword{meta}
