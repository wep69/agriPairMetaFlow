\name{apm_rho_sensitivity}
\alias{apm_rho_sensitivity}
\title{Correlation sensitivity analysis}
\usage{
apm_rho_sensitivity(effects, rho = seq(0, 0.9, 0.1), build_vcov, fit = NULL, metric = c("estimate", "se", "ci", "pi", "tau2"), ...)
}
\description{
Refits covariance and synthesis across a transparent grid of plausible correlations without selecting a preferred value.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(soil_management_multiresponse,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_rho_sensitivity(es,rho=c(.25,.5,.75),build_vcov=list(cluster="study_id",type="outcome"))
apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")

apm_rho_sensitivity(es,rho=c(.2,.8),build_vcov=list(cluster="study_id",type="outcome"),metric="se")
}
