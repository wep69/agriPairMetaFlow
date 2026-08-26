# Teaching-data generation

The 0.1.0 snapshot uses deterministic synthetic agronomic datasets. Their source-of-truth CSV files are stored under `inst/extdata/`, and equivalent small objects are materialized in `R/teaching-data.R` so examples can run without a data-building step. They are not empirical field evidence.

Before a formal release, the local R validation workflow should regenerate conventional `data/*.rda` objects from the same frozen inputs if that packaging form is preferred, verify row/column identities and hashes, and then regenerate documentation.
