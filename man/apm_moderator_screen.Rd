\name{apm_moderator_screen}
\alias{apm_moderator_screen}
\title{Exploratory screening of many agronomic moderators with MetaForest}
\description{Development-snapshot manual for apm_moderator_screen. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_moderator_screen(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: climatic moderator screening.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop+soil_texture, seed=1, tune=FALSE)
# Example 2: permutation importance.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+crop, importance="permutation", seed=2, tune=FALSE)
# Example 3: minimal-depth summary when ranger exposes tree structure.
if(requireNamespace("metaforest",quietly=TRUE)) apm_moderator_screen(agri_effects_benchmark, moderators=~dose+rainfall+soil_texture, importance="minimal_depth", seed=3, tune=FALSE)
}
