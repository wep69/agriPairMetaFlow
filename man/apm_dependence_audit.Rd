\name{apm_dependence_audit}
\alias{apm_dependence_audit}
\title{Audit effect-size dependence}
\usage{
apm_dependence_audit(effects, plan = NULL, V = NULL, cluster = NULL)
}
\description{
Summarizes repeated clusters, shared controls, repeated outcomes/times, and whether supplied covariance information addresses sampling dependence.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_dependence_audit(es,cluster=study_id)
V <- apm_vcov(es,cluster=experiment_id)
apm_dependence_audit(es,V=V,cluster=study_id)

apm_dependence_audit(es)
}
