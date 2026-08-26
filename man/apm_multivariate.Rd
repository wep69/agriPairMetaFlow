\name{apm_multivariate}
\alias{apm_multivariate}
\title{Multivariate treatment-control meta-analysis}
\description{Jointly synthesize multiple agronomic outcomes while preserving sampling covariance and between-outcome heterogeneity.}
\usage{apm_multivariate(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
V <- diag(soil_management_multiresponse$vi); m1 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V)
m2 <- apm_multivariate(soil_management_multiresponse, outcome=outcome, study=mv_study_id, V=V, mods=~climate_zone)
if (requireNamespace("mixmeta", quietly=TRUE)) m3 <- apm_multivariate(biochar_multiresponse, outcome=outcome, study=study_id, V=diag(biochar_multiresponse$vi), backend="mixmeta")
}
