\name{apm_metareg}
\alias{apm_metareg}
\title{Fit agronomic meta-regression models}
\description{Fits mixed-effects meta-regression while retaining moderator support, centering/scaling constants, factor reference levels, residual heterogeneity, and a transparent meta-analytic R-squared descriptor. Continuous moderators are centered by default so the intercept is evaluated at their observed mean.}
\usage{apm_metareg(effects, moderators, V = NULL, random = NULL, method = "REML", test = "t", center = TRUE, scale = FALSE, interactions = NULL, ...)}
\arguments{
  \item{effects}{`apm_effects` or a data frame containing `yi` and `vi`.}
  \item{moderators}{One-sided moderator formula, for example `~ rainfall + crop`.}
  \item{V}{Optional sampling variance-covariance matrix.}
  \item{random}{Optional random-effects formula. Supplying `V` or `random` routes the fit through `metafor::rma.mv()`.}
  \item{method}{Heterogeneity estimator, default `"REML"`.}
  \item{test}{Inference method supported by the selected `metafor` backend.}
  \item{center}{Center numeric moderators before fitting.}
  \item{scale}{Scale numeric moderators by their SD after centering.}
  \item{interactions}{Optional character vector of prespecified interaction terms to add to `moderators`.}
  \item{...}{Additional arguments passed to `metafor::rma.uni()` or `metafor::rma.mv()`.}
}
\value{An `apm_metareg` object inheriting from `apm_model`.}
\examples{
# Example 1: rainfall and temperature as quantitative moderators.
irrig_es <- apm_effect_size(irrigation_climate, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_metareg(irrig_es, ~ rainfall + mean_temp)
# Example 2: adjusted crop differences for an inoculant treatment.
bio_es <- apm_effect_size(bioinoculant_multicrop, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_metareg(bio_es, ~ crop + site)
# Example 3: dependence-aware nitrogen meta-regression.
maize_es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t,
n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
maize_V <- apm_vcov(maize_es, cluster=experiment_id)
apm_metareg(maize_es, ~ N_rate + soil_texture, V=maize_V,
random=~1|study_id/effect_id)
}
\keyword{meta}
