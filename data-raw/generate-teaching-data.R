# Developer-side regeneration contract for synthetic teaching data.
# The release snapshot stores deterministic CSV mirrors in inst/extdata and
# materializes equivalent namespace objects in R/teaching-data.R.
#
# Before a release on a machine with R, regenerate package data as .rda files
# if desired, compare hashes to inst/metadata/data_hashes.csv, and rerun the
# complete validation suite. Never replace these synthetic examples with field
# observations without documenting source, license, and provenance.
set.seed(20260826)
message("See tools/README-data-generation.md for the frozen data-generation specification.")

# 0.4.0 multivariate teaching-data extension ---------------------------------
# The installed CSV fixtures are frozen deterministic snapshots. Re-create the
# multivariate identifiers/effect-size fields from the treatment-control arm
# summaries before release and verify their SHA-256 hashes.
#
# soil_management_multiresponse: three outcomes within six multivariate studies
# biochar_multiresponse: yield, soil_C, and N2O within eight synthetic studies
#
# This file intentionally avoids downloading external empirical data. The
# examples are synthetic and must never be described as field evidence.
