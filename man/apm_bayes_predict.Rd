\name{apm_bayes_predict}
\alias{apm_bayes_predict}
\title{Bayesian posterior and predictive summaries}
\description{Obtain posterior mean-effect or new-study predictive distributions with explicit target labels.}
\usage{apm_bayes_predict(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); p1 <- apm_bayes_predict(b,predictive=FALSE) }
if (requireNamespace("bayesmeta",quietly=TRUE)) { b <- apm_bayes(agri_effects_benchmark,backend="bayesmeta"); p2 <- apm_bayes_predict(b,predictive=TRUE,transform="percent") }
if (requireNamespace("bayesmeta",quietly=TRUE)) { es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c); es$rainfall <- irrigation_climate$rainfall; b <- apm_bayes(es,mods=~rainfall,backend="bayesmeta"); p3 <- apm_bayes_predict(b,newdata=data.frame(rainfall=900)) }
}
