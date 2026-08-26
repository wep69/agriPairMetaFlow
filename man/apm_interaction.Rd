\name{apm_interaction}
\alias{apm_interaction}
\title{Interpret prespecified meta-regression interactions}
\description{Converts interaction coefficients into simple slopes or adjusted contrasts on scientifically interpretable moderator scales. Simple-effect p-values and joint tests follow the fitted model's t-based versus normal inference mode.}
\usage{apm_interaction(model, term, at = NULL, contrast = c("difference", "ratio"), adjust = "none", level = 0.95)}
\arguments{
  \item{model}{An `apm_metareg` model containing the requested interaction.}
  \item{term}{Interaction term, such as `"rainfall:climate_zone"`.}
  \item{at}{Optional named list defining values for continuous moderators.}
  \item{contrast}{`"difference"` on the model scale or `"ratio"` for log-ratio estimands.}
  \item{adjust}{Multiplicity adjustment from `stats::p.adjust.methods`.}
  \item{level}{Confidence level.}
}
\value{An `apm_interaction` object with simple effects, contrasts, and an interaction-specific joint Wald test.}
\examples{
# Example 1: rainfall slope by climate zone.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irr_i <- apm_metareg(irr_es,~rainfall*climate_zone)
apm_interaction(irr_i,"rainfall:climate_zone",at=list(rainfall=c(600,900)))
# Example 2: crop by site interaction for inoculant response.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_i <- apm_metareg(bio_es,~crop*site)
apm_interaction(bio_i,"crop:site",adjust="holm")
# Example 3: nitrogen slope by soil texture with dependent contrasts.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_i <- apm_metareg(mz_es,~N_rate*soil_texture,V=mz_V,random=~1|study_id/effect_id)
apm_interaction(mz_i,"N_rate:soil_texture",contrast="ratio")
}
\keyword{meta}
