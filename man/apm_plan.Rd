\name{apm_plan}
\alias{apm_plan}
\title{Plan the treatment-control estimand and experimental hierarchy}
\description{Plan the treatment-control estimand and experimental hierarchy. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_plan(data, study, treatment, control, response = NULL, experiment = NULL, effect_id = NULL, dose = NULL, site = NULL, year = NULL, outcome = NULL, block = NULL, time = NULL, cluster = NULL, units = NULL, design = c("auto", "independent", "paired"))
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: shared-control nitrogen-rate experiments.
apm_plan(maize_n_shared, study=study_id, experiment=experiment_id,
  treatment=treatment, control=control, response=mean_t, dose=N_rate,
  site=site, year=year)
# Example 2: genuinely paired block summaries.
apm_plan(wheat_paired_blocks, study=study_id, treatment=treatment,
  control=control, response=mean_t, block=block_id, design="paired")
# Example 3: multicrop inoculant evidence.
apm_plan(bioinoculant_multicrop, study=study_id, treatment=treatment,
  control=control, response=mean_t, outcome=outcome, site=site)
}
