\name{apm_bayes_threshold}
\alias{apm_bayes_threshold}
\title{Bayesian agronomic relevance probability}
\description{Calculate posterior or predictive probability relative to a user-defined agronomic threshold without automatic decisions.}
\usage{apm_bayes_threshold(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t1<-apm_bayes_threshold(b,5,scale="percent") }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t2<-apm_bayes_threshold(b,10,scale="percent",predictive=TRUE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); t3<-apm_bayes_threshold(b,0,rope=c(-.05,.05)) }
}
