\name{apm_subgroup}
\alias{apm_subgroup}
\title{Fit prespecified subgroup meta-analyses}
\description{Fit prespecified subgroup meta-analyses. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_subgroup(effects, subgroup, method = "REML", test = "knha", interaction_test = TRUE, min_studies = 2, ...)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: inoculant effects by crop.
e1 <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_subgroup(e1, crop)
# Example 2: irrigation effects by climate zone.
e2 <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_subgroup(e2, climate_zone)
# Example 3: benchmark effects by soil texture.
apm_subgroup(agri_effects_benchmark, soil_texture, interaction_test=TRUE)
}
