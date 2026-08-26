\name{apm_bayes_compare}
\alias{apm_bayes_compare}
\title{Compare prespecified Bayesian models}
\description{Compare compatible Bayesian models using predictive criteria or inspect posterior model probabilities from a RoBMA ensemble.}
\usage{apm_bayes_compare(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (FALSE) apm_bayes_compare(b1,b2,criterion="loo")
if (FALSE) apm_bayes_compare(b1,b2,criterion="waic")
if (FALSE) apm_bayes_compare(robma_fit,criterion="model_probability")
}
