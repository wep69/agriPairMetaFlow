\name{apm_capabilities}
\alias{apm_capabilities}
\title{Report agriPairMetaFlow capabilities and optional backends}
\description{Reports the stable feature registry, backend policy, installation state, and validation tier without installing software.}
\usage{apm_capabilities(feature = NULL, installed = TRUE, detail = c("summary", "full"))}
\arguments{\item{feature}{Optional exact feature filter.}\item{installed}{Inspect local installation state.}\item{detail}{Summary or full registry.}}
\value{An apm_capabilities data frame.}
\examples{
# Example 1: complete registry.
apm_capabilities()
# Example 2: Bayesian capability routes.
apm_capabilities("bayesian", detail="full")
# Example 3: dose-response backend state.
apm_capabilities("dose-response", installed=TRUE)
}
