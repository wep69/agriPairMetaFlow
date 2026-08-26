\name{apm_bayes}
\alias{apm_bayes}
\title{Bayesian pairwise meta-analysis}
\description{Fit Bayesian normal-normal, meta-regression, robust model-averaged, or multilevel models through registered backends.}
\usage{apm_bayes(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (requireNamespace("bayesmeta",quietly=TRUE)) b1 <- apm_bayes(agri_effects_benchmark,backend="bayesmeta")
if (requireNamespace("bayesmeta",quietly=TRUE)) { es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); es$rainfall <- irrigation_climate$rainfall; b2 <- apm_bayes(es,mods=~rainfall,backend="bayesmeta") }
if (requireNamespace("RoBMA",quietly=TRUE) && requireNamespace("BayesTools",quietly=TRUE)) b3 <- apm_bayes(agri_effects_benchmark,backend="RoBMA",seed=1)
}
