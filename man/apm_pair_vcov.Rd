\name{apm_pair_vcov}
\alias{apm_pair_vcov}
\title{Paired/repeated covariance}
\usage{
apm_pair_vcov(effects, pair_id, r, structure = c("paired", "compound", "user"), user_V = NULL)
}
\description{
Builds covariance matrices for genuinely paired, matched, or repeated effect sizes.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(wheat_paired_blocks,"lnRR",design="paired",m_t=mean_t,sd_t=sd_t,n_t=n_pairs,m_c=mean_c,sd_c=sd_c,n_c=n_pairs,r=r_tc)
apm_pair_vcov(es,pair_id=study_id,r=.6)
apm_pair_vcov(es,pair_id=study_id,r=.4,structure="compound")

apm_pair_vcov(es,pair_id=study_id,r=.8)
}
