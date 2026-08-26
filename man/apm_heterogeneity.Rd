\name{apm_heterogeneity}
\alias{apm_heterogeneity}
\title{Summarize heterogeneity and its uncertainty}
\description{Summarize heterogeneity and its uncertainty. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_heterogeneity(model, ci = TRUE, level = 0.95, method_ci = c("auto", "profile", "QP"))
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: heterogeneity of benchmark lnRR effects.
apm_heterogeneity(apm_fit(agri_effects_benchmark))
# Example 2: heterogeneity of CVR effects.
ev <- apm_effect_size(covercrop_variability,"CVR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_heterogeneity(apm_fit(ev))
# Example 3: heterogeneity after a rainfall moderator.
apm_heterogeneity(apm_fit(agri_effects_benchmark, mods=~rainfall, model="mixed"))
}
