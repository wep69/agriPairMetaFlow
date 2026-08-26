\name{apm_predict_context}
\alias{apm_predict_context}
\title{Predict treatment effects for explicit agronomic contexts}
\description{Generates model-based predictions for combinations of quantitative and qualitative agronomic moderators, labels interpolation versus extrapolation, and optionally evaluates a practical-effect threshold. Predictive threshold probabilities are returned only when the relevant heterogeneity variance is identifiable; the function does not guess a predictive variance for ambiguous multilevel structures.}
\usage{apm_predict_context(model, newdata, level = 0.95, prediction = TRUE, threshold = NULL, transform = c("auto", "none", "exp", "percent"))}
\arguments{
  \item{model}{An \code{apm_metareg} or \code{apm_curve} object.}
  \item{newdata}{Data frame containing moderator contexts.}
  \item{level}{Confidence level.}
  \item{prediction}{Include a prediction interval where supported by the fitted backend.}
  \item{threshold}{Optional practical threshold on the displayed output scale.}
  \item{transform}{Output transformation.}
}
\value{An \code{apm_prediction} retaining context columns, support flags, and the basis used for any threshold probability.}
\examples{
# Example 1: expected irrigation effect at 800 mm rainfall and 24 C.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_m <- apm_metareg(irr_es,~rainfall+mean_temp)
apm_predict_context(irr_m,data.frame(rainfall=800,mean_temp=24))
# Example 2: crop/site context for an inoculant.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_m <- apm_metareg(bio_es,~crop+site)
apm_predict_context(bio_m,data.frame(crop="maize",site="Areia"),transform="percent")
# Example 3: practical 5 percent threshold along an N-rate curve.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
  m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_curve <- apm_metareg_curve(mz_es,N_rate,"quadratic")
apm_predict_context(mz_curve,data.frame(N_rate=c(60,120)),threshold=5,transform="percent")
}
\keyword{meta}
