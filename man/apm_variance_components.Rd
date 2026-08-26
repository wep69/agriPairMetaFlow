\name{apm_variance_components}
\alias{apm_variance_components}
\title{Extract variance components}
\usage{
apm_variance_components(model, level = 0.95, proportion = TRUE)
}
\description{
Extracts multilevel heterogeneity components and optionally expresses them as proportions of modeled heterogeneity.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
ml <- apm_multilevel(es,random=~1|study_id/effect_id,V=apm_vcov(es,cluster=experiment_id),test="z")
apm_variance_components(ml)
apm_variance_components(ml,proportion=FALSE)

apm_variance_components(ml,level=.90)
}
