\name{apm_shared_control}
\alias{apm_shared_control}
\title{Detect reused controls}
\usage{
apm_shared_control(data, study, control_id, treatment_id = NULL, effect_id = NULL, check_values = TRUE)
}
\description{
Detects treatment contrasts that reuse a control arm within a study or experiment and reports multiplicity and inconsistent duplicated control summaries.
}
\value{A structured agriPairMetaFlow object retaining assumptions and provenance.}
\examples{
apm_shared_control(maize_n_shared, study=experiment_id, control_id=control)
apm_shared_control(fertilizer_dose_response, study=study_id, control_id=control_id, treatment_id=dose_id)
apm_shared_control(soil_management_multiresponse, study=study_id, control_id=control, treatment_id=outcome)
}
