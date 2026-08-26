\name{apm_doctor}
\alias{apm_doctor}
\title{Diagnose the agriPairMetaFlow installation without changing it}
\description{Inspects core dependencies, optional backends, rendering tools, frozen data, and smoke examples while never installing or modifying software.}
\usage{apm_doctor(full = FALSE, check_backends = TRUE, check_render = FALSE, check_examples = FALSE)}
\arguments{\item{full}{Run extended reproducibility checks.}\item{check_backends}{Inspect optional backends.}\item{check_render}{Inspect Pandoc and Quarto.}\item{check_examples}{Run small core smoke examples.}}
\value{An apm_doctor object with PASS, WARN, FAIL, and NOT RUN checks plus remediation guidance.}
\examples{
# Example 1: core diagnosis.
apm_doctor()
# Example 2: extended backend diagnosis.
apm_doctor(full=TRUE, check_backends=TRUE)
# Example 3: release-machine diagnosis.
apm_doctor(full=TRUE, check_render=TRUE, check_examples=TRUE)
}
