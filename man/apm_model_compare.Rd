\name{apm_model_compare}
\alias{apm_model_compare}
\title{Compare prespecified meta-regression models}
\description{Compares compatible candidate models without automatic stepwise selection. When fixed-effect design matrices differ, likelihood criteria are calculated from ML refits by default. Nesting is assessed from fixed-effect column spaces rather than coefficient labels, protecting comparisons of spline bases with similar names but different knots.}
\usage{apm_model_compare(..., criterion = c("AICc", "AIC", "BIC", "LRT"), refit_ml = TRUE, weights = TRUE)}
\arguments{
  \item{...}{Two or more \code{apm_model} objects fitted to the same effects.}
  \item{criterion}{\code{"AICc"}, \code{"AIC"}, \code{"BIC"}, or \code{"LRT"}.}
  \item{refit_ml}{Refit REML candidate models by maximum likelihood when fixed-effect design matrices differ.}
  \item{weights}{Calculate normalized information-criterion weights.}
}
\value{An \code{apm_model_comparison} with criteria, deltas, weights, fixed-design hashes, column-space nesting information, and provenance.}
\examples{
# Example 1: linear versus quadratic rainfall association.
irr_es <- apm_effect_size(irrigation_climate,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
irrig_lin <- apm_metareg_curve(irr_es,rainfall,"linear")
irrig_quad <- apm_metareg_curve(irr_es,rainfall,"quadratic")
apm_model_compare(irrig_lin,irrig_quad,criterion="AICc")
# Example 2: linear versus spline N-rate relationship.
mz_es <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,
  m_c=mean_c,sd_c=sd_c,n_c=n_c)
mz_V <- apm_vcov(mz_es,cluster=experiment_id)
mz_lin <- apm_metareg_curve(mz_es,N_rate,"linear",V=mz_V,random=~1|study_id/effect_id)
mz_ns <- apm_metareg_curve(mz_es,N_rate,"ns",df=3,V=mz_V,random=~1|study_id/effect_id)
apm_model_compare(mz_lin,mz_ns,criterion="AIC")
# Example 3: main effects versus a prespecified crop-by-site interaction.
bio_es <- apm_effect_size(bioinoculant_multicrop,"lnRR",m_t=mean_t,sd_t=sd_t,
  n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
bio_main <- apm_metareg(bio_es,~crop+site)
bio_int <- apm_metareg(bio_es,~crop*site)
apm_model_compare(bio_main,bio_int,criterion="LRT")
}
\keyword{meta}
