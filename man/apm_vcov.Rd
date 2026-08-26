\name{apm_vcov}
\alias{apm_vcov}
\title{Construct sampling covariance}
\usage{
apm_vcov(effects, cluster, subgroup = NULL, obs = NULL, type = NULL, time1 = NULL, time2 = NULL, rho = NULL, phi = NULL, shared_control = TRUE, near_pd = FALSE, sparse = FALSE)
}
\description{
Constructs a variance-covariance matrix for dependent effect sizes using explicit dependency descriptors and metafor::vcalc().
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t, m_c=mean_c, sd_c=sd_c, n_c=n_c)
apm_vcov(es, cluster=experiment_id)
es2 <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_vcov(es2,cluster=study_id,type=outcome,rho=.5,shared_control=FALSE)

apm_vcov(es, cluster=study_id, rho=.3, shared_control=FALSE)
}
