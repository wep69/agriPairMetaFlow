\name{apm_read}
\alias{apm_read}
\title{Read meta-analytic study data with provenance}
\description{Read meta-analytic study data with provenance. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_read(path, sheet = NULL, mapping = NULL, na = c("", "NA"), units = NULL, strict = TRUE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: maize nitrogen experiments bundled with the package.
f1 <- system.file("extdata", "maize_n_shared.csv", package = "agriPairMetaFlow")
if (nzchar(f1)) maize <- apm_read(f1)

# Example 2: uncertainty fields imported from CSV.
f2 <- system.file("extdata", "agri_uncertainty_mixed.csv", package = "agriPairMetaFlow")
if (nzchar(f2)) unc <- apm_read(f2, mapping = c(study = "study_id"))

# Example 3: explicit agronomic units.
f3 <- system.file("extdata", "soil_management_multiresponse.csv", package = "agriPairMetaFlow")
if (nzchar(f3)) soil <- apm_read(f3, units = c(mean_t = "Mg ha-1", mean_c = "Mg ha-1"))
}
