\name{apm_multivariate_plot}
\alias{apm_multivariate_plot}
\title{Multivariate meta-analysis plots}
\description{Create outcome-specific, correlation, or prediction-oriented figures from multivariate models.}
\usage{apm_multivariate_plot(...)}
\arguments{\item{...}{Arguments documented in the function source. Regenerate this manual with roxygen2 during local validation.}}
\value{An auditable agriPairMetaFlow result object; see the corresponding class documentation and vignettes.}
\examples{
if (requireNamespace("metafor",quietly=TRUE)) { m<-apm_multivariate(soil_management_multiresponse,outcome=outcome,study=mv_study_id,V=diag(soil_management_multiresponse$vi)); p1<-apm_multivariate_plot(m,"outcome_forest") }
if (requireNamespace("metafor",quietly=TRUE)) { m<-apm_multivariate(soil_management_multiresponse,outcome=outcome,study=mv_study_id,V=diag(soil_management_multiresponse$vi)); if(!is.null(m$between_cor)) p2<-apm_multivariate_plot(m,"correlation") }
if (requireNamespace("metafor",quietly=TRUE)) { m<-apm_multivariate(biochar_multiresponse,outcome=outcome,study=study_id,V=diag(biochar_multiresponse$vi)); p3<-apm_multivariate_plot(m,"prediction") }
}
