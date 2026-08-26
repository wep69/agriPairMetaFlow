\name{apm_bayes_diagnostics}
\alias{apm_bayes_diagnostics}
\title{Bayesian computational diagnostics}
\description{Expose backend-appropriate convergence, effective-sample-size, Monte Carlo, and posterior predictive diagnostics.}
\usage{apm_bayes_diagnostics(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d1<-apm_bayes_diagnostics(b,plot=FALSE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d2<-apm_bayes_diagnostics(b,checks="convergence",plot=FALSE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b<-apm_bayes(agri_effects_benchmark,backend="bayesmeta"); d3<-apm_bayes_diagnostics(b,checks="ppc",plot=TRUE) }
}
