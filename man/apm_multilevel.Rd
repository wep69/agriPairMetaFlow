\name{apm_multilevel}
\alias{apm_multilevel}
\title{Multilevel meta-analysis}
\usage{
apm_multilevel(effects, random = ~1 | study_id/effect_id, V = NULL, mods = ~1, struct = "CS", method = "REML", test = "t", dfs = c("contain", "residual"), ...)
}
\description{
Fits hierarchical meta-analytic models using metafor::rma.mv().
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
V <- apm_vcov(es,cluster=experiment_id)
apm_multilevel(es,random=~1|study_id/effect_id,V=V,test="z")
apm_multilevel(es,random=~1|study_id,V=V,test="t")

apm_multilevel(es,random=~1|study_id,V=V,test="z")
}
