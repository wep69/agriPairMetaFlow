# Detect reused controls

Detects treatment contrasts that reuse a control arm within a study or
experiment and reports multiplicity and inconsistent duplicated control
summaries.

## Usage

``` r
apm_shared_control(data, study, control_id, treatment_id = NULL, effect_id = NULL, check_values = TRUE)
```

## Value

A structured agriPairMetaFlow object retaining assumptions and
provenance.

## Examples

``` r
apm_shared_control(maize_n_shared, study=experiment_id, control_id=control)
#> <apm_shared_control>
#>  n_rows n_studies n_control_groups n_shared_control_groups
#>      24         8                8                       8
#>  n_rows_in_shared_groups max_multiplicity n_conflicts
#>                       24                3           0
#> Construct a sampling covariance matrix before synthesis; do not treat these contrasts as independent. 
apm_shared_control(fertilizer_dose_response, study=study_id, control_id=control_id, treatment_id=dose_id)
#> <apm_shared_control>
#>  n_rows n_studies n_control_groups n_shared_control_groups
#>      32         8                8                       8
#>  n_rows_in_shared_groups max_multiplicity n_conflicts
#>                       32                4           0
#> Construct a sampling covariance matrix before synthesis; do not treat these contrasts as independent. 
apm_shared_control(soil_management_multiresponse, study=study_id, control_id=control, treatment_id=outcome)
#> <apm_shared_control>
#>  n_rows n_studies n_control_groups n_shared_control_groups
#>      18        18               18                       0
#>  n_rows_in_shared_groups max_multiplicity n_conflicts
#>                        0                1           0
#> No reused control arm was detected from the supplied identifiers. 
```
