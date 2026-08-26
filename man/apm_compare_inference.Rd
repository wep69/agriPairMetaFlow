\name{apm_compare_inference}
\alias{apm_compare_inference}
\title{Compare inferential approaches}
\usage{
apm_compare_inference(model, robust = NULL, wild = NULL, methods = c("model", "CR2", "wild"), transform = c("auto", "none", "exp", "percent"))
}
\description{
Aligns conventional, robust, and wild-bootstrap results without automatically selecting the most favorable inference.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
fit <- apm_fit(es,mods=~rainfall)
apm_compare_inference(fit,methods="model")
apm_compare_inference(apm_fit(es),methods="model",transform="percent")

apm_compare_inference(fit,methods="model",transform="exp")
}
