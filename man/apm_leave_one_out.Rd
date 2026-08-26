\name{apm_leave_one_out}
\alias{apm_leave_one_out}
\title{Leave-one-study or leave-one-effect sensitivity analysis}
\description{Development-snapshot manual for apm_leave_one_out. The roxygen source in R/ is authoritative; regenerate with roxygen2 during local validation.}
\usage{apm_leave_one_out(...)}
\arguments{\item{...}{See the complete roxygen documentation and vignettes for arguments and method-specific assumptions.}}
\value{An auditable agriPairMetaFlow result or output object as documented in the function source.}
\examples{
# Example 1: independent yield-response studies.
apm_leave_one_out(apm_fit(agri_effects_benchmark), unit="study")
# Example 2: explicit effect-level sensitivity as a diagnostic.
apm_leave_one_out(apm_fit(agri_effects_benchmark), unit="effect")
# Example 3: report results on the percent-change scale.
apm_leave_one_out(apm_fit(agri_effects_benchmark), transform="percent")
}
