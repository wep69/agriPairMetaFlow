\name{apm_marginal_effects}
\alias{apm_marginal_effects}
\title{Adjusted marginal effects from agronomic meta-regression}
\description{Computes standardized marginal predictions by averaging the fitted meta-regression design matrix over the observed study distribution while setting selected moderators to explicit levels or values.}
\usage{apm_marginal_effects(model, variables = NULL, at = NULL, weights = c("equal", "study"), transform = c("auto", "none", "exp", "percent"), level = 0.95)}
\arguments{
  \item{model}{An `apm_metareg` model.}
  \item{variables}{Moderator names to summarize. Numeric moderators require explicit values in `at`.}
  \item{at}{Named list of moderator values at which marginal predictions are evaluated.}
  \item{weights}{Marginalization rule: equal effect-level weights or equal study-level weights.}
  \item{transform}{Output transformation.}
  \item{level}{Confidence level.}
}
\value{An `apm_marginal` object with adjusted estimates and uncertainty.}
\examples{
# Example 1: crop-adjusted inoculant response.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_m <- apm_metareg(bio_es, ~ crop + site)
apm_marginal_effects(bio_m, variables="crop", transform="percent")
# Example 2: irrigation response at three rainfall contexts.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_m <- apm_metareg(irr_es, ~ rainfall * climate_zone)
apm_marginal_effects(irr_m, at=list(rainfall=c(600,900,1200)))
# Example 3: equal-study weighting with shared-control nitrogen effects.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_m <- apm_metareg(mz_es,~N_rate+soil_texture,V=mz_V,random=~1|study_id/effect_id)
apm_marginal_effects(mz_m,variables="soil_texture",weights="study")
}
\keyword{meta}
