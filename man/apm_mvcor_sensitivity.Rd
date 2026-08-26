\name{apm_mvcor_sensitivity}
\alias{apm_mvcor_sensitivity}
\title{Sensitivity to unknown outcome correlations}
\description{Refit multivariate models over a prespecified grid of within-study outcome correlations.}
\usage{apm_mvcor_sensitivity(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
s1 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(0,.5))
s2 <- apm_mvcor_sensitivity(biochar_multiresponse, outcome=outcome, study=study_id, rho=c(.25,.5,.75))
s3 <- apm_mvcor_sensitivity(soil_management_multiresponse, outcome=outcome, study=mv_study_id, rho=c(0,.3), fit_args=list(mods=~climate_zone))
}
