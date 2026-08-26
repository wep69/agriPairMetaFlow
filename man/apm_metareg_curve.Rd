\name{apm_metareg_curve}
\alias{apm_metareg_curve}
\title{Fit quantitative moderator curves in meta-regression}
\description{Fits linear, hierarchical polynomial, natural-spline, or restricted-cubic- spline relationships between a treatment-control effect and a quantitative agronomic moderator. Curves describe across-study effect modification and are not automatically causal treatment-dose recommendations.}
\usage{apm_metareg_curve(effects, x, form = c("linear", "quadratic", "cubic", "ns", "rcs"), df = 3, knots = NULL, V = NULL, random = NULL, method = "REML", level = 0.95, grid = 100)}
\arguments{
  \item{effects}{Effect-size data containing `yi` and `vi`.}
  \item{x}{Quantitative moderator column.}
  \item{form}{Functional form: linear, quadratic, cubic, natural spline (`ns`), or restricted cubic spline (`rcs`).}
  \item{df}{Basis degrees of freedom for spline forms.}
  \item{knots}{Optional internal knots. For `rcs`, at least four unique knots are required; otherwise deterministic quantile knots are generated.}
  \item{V}{Optional sampling covariance matrix.}
  \item{random}{Optional random-effects formula for dependent effects.}
  \item{method}{Heterogeneity estimator.}
  \item{level}{Confidence level used for the stored prediction grid.}
  \item{grid}{Number of grid points across observed moderator support.}
}
\value{An `apm_curve` object inheriting from `apm_metareg` and `apm_model`.}
\examples{
# Example 1: linear rainfall effect modification.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_metareg_curve(irr_es,rainfall,form="linear")
# Example 2: quadratic rainfall relationship with hierarchy preserved.
apm_metareg_curve(irr_es,rainfall,form="quadratic")
# Example 3: nonlinear N-rate association with shared-control covariance.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
apm_metareg_curve(mz_es,N_rate,form="ns",df=3,V=mz_V,
random=~1|study_id/effect_id)
}
\keyword{meta}
