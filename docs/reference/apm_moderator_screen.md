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
#> Error in metaforest::MetaForest(f, data = dat, vi = "vi", study = clname,     whichweights = "random", importance = "permutation", ...): object 'clname' not found
# Example 2: permutation importance.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop, importance="permutation", seed=2, tune=FALSE)
#> Error in metaforest::MetaForest(f, data = dat, vi = "vi", study = clname,     whichweights = "random", importance = "permutation", ...): object 'clname' not found
# Example 3: minimal-depth summary when ranger exposes tree structure.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+soil_texture, importance="minimal_depth", seed=3, tune=FALSE)
#> Error in metaforest::MetaForest(f, data = dat, vi = "vi", study = clname,     whichweights = "random", importance = "permutation", ...): object 'clname' not found
```
