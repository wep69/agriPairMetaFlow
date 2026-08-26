\name{apm_table}
\alias{apm_table}
\title{Create standardized analysis tables}
\description{Create standardized analysis tables. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_table(x, component = c("auto", "effects", "model", "heterogeneity", "metareg", "robust", "bayes", "sensitivity"), transform = c("auto", "none", "exp", "percent"), digits = 3, format = c("data.frame", "gt", "flextable"), ...)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: effect-size table.
ee <- apm_effect_size(maize_n_shared,"lnRR",m_t=mean_t,sd_t=sd_t,n_t=n_t,m_c=mean_c,sd_c=sd_c,n_c=n_c)
apm_table(ee, component="effects")
# Example 2: pooled model table as percent change.
apm_table(apm_fit(agri_effects_benchmark), component="model", transform="percent")
# Example 3: heterogeneity table, optionally formatted with gt.
hh <- apm_heterogeneity(apm_fit(agri_effects_benchmark))
if (requireNamespace("gt", quietly=TRUE)) apm_table(hh, format="gt")
}
