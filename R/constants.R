.apm_effect_registry <- list(
  lnRR = list(independent = "ROM", paired = "ROMC", null = 0, transform = "ratio"),
  MD   = list(independent = "MD",  paired = "MC",   null = 0, transform = "identity"),
  SMD  = list(independent = "SMD", paired = "SMCC", null = 0, transform = "identity"),
  VR   = list(independent = "VR",  paired = "VRC",  null = 0, transform = "ratio"),
  CVR  = list(independent = "CVR", paired = "CVRC", null = 0, transform = "ratio"),
  RR   = list(independent = "RR",  paired = "MPRR", null = 0, transform = "ratio"),
  OR   = list(independent = "OR",  paired = "MPOR", null = 0, transform = "ratio"),
  RD   = list(independent = "RD",  paired = "MPRD", null = 0, transform = "identity"),
  ZCOR = list(independent = "ZCOR", paired = NA_character_, null = 0, transform = "zcor"),
  GEN  = list(independent = "GEN", paired = "GEN", null = 0, transform = "identity")
)

.apm_log_measures <- c("lnRR", "VR", "CVR", "RR", "OR", "ROM", "ROMC", "VRC", "CVRC", "MPRR", "MPOR")
