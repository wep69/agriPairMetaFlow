\name{apm_wild_bootstrap}
\alias{apm_wild_bootstrap}
\title{Cluster wild bootstrap}
\usage{
apm_wild_bootstrap(model, cluster, constraints = NULL, R = 9999, seed = NULL, type = c("Rademacher", "Mammen"), parallel = FALSE)
}
\description{
Performs cluster wild-bootstrap Wald tests through wildmeta and records Monte Carlo uncertainty and reproducibility settings.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
\dontrun{
es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
fit <- apm_fit(es,mods=~rainfall)
apm_wild_bootstrap(fit,cluster=study_id,constraints=2,R=499,seed=42)
apm_wild_bootstrap(fit,cluster=study_id,R=499,seed=7,type="Mammen")
}

apm_wild_bootstrap(fit,cluster=study_id,constraints=2,R=499,seed=11,type="Rademacher")
}
