\name{apm_effect_size}
\alias{apm_effect_size}
\title{Compute treatment-control effect sizes and sampling variances}
\description{Compute treatment-control effect sizes and sampling variances. This conservative manual snapshot is regenerated from the authoritative roxygen source before release.}
\usage{
apm_effect_size(data, measure = c("lnRR", "MD", "SMD", "VR", "CVR", "RR", "OR", "RD", "ZCOR", "GEN"), design = c("auto", "independent", "paired"), m_t = NULL, sd_t = NULL, n_t = NULL, m_c = NULL, sd_c = NULL, n_c = NULL, event_t = NULL, event_c = NULL, r = NULL, yi = NULL, vi = NULL, correct = TRUE, vtype = "LS", paired_standardization = c("change", "raw"), append = TRUE)
}
\value{A documented agriPairMetaFlow S3 object or presentation object, depending on the function.}
\examples{
# Example 1: log response ratio for maize nitrogen treatments.
apm_effect_size(maize_n_shared, "lnRR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c)
# Example 2: coefficient-of-variation ratio for cover crops.
apm_effect_size(covercrop_variability, "CVR", m_t=mean_t, sd_t=sd_t, n_t=n_t,
  m_c=mean_c, sd_c=sd_c, n_c=n_c)
# Example 3: paired log response ratio for matched wheat blocks.
apm_effect_size(wheat_paired_blocks, "lnRR", design="paired", m_t=mean_t,
  sd_t=sd_t, n_t=n_pairs, m_c=mean_c, sd_c=sd_c, n_c=n_pairs, r=r_tc)
}
