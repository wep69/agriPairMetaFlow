\name{apm_prior}
\alias{apm_prior}
\title{Backend-neutral Bayesian prior specification}
\description{Create an auditable prior specification that can be translated to supported Bayesian backends.}
\usage{apm_prior(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
p1 <- apm_prior(effect=list(dist="normal",mean=0,sd=.2))
p2 <- apm_prior(tau=list(dist="halfnormal",scale=.2))
p3 <- apm_prior(moderators=list(rainfall=list(dist="normal",mean=0,sd=.001)))
}
