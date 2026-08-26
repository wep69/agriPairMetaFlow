\name{apm_workflow}
\alias{apm_workflow}
\title{Run an auditable end-to-end agronomic meta-analysis workflow}
\description{Consolidated 1.0 development-snapshot manual. The roxygen source in R/workflow.R is authoritative and must be regenerated locally with roxygen2 before formal release.}
\usage{apm_workflow(data, plan = NULL, measure = "lnRR", dependence = c("auto", "independent", "shared_control", "paired"), model = c("auto", "random", "multilevel"), moderators = NULL, robust = FALSE, bayes = FALSE, threshold = NULL, seed = NULL, ...)}
\arguments{\item{data}{Treatment-control summaries or an apm_effects object.}\item{plan}{Optional explicit apm_plan.}\item{measure}{Effect-size measure.}\item{dependence}{Dependence routing.}\item{model}{Model routing.}\item{moderators}{Optional moderator formula.}\item{robust}{Request CR2 sensitivity.}\item{bayes}{Request Bayesian sensitivity fit.}\item{threshold}{Optional agronomic relevance threshold.}\item{seed}{Optional reproducibility seed.}\item{...}{Arguments forwarded to the selected frequentist fitting function.}}
\value{An apm_workflow retaining every intermediate object and the routing log.}
\examples{
# Example 1: shared zero-N control.
if (requireNamespace("clubSandwich", quietly=TRUE)) apm_workflow(maize_n_shared, measure="lnRR", dependence="shared_control", model="multilevel", robust=TRUE)
# Example 2: climatic moderators.
apm_workflow(irrigation_climate, measure="lnRR", moderators=~rainfall+mean_temp, threshold=5)
# Example 3: genuinely paired wheat summaries.
apm_workflow(wheat_paired_blocks, measure="lnRR", dependence="paired", model="random")
}
