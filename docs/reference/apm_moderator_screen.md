# Exploratory screening of many agronomic moderators with MetaForest

Development-snapshot manual for apm_moderator_screen. The roxygen source
in R/ is authoritative; regenerate with roxygen2 during local
validation.

## Usage

``` r
apm_moderator_screen(...)
```

## Arguments

- ...:

  See the complete roxygen documentation and vignettes for arguments and
  method-specific assumptions.

## Value

An auditable agriPairMetaFlow result or output object as documented in
the function source.

## Examples

``` r
# Example 1: climatic moderator screening.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop+soil_texture, seed=1, tune=FALSE)
#> Warning: Unused arguments: study
#> <apm_moderator_screen> exploratory=TRUE | units=24
#>     moderator    importance      metric
#>      rainfall  0.0036837475 permutation
#>  soil_texture -0.0008193985 permutation
#>          crop -0.0009404871 permutation
#>          dose -0.0018901358 permutation
#> MetaForest is exploratory moderator screening. Confirm scientific hypotheses with prespecified meta-regression and appropriate uncertainty analysis. 
# Example 2: permutation importance.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop, importance="permutation", seed=2, tune=FALSE)
#> Warning: Unused arguments: study
#> <apm_moderator_screen> exploratory=TRUE | units=24
#>  moderator    importance      metric
#>   rainfall  0.0035947638 permutation
#>       crop -0.0009535502 permutation
#>       dose -0.0015210400 permutation
#> MetaForest is exploratory moderator screening. Confirm scientific hypotheses with prespecified meta-regression and appropriate uncertainty analysis. 
# Example 3: minimal-depth summary when ranger exposes tree structure.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+soil_texture, importance="minimal_depth", seed=3, tune=FALSE)
#> Warning: Unused arguments: study
#> <apm_moderator_screen> exploratory=TRUE | units=24
#>     moderator importance        metric
#>          dose  0.8717391 minimal_depth
#>      rainfall  0.9076577 minimal_depth
#>  soil_texture  1.0919283 minimal_depth
#> MetaForest is exploratory moderator screening. Confirm scientific hypotheses with prespecified meta-regression and appropriate uncertainty analysis. 
```
