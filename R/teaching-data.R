# Teaching datasets for agriPairMetaFlow 0.1.0.
# Deterministic synthetic data for examples and validation, not field evidence.

#' Synthetic agronomic teaching data: maize_n_shared
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 24 rows and 18 variables after development identifiers are added.
#' @export
maize_n_shared <- data.frame(
  study_id = c(
    "MZ01", "MZ01", "MZ01", "MZ02", "MZ02", "MZ02",
    "MZ03", "MZ03", "MZ03", "MZ04", "MZ04", "MZ04",
    "MZ05", "MZ05", "MZ05", "MZ06", "MZ06", "MZ06",
    "MZ07", "MZ07", "MZ07", "MZ08", "MZ08", "MZ08"
  ),
  experiment_id = c(
    "MZ01E1", "MZ01E1", "MZ01E1", "MZ02E1", "MZ02E1", "MZ02E1",
    "MZ03E1", "MZ03E1", "MZ03E1", "MZ04E1", "MZ04E1", "MZ04E1",
    "MZ05E1", "MZ05E1", "MZ05E1", "MZ06E1", "MZ06E1", "MZ06E1",
    "MZ07E1", "MZ07E1", "MZ07E1", "MZ08E1", "MZ08E1", "MZ08E1"
  ),
  site = c(
    "Areia", "Areia", "Areia", "Campina Grande", "Campina Grande", "Campina Grande",
    "Patos", "Patos", "Patos", "Sousa", "Sousa", "Sousa",
    "Areia", "Areia", "Areia", "Campina Grande", "Campina Grande", "Campina Grande",
    "Patos", "Patos", "Patos", "Sousa", "Sousa", "Sousa"
  ),
  year = c(
    2018, 2018, 2018, 2019, 2019, 2019,
    2020, 2020, 2020, 2021, 2021, 2021,
    2022, 2022, 2022, 2017, 2017, 2017,
    2018, 2018, 2018, 2019, 2019, 2019
  ),
  crop = c(
    "maize", "maize", "maize", "maize", "maize", "maize",
    "maize", "maize", "maize", "maize", "maize", "maize",
    "maize", "maize", "maize", "maize", "maize", "maize",
    "maize", "maize", "maize", "maize", "maize", "maize"
  ),
  soil_texture = c(
    "loam", "loam", "loam", "clay", "clay", "clay",
    "sandy", "sandy", "sandy", "loam", "loam", "loam",
    "clay", "clay", "clay", "sandy", "sandy", "sandy",
    "loam", "loam", "loam", "clay", "clay", "clay"
  ),
  treatment = c(
    "N50", "N100", "N150", "N50", "N100", "N150",
    "N50", "N100", "N150", "N50", "N100", "N150",
    "N50", "N100", "N150", "N50", "N100", "N150",
    "N50", "N100", "N150", "N50", "N100", "N150"
  ),
  control = c(
    "N0", "N0", "N0", "N0", "N0", "N0",
    "N0", "N0", "N0", "N0", "N0", "N0",
    "N0", "N0", "N0", "N0", "N0", "N0",
    "N0", "N0", "N0", "N0", "N0", "N0"
  ),
  N_rate = c(
    50, 100, 150, 50, 100, 150,
    50, 100, 150, 50, 100, 150,
    50, 100, 150, 50, 100, 150,
    50, 100, 150, 50, 100, 150
  ),
  mean_t = c(
    5.074, 5.275, 5.351, 5.1, 5.307, 5.361,
    5.01, 5.086, 5.227, 4.839, 4.829, 4.889,
    4.763, 4.781, 4.806, 4.913, 5.027, 4.911,
    5.139, 5.117, 5.354, 5.32, 5.302, 5.311
  ),
  sd_t = c(
    0.46, 0.485, 0.51, 0.44, 0.465, 0.49,
    0.46, 0.485, 0.51, 0.44, 0.465, 0.49,
    0.46, 0.485, 0.51, 0.44, 0.465, 0.49,
    0.46, 0.485, 0.51, 0.44, 0.465, 0.49
  ),
  n_t = c(
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4
  ),
  mean_c = c(
    4.81, 4.81, 4.81, 4.827, 4.827, 4.827,
    4.635, 4.635, 4.635, 4.411, 4.411, 4.411,
    4.36, 4.36, 4.36, 4.53, 4.53, 4.53,
    4.764, 4.764, 4.764, 4.847, 4.847, 4.847
  ),
  sd_c = c(
    0.45, 0.45, 0.45, 0.48, 0.48, 0.48,
    0.42, 0.42, 0.42, 0.45, 0.45, 0.45,
    0.48, 0.48, 0.48, 0.42, 0.42, 0.42,
    0.45, 0.45, 0.45, 0.48, 0.48, 0.48
  ),
  n_c = c(
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4,
    5, 5, 5, 4, 4, 4
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: covercrop_variability
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 18 rows and 10 variables.
#' @export
covercrop_variability <- data.frame(
  study_id = c(
    "CV01", "CV02", "CV03", "CV04", "CV05", "CV06",
    "CV07", "CV08", "CV09", "CV10", "CV11", "CV12",
    "CV13", "CV14", "CV15", "CV16", "CV17", "CV18"
  ),
  crop = c(
    "soybean", "cotton", "maize", "soybean", "cotton", "maize",
    "soybean", "cotton", "maize", "soybean", "cotton", "maize",
    "soybean", "cotton", "maize", "soybean", "cotton", "maize"
  ),
  treatment = c(
    "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop",
    "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop",
    "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop", "cover_crop"
  ),
  control = c(
    "fallow", "fallow", "fallow", "fallow", "fallow", "fallow",
    "fallow", "fallow", "fallow", "fallow", "fallow", "fallow",
    "fallow", "fallow", "fallow", "fallow", "fallow", "fallow"
  ),
  mean_t = c(
    4.576, 5.04, 5.512, 4.28, 4.532, 4.992,
    5.46, 4.24, 4.708, 4.944, 5.408, 4.2,
    4.664, 5.136, 5.356, 4.16, 4.62, 5.088
  ),
  sd_t = c(
    0.516, 0.585, 0.517, 0.492, 0.559, 0.495,
    0.564, 0.533, 0.473, 0.54, 0.611, 0.451,
    0.516, 0.585, 0.517, 0.492, 0.559, 0.495
  ),
  n_t = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  mean_c = c(
    4.4, 4.8, 5.2, 4.0, 4.4, 4.8,
    5.2, 4.0, 4.4, 4.8, 5.2, 4.0,
    4.4, 4.8, 5.2, 4.0, 4.4, 4.8
  ),
  sd_c = c(
    0.6, 0.65, 0.55, 0.6, 0.65, 0.55,
    0.6, 0.65, 0.55, 0.6, 0.65, 0.55,
    0.6, 0.65, 0.55, 0.6, 0.65, 0.55
  ),
  n_c = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: irrigation_climate
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 20 rows and 14 variables after development identifiers and mean temperature are added.
#' @export
irrigation_climate <- data.frame(
  study_id = c(
    "IR01", "IR02", "IR03", "IR04", "IR05", "IR06",
    "IR07", "IR08", "IR09", "IR10", "IR11", "IR12",
    "IR13", "IR14", "IR15", "IR16", "IR17", "IR18",
    "IR19", "IR20"
  ),
  climate_zone = c(
    "semiarid", "semiarid", "semiarid", "semiarid", "semiarid", "semiarid",
    "transition", "transition", "transition", "transition", "transition", "transition",
    "transition", "humid", "humid", "humid", "humid", "humid",
    "humid", "humid"
  ),
  rainfall = c(
    495, 540, 585, 630, 675, 720,
    765, 810, 855, 900, 945, 990,
    1035, 1080, 1125, 1170, 1215, 1260,
    1305, 1350
  ),
  treatment = c(
    "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation",
    "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation",
    "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation", "supplemental_irrigation",
    "supplemental_irrigation", "supplemental_irrigation"
  ),
  control = c(
    "rainfed", "rainfed", "rainfed", "rainfed", "rainfed", "rainfed",
    "rainfed", "rainfed", "rainfed", "rainfed", "rainfed", "rainfed",
    "rainfed", "rainfed", "rainfed", "rainfed", "rainfed", "rainfed",
    "rainfed", "rainfed"
  ),
  mean_t = c(
    4.823, 4.728, 4.897, 5.008, 5.301, 5.195,
    5.305, 5.28, 5.187, 5.457, 5.571, 5.775,
    5.623, 5.803, 5.992, 5.784, 6.156, 6.055,
    6.193, 6.163
  ),
  sd_t = c(
    0.47, 0.49, 0.51, 0.45, 0.47, 0.49,
    0.51, 0.45, 0.47, 0.49, 0.51, 0.45,
    0.47, 0.49, 0.51, 0.45, 0.47, 0.49,
    0.51, 0.45
  ),
  n_t = c(
    5, 4, 5, 4, 5, 4,
    5, 4, 5, 4, 5, 4,
    5, 4, 5, 4, 5, 4,
    5, 4
  ),
  mean_c = c(
    4.19, 4.28, 4.37, 4.46, 4.55, 4.64,
    4.73, 4.82, 4.91, 5.0, 5.09, 5.18,
    5.27, 5.36, 5.45, 5.54, 5.63, 5.72,
    5.81, 5.9
  ),
  sd_c = c(
    0.5, 0.52, 0.48, 0.5, 0.52, 0.48,
    0.5, 0.52, 0.48, 0.5, 0.52, 0.48,
    0.5, 0.52, 0.48, 0.5, 0.52, 0.48,
    0.5, 0.52
  ),
  n_c = c(
    5, 4, 5, 4, 5, 4,
    5, 4, 5, 4, 5, 4,
    5, 4, 5, 4, 5, 4,
    5, 4
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: bioinoculant_multicrop
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 24 rows and 16 variables after development identifiers are added.
#' @export
bioinoculant_multicrop <- data.frame(
  study_id = c(
    "BI01", "BI02", "BI03", "BI04", "BI05", "BI06",
    "BI07", "BI08", "BI09", "BI10", "BI11", "BI12",
    "BI13", "BI14", "BI15", "BI16", "BI17", "BI18",
    "BI19", "BI20", "BI21", "BI22", "BI23", "BI24"
  ),
  site = c(
    "Bananeiras", "Lagoa Seca", "Areia", "Bananeiras", "Lagoa Seca", "Areia",
    "Bananeiras", "Lagoa Seca", "Areia", "Bananeiras", "Lagoa Seca", "Areia",
    "Bananeiras", "Lagoa Seca", "Areia", "Bananeiras", "Lagoa Seca", "Areia",
    "Bananeiras", "Lagoa Seca", "Areia", "Bananeiras", "Lagoa Seca", "Areia"
  ),
  crop = c(
    "maize", "soybean", "wheat", "common_bean", "maize", "soybean",
    "wheat", "common_bean", "maize", "soybean", "wheat", "common_bean",
    "maize", "soybean", "wheat", "common_bean", "maize", "soybean",
    "wheat", "common_bean", "maize", "soybean", "wheat", "common_bean"
  ),
  outcome = c(
    "yield", "yield", "yield", "yield", "yield", "yield",
    "yield", "yield", "yield", "yield", "yield", "yield",
    "yield", "yield", "yield", "yield", "yield", "yield",
    "yield", "yield", "yield", "yield", "yield", "yield"
  ),
  treatment = c(
    "inoculated", "inoculated", "inoculated", "inoculated", "inoculated", "inoculated",
    "inoculated", "inoculated", "inoculated", "inoculated", "inoculated", "inoculated",
    "inoculated", "inoculated", "inoculated", "inoculated", "inoculated", "inoculated",
    "inoculated", "inoculated", "inoculated", "inoculated", "inoculated", "inoculated"
  ),
  control = c(
    "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated",
    "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated",
    "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated",
    "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated", "uninoculated"
  ),
  mean_t = c(
    5.448, 3.188, 2.935, 2.406, 5.215, 3.2,
    2.844, 2.349, 5.84, 3.145, 2.771, 2.324,
    5.611, 3.302, 2.819, 2.274, 5.452, 3.299,
    2.986, 2.159, 5.457, 3.281, 2.903, 2.367
  ),
  sd_t = c(
    0.37, 0.39, 0.41, 0.35, 0.37, 0.39,
    0.41, 0.35, 0.37, 0.39, 0.41, 0.35,
    0.37, 0.39, 0.41, 0.35, 0.37, 0.39,
    0.41, 0.35, 0.37, 0.39, 0.41, 0.35
  ),
  n_t = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  mean_c = c(
    4.992, 3.038, 2.8, 2.244, 4.888, 2.976,
    2.744, 2.2, 5.304, 2.914, 2.688, 2.156,
    5.2, 3.162, 2.632, 2.112, 5.096, 3.1,
    2.856, 2.068, 4.992, 3.038, 2.8, 2.244
  ),
  sd_c = c(
    0.39, 0.41, 0.37, 0.39, 0.41, 0.37,
    0.39, 0.41, 0.37, 0.39, 0.41, 0.37,
    0.39, 0.41, 0.37, 0.39, 0.41, 0.37,
    0.39, 0.41, 0.37, 0.39, 0.41, 0.37
  ),
  n_c = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: wheat_paired_blocks
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 12 rows and 10 variables.
#' @export
wheat_paired_blocks <- data.frame(
  study_id = c(
    "WP01", "WP02", "WP03", "WP04", "WP05", "WP06",
    "WP07", "WP08", "WP09", "WP10", "WP11", "WP12"
  ),
  block_id = c(
    "B01", "B02", "B03", "B04", "B05", "B06",
    "B07", "B08", "B09", "B10", "B11", "B12"
  ),
  treatment = c(
    "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment",
    "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment", "seed_treatment"
  ),
  control = c(
    "untreated", "untreated", "untreated", "untreated", "untreated", "untreated",
    "untreated", "untreated", "untreated", "untreated", "untreated", "untreated"
  ),
  mean_t = c(
    4.023, 4.156, 4.253, 4.343, 3.824, 3.979,
    4.146, 4.289, 4.394, 3.84, 3.95, 4.096
  ),
  sd_t = c(
    0.323, 0.342, 0.304, 0.323, 0.342, 0.304,
    0.323, 0.342, 0.304, 0.323, 0.342, 0.304
  ),
  mean_c = c(
    3.72, 3.84, 3.96, 4.08, 3.6, 3.72,
    3.84, 3.96, 4.08, 3.6, 3.72, 3.84
  ),
  sd_c = c(
    0.34, 0.36, 0.32, 0.34, 0.36, 0.32,
    0.34, 0.36, 0.32, 0.34, 0.36, 0.32
  ),
  n_pairs = c(
    9, 10, 11, 8, 9, 10,
    11, 8, 9, 10, 11, 8
  ),
  r_tc = c(
    0.48, 0.51, 0.54, 0.45, 0.48, 0.51,
    0.54, 0.45, 0.48, 0.51, 0.54, 0.45
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: agri_uncertainty_mixed
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 12 rows and 6 variables.
#' @export
agri_uncertainty_mixed <- data.frame(
  study_id = c(
    "UN01", "UN02", "UN03", "UN04", "UN05", "UN06",
    "UN07", "UN08", "UN09", "UN10", "UN11", "UN12"
  ),
  mean_yield = c(
    3.2, 3.4, 3.6, 3.8, 4.0, 4.2,
    4.4, 4.6, 4.8, 5.0, 5.2, 5.4
  ),
  n = c(
    5, 6, 7, 4, 5, 6,
    7, 4, 5, 6, 7, 4
  ),
  se_yield = c(
    NA_real_, NA_real_, 0.14174, NA_real_, NA_real_, 0.14289,
    NA_real_, NA_real_, 0.14534, NA_real_, NA_real_, 0.15
  ),
  cv_percent = c(
    10.156, NA_real_, NA_real_, 7.895, NA_real_, NA_real_,
    8.523, NA_real_, NA_real_, 7.0, NA_real_, NA_real_
  ),
  residual_mse = c(
    NA_real_, 0.1225, NA_real_, NA_real_, 0.10563, NA_real_,
    NA_real_, 0.09, NA_real_, NA_real_, 0.14062, NA_real_
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: pest_suppression_binary
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 16 rows and 8 variables.
#' @export
pest_suppression_binary <- data.frame(
  study_id = c(
    "PS01", "PS02", "PS03", "PS04", "PS05", "PS06",
    "PS07", "PS08", "PS09", "PS10", "PS11", "PS12",
    "PS13", "PS14", "PS15", "PS16"
  ),
  crop = c(
    "maize", "soybean", "cotton", "maize", "soybean", "cotton",
    "maize", "soybean", "cotton", "maize", "soybean", "cotton",
    "maize", "soybean", "cotton", "maize"
  ),
  treatment = c(
    "IPM", "IPM", "IPM", "IPM", "IPM", "IPM",
    "IPM", "IPM", "IPM", "IPM", "IPM", "IPM",
    "IPM", "IPM", "IPM", "IPM"
  ),
  control = c(
    "standard", "standard", "standard", "standard", "standard", "standard",
    "standard", "standard", "standard", "standard", "standard", "standard",
    "standard", "standard", "standard", "standard"
  ),
  event_t = c(
    11, 12, 10, 13, 11, 10,
    11, 13, 12, 10, 11, 11,
    12, 13, 9, 11
  ),
  n_t = c(
    42, 44, 46, 48, 40, 42,
    44, 46, 48, 40, 42, 44,
    46, 48, 40, 42
  ),
  event_c = c(
    16, 18, 17, 16, 17, 16,
    18, 16, 15, 17, 19, 15,
    16, 18, 17, 16
  ),
  n_c = c(
    44, 46, 48, 42, 44, 46,
    48, 42, 44, 46, 48, 42,
    44, 46, 48, 42
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: agri_effects_benchmark
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 24 rows and 9 variables.
#' @export
agri_effects_benchmark <- data.frame(
  study_id = c(
    "BM01", "BM02", "BM03", "BM04", "BM05", "BM06",
    "BM07", "BM08", "BM09", "BM10", "BM11", "BM12",
    "BM13", "BM14", "BM15", "BM16", "BM17", "BM18",
    "BM19", "BM20", "BM21", "BM22", "BM23", "BM24"
  ),
  crop = c(
    "soybean", "wheat", "maize", "soybean", "wheat", "maize",
    "soybean", "wheat", "maize", "soybean", "wheat", "maize",
    "soybean", "wheat", "maize", "soybean", "wheat", "maize",
    "soybean", "wheat", "maize", "soybean", "wheat", "maize"
  ),
  soil_texture = c(
    "loam", "clay", "sandy", "loam", "clay", "sandy",
    "loam", "clay", "sandy", "loam", "clay", "sandy",
    "loam", "clay", "sandy", "loam", "clay", "sandy",
    "loam", "clay", "sandy", "loam", "clay", "sandy"
  ),
  dose = c(
    100, 150, 200, 50, 100, 150,
    200, 50, 100, 150, 200, 50,
    100, 150, 200, 50, 100, 150,
    200, 50, 100, 150, 200, 50
  ),
  rainfall = c(
    535, 570, 605, 640, 675, 710,
    745, 780, 815, 850, 885, 920,
    955, 990, 1025, 1060, 1095, 1130,
    1165, 1200, 1235, 1270, 1305, 1340
  ),
  yi = c(
    0.207013, 0.250453, 0.200983, 0.091331, 0.10653, 0.293532,
    0.046698, 0.136017, 0.068557, -0.065601, 0.288231, 0.05436,
    0.058339, 0.131884, 0.20388, 0.14185, 0.187168, -0.038421,
    -0.04639, -0.156507, -0.179244, 0.180179, -0.034404, 0.121567
  ),
  vi = c(
    0.0095, 0.011, 0.0125, 0.008, 0.0095, 0.011,
    0.0125, 0.008, 0.0095, 0.011, 0.0125, 0.008,
    0.0095, 0.011, 0.0125, 0.008, 0.0095, 0.011,
    0.0125, 0.008, 0.0095, 0.011, 0.0125, 0.008
  ),
  sei = c(
    0.097468, 0.104881, 0.111803, 0.089443, 0.097468, 0.104881,
    0.111803, 0.089443, 0.097468, 0.104881, 0.111803, 0.089443,
    0.097468, 0.104881, 0.111803, 0.089443, 0.097468, 0.104881,
    0.111803, 0.089443, 0.097468, 0.104881, 0.111803, 0.089443
  ),
  measure = c(
    "lnRR", "lnRR", "lnRR", "lnRR", "lnRR", "lnRR",
    "lnRR", "lnRR", "lnRR", "lnRR", "lnRR", "lnRR",
    "lnRR", "lnRR", "lnRR", "lnRR", "lnRR", "lnRR",
    "lnRR", "lnRR", "lnRR", "lnRR", "lnRR", "lnRR"
  ),
  stringsAsFactors = FALSE
)

#' Synthetic agronomic teaching data: soil_management_multiresponse
#'
#' Deterministic synthetic data used only for examples, tests, and validation.
#' @format A data frame with 18 rows and 10 variables.
#' @export
soil_management_multiresponse <- data.frame(
  study_id = c(
    "SM01", "SM02", "SM03", "SM04", "SM05", "SM06",
    "SM07", "SM08", "SM09", "SM10", "SM11", "SM12",
    "SM13", "SM14", "SM15", "SM16", "SM17", "SM18"
  ),
  outcome = c(
    "soil_C", "infiltration", "yield", "soil_C", "infiltration", "yield",
    "soil_C", "infiltration", "yield", "soil_C", "infiltration", "yield",
    "soil_C", "infiltration", "yield", "soil_C", "infiltration", "yield"
  ),
  treatment = c(
    "conservation", "conservation", "conservation", "conservation", "conservation", "conservation",
    "conservation", "conservation", "conservation", "conservation", "conservation", "conservation",
    "conservation", "conservation", "conservation", "conservation", "conservation", "conservation"
  ),
  control = c(
    "conventional", "conventional", "conventional", "conventional", "conventional", "conventional",
    "conventional", "conventional", "conventional", "conventional", "conventional", "conventional",
    "conventional", "conventional", "conventional", "conventional", "conventional", "conventional"
  ),
  mean_t = c(
    18.547, 27.73, 4.355, 19.757, 26.55, 4.173,
    18.95, 28.32, 4.445, 18.144, 27.14, 4.264,
    19.354, 28.91, 4.082, 18.547, 27.73, 4.355
  ),
  sd_t = c(
    1.573, 2.232, 0.383, 1.676, 2.137, 0.367,
    1.607, 2.28, 0.391, 1.539, 2.185, 0.375,
    1.642, 2.328, 0.359, 1.573, 2.232, 0.383
  ),
  n_t = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  mean_c = c(
    16.56, 23.5, 4.032, 17.64, 22.5, 3.864,
    16.92, 24.0, 4.116, 16.2, 23.0, 3.948,
    17.28, 24.5, 3.78, 16.56, 23.5, 4.032
  ),
  sd_c = c(
    1.656, 2.35, 0.403, 1.764, 2.25, 0.386,
    1.692, 2.4, 0.412, 1.62, 2.3, 0.395,
    1.728, 2.45, 0.378, 1.656, 2.35, 0.403
  ),
  n_c = c(
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4,
    5, 6, 4, 5, 6, 4
  ),
  stringsAsFactors = FALSE
)


# Development extensions introduced in 0.2.0: explicit contrast identifiers used
# to demonstrate shared-control and dependence-aware workflows.
maize_n_shared$effect_id <- paste0(maize_n_shared$experiment_id,"_",maize_n_shared$treatment)
maize_n_shared$control_id <- paste0(maize_n_shared$experiment_id,"_",maize_n_shared$control)
bioinoculant_multicrop$experiment_id <- paste0(bioinoculant_multicrop$study_id,"E1")
bioinoculant_multicrop$effect_id <- paste0(bioinoculant_multicrop$study_id,"_",bioinoculant_multicrop$treatment)
bioinoculant_multicrop$control_id <- paste0(bioinoculant_multicrop$study_id,"_",bioinoculant_multicrop$control)
soil_management_multiresponse$effect_id <- paste0(soil_management_multiresponse$study_id,"_",soil_management_multiresponse$outcome)
wheat_paired_blocks$effect_id <- paste0(wheat_paired_blocks$study_id,"_",wheat_paired_blocks$block_id)
irrigation_climate$experiment_id <- paste0(irrigation_climate$study_id,"E1")
irrigation_climate$effect_id <- paste0(irrigation_climate$study_id,"_IRR")
# Quantitative climate moderator added in 0.3.0 for two-moderator teaching examples.
irrigation_climate$mean_temp <- round(27 - 0.005 * (irrigation_climate$rainfall - min(irrigation_climate$rainfall)), 2)

#' Synthetic agronomic teaching data: fertilizer_dose_response
#'
#' Multiple nitrogen rates compared with a shared zero-N reference. Deterministic
#' synthetic data for dependence and dose-response examples; not field evidence.
#' @format A data frame with 32 rows and 22 variables including effect-size and dose metadata.
#' @export
fertilizer_dose_response <- local({
  study_id <- rep(sprintf("FD%02d",1:8), each=4)
  N_rate <- rep(c(40,80,120,160),8)
  base <- rep(c(3.8,4.1,4.4,4.0,4.3,3.9,4.2,4.5),each=4)
  response <- 0.0009*N_rate - 0.0000025*N_rate^2
  mean_c <- base
  mean_t <- round(base*(1+response),3)
  n <- rep(c(4,5,6,5,4,6,5,6),each=4)
  data.frame(
    study_id=study_id,
    experiment_id=paste0(study_id,"E1"),
    dose_id=paste0(study_id,"_N",N_rate),
    effect_id=paste0(study_id,"_N",N_rate),
    control_id=paste0(study_id,"_N0"),
    crop=rep(c("maize","wheat","maize","wheat","maize","wheat","maize","wheat"),each=4),
    soil_texture=rep(c("loam","clay","sandy","loam","clay","sandy","loam","clay"),each=4),
    N_rate=N_rate,
    treatment=paste0("N",N_rate),
    control="N0",
    mean_t=mean_t,
    sd_t=round(0.38+0.0007*N_rate,3),
    n_t=n,
    mean_c=mean_c,
    sd_c=rep(c(.42,.46,.40,.44,.45,.41,.43,.47),each=4),
    n_c=n,
    stringsAsFactors=FALSE
  )
})
maize_n_shared$treatment_id <- paste0(maize_n_shared$experiment_id,"_",maize_n_shared$treatment)
bioinoculant_multicrop$treatment_id <- paste0(bioinoculant_multicrop$experiment_id,"_",bioinoculant_multicrop$treatment)
fertilizer_dose_response$treatment_id <- fertilizer_dose_response$dose_id
# Effect-size columns used by the 0.3.0 dose-response teaching workflow.
# The diagonal sampling variance is the large-sample ln response-ratio variance;
# off-diagonal covariance induced by the shared N0 arm is reconstructed by
# apm_vcov() from treatment_id/control_id metadata.
fertilizer_dose_response$lnRR <- log(fertilizer_dose_response$mean_t / fertilizer_dose_response$mean_c)
fertilizer_dose_response$vi <- fertilizer_dose_response$sd_t^2 / (fertilizer_dose_response$n_t * fertilizer_dose_response$mean_t^2) +
  fertilizer_dose_response$sd_c^2 / (fertilizer_dose_response$n_c * fertilizer_dose_response$mean_c^2)
fertilizer_dose_response$sei <- sqrt(fertilizer_dose_response$vi)
fertilizer_dose_response$measure <- "ROM"
fertilizer_dose_response$dose_unit <- "kg N ha-1"


# Multivariate teaching extensions introduced in 0.4.0.
soil_management_multiresponse$mv_study_id <- rep(sprintf("SMV%02d", 1:6), each = 3)
soil_management_multiresponse$climate_zone <- rep(c("semiarid","transition","humid","semiarid","transition","humid"), each = 3)
soil_management_multiresponse$lnRR <- log(soil_management_multiresponse$mean_t / soil_management_multiresponse$mean_c)
soil_management_multiresponse$yi <- soil_management_multiresponse$lnRR
soil_management_multiresponse$vi <- soil_management_multiresponse$sd_t^2 / (soil_management_multiresponse$n_t * soil_management_multiresponse$mean_t^2) +
  soil_management_multiresponse$sd_c^2 / (soil_management_multiresponse$n_c * soil_management_multiresponse$mean_c^2)
soil_management_multiresponse$sei <- sqrt(soil_management_multiresponse$vi)
soil_management_multiresponse$measure <- "ROM"

#' Synthetic agronomic teaching data: biochar_multiresponse
#'
#' Eight synthetic studies jointly reporting yield, soil carbon, and N2O response
#' to biochar versus no biochar. Deterministic teaching data, not field evidence.
#' @format A data frame with 24 rows and multivariate effect-size metadata.
#' @export
biochar_multiresponse <- data.frame(
  study_id = c("BC01","BC01","BC01","BC02","BC02","BC02","BC03","BC03","BC03","BC04","BC04","BC04","BC05","BC05","BC05","BC06","BC06","BC06","BC07","BC07","BC07","BC08","BC08","BC08"),
  outcome = c("yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O","yield","soil_C","N2O"),
  climate_zone = c("semiarid","semiarid","semiarid","transition","transition","transition","humid","humid","humid","semiarid","semiarid","semiarid","transition","transition","transition","humid","humid","humid","transition","transition","transition","semiarid","semiarid","semiarid"),
  treatment = c("biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar","biochar"),
  control = c("no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar","no_biochar"),
  mean_t = c(4.009,16.24,1.98,4.2307,17.2064,2.0292,4.4554,18.1896,2.0768,4.5787,19.1896,2.196,4.8048,19.376,2.2428,5.0337,20.376,2.288,5.1484,21.3928,2.412,5.3788,22.4264,2.4564),
  sd_t = c(0.3849,1.4031,0.2661,0.4062,1.4866,0.2727,0.4277,1.5716,0.2791,0.4396,1.658,0.2951,0.4613,1.6741,0.3014,0.4832,1.7605,0.3075,0.4942,1.8483,0.3242,0.5164,1.9376,0.3301),
  n_t = c(5,5,5,6,6,6,5,5,5,4,4,4,6,6,6,5,5,5,5,5,5,6,6,6),
  mean_c = c(3.8,14.5,2.2,3.98,15.2,2.28,4.16,15.9,2.36,4.34,16.6,2.44,4.52,17.3,2.52,4.7,18,2.6,4.88,18.7,2.68,5.06,19.4,2.76),
  sd_c = c(0.38,1.305,0.308,0.398,1.368,0.3192,0.416,1.431,0.3304,0.434,1.494,0.3416,0.452,1.557,0.3528,0.47,1.62,0.364,0.488,1.683,0.3752,0.506,1.746,0.3864),
  n_c = c(5,5,5,6,6,6,5,5,5,4,4,4,6,6,6,5,5,5,5,5,5,6,6,6),
  effect_id = c("BC01_yield","BC01_soil_C","BC01_N2O","BC02_yield","BC02_soil_C","BC02_N2O","BC03_yield","BC03_soil_C","BC03_N2O","BC04_yield","BC04_soil_C","BC04_N2O","BC05_yield","BC05_soil_C","BC05_N2O","BC06_yield","BC06_soil_C","BC06_N2O","BC07_yield","BC07_soil_C","BC07_N2O","BC08_yield","BC08_soil_C","BC08_N2O"),
  lnRR = c(0.053540766928,0.113328685307,-0.105360515658,0.0610950993598,0.123985979781,-0.116533816256,0.0685927914656,0.134530892958,-0.12783337151,0.053540766928,0.14496577025,-0.105360515658,0.0610950993598,0.113328685307,-0.116533816256,0.0685927914656,0.123985979781,-0.12783337151,0.053540766928,0.134530892958,-0.105360515658,0.0610950993598,0.14496577025,-0.116533816256),
  vi = c(0.0038432,0.003112992,0.007532672,0.00320266666667,0.00259416,0.00627722666667,0.0038432,0.003112992,0.007532672,0.004804,0.00389124,0.00941584,0.00320266666667,0.00259416,0.00627722666667,0.0038432,0.003112992,0.007532672,0.0038432,0.003112992,0.007532672,0.00320266666667,0.00259416,0.00627722666667),
  sei = c(0.0619935480514,0.0557941932463,0.0867909672719,0.0565921078125,0.0509328970313,0.0792289509376,0.0619935480514,0.0557941932463,0.0867909672719,0.0693108938047,0.0623798044242,0.0970352513265,0.0565921078125,0.0509328970313,0.0792289509376,0.0619935480514,0.0557941932463,0.0867909672719,0.0619935480514,0.0557941932463,0.0867909672719,0.0565921078125,0.0509328970313,0.0792289509376),
  measure = c("ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM","ROM"),
  stringsAsFactors = FALSE
)
biochar_multiresponse$yi <- biochar_multiresponse$lnRR
