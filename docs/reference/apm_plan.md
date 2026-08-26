# Plan the treatment-control estimand and experimental hierarchy

Plan the treatment-control estimand and experimental hierarchy. This
conservative manual snapshot is regenerated from the authoritative
roxygen source before release.

## Usage

``` r
apm_plan(data, study, treatment, control, response = NULL, experiment = NULL, effect_id = NULL, dose = NULL, site = NULL, year = NULL, outcome = NULL, block = NULL, time = NULL, cluster = NULL, units = NULL, design = c("auto", "independent", "paired"))
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: shared-control nitrogen-rate experiments.
apm_plan(maize_n_shared, study=study_id, experiment=experiment_id,
  treatment=treatment, control=control, response=mean_t, dose=N_rate,
  site=site, year=year)
#> <apm_plan>
#> design: independent 
#> shared controls: 8 
#> - Shared controls detected: version 0.1.0 can audit them, but covariance modeling is introduced in 0.2.0. 
# Example 2: genuinely paired block summaries.
apm_plan(wheat_paired_blocks, study=study_id, treatment=treatment,
  control=control, response=mean_t, block=block_id, design="paired")
#> <apm_plan>
#> design: paired 
#> shared controls: 0 
# Example 3: multicrop inoculant evidence.
apm_plan(bioinoculant_multicrop, study=study_id, treatment=treatment,
  control=control, response=mean_t, outcome=outcome, site=site)
#> <apm_plan>
#> design: independent 
#> shared controls: 0 
```
