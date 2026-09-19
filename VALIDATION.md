# Validation status: agriPairMetaFlow 1.0.0.9000

The package architecture through the planned 1.0 release is implemented.
The project decision remains explicit: the construction environment
**does not install or execute R**. Runtime and numerical validation are
performed locally.

Status vocabulary:

- **PASS**: actually checked in the construction environment;
- **FAIL**: actually checked and failed;
- **NOT RUN / LOCAL**: intentionally reserved for the local R validation
  procedure.

## Construction-environment gates

| Gate | Status | Evidence |
|----|----|----|
| 0.1.0-0.5.0 analytical API preserved | PASS | NAMESPACE/source static audit |
| 3 planned 1.0.0 integration functions implemented | PASS | `R/workflow.R`, `R/capabilities.R`, `R/doctor.R` |
| 57 analytical exports represented | PASS | NAMESPACE/API static gate |
| all 57 exports have source roxygen documentation | PASS | static coverage audit |
| at least three roxygen example calls per analytical export | PASS | static coverage audit |
| conservative manual snapshot for every analytical export | PASS | 57/57 API manuals plus dataset topics |
| at least three vignette calls per analytical export | PASS | static vignette coverage audit |
| test-file coverage for every analytical export | PASS | static test coverage audit |
| frozen agronomic datasets present | PASS | 11/11 `inst/extdata` CSV files |
| frozen dataset SHA-256 validation | PASS | `inst/metadata/data_hashes.csv` |
| workflow retains explicit routing log | PASS | 1.0 source safety gate |
| shared-control auto route creates sampling covariance | PASS | 1.0 source safety gate |
| paired route does not invent between-study covariance | PASS | source inspection and workflow contract |
| workflow manual-equivalence test present | PASS | `tests/testthat/test-workflow.R` |
| capability registry includes backend/version/validation tiers | PASS | 1.0 source safety gate |
| doctor explicitly non-mutating | PASS | 1.0 source safety gate |
| doctor separates core and optional readiness | PASS | source/test audit |
| all release-block scientific safety gates retained | PASS | extended static validator |
| source-only validation suite | PASS | **755/755** checks |
| API coverage matrix | PASS | `inst/metadata/api_1_0_coverage.csv` |
| R source parsing | NOT RUN / LOCAL | local R required |
| roxygen2 regeneration | NOT RUN / LOCAL | local R required |
| clean-library source installation | NOT RUN / LOCAL | local R required |
| 58 testthat files executed | NOT RUN / LOCAL | local R required |
| package examples executed | NOT RUN / LOCAL | local R required |
| deterministic numerical backend equivalence | NOT RUN / LOCAL | local R and backends required |
| stochastic/Monte Carlo backend validation | NOT RUN / LOCAL | local R/backends required |
| JAGS/Stan diagnostics | NOT RUN / LOCAL | local external engines required |
| all normal vignettes rendered | NOT RUN / LOCAL | local R/Pandoc required |
| reports rendered and visually checked | NOT RUN / LOCAL | local R/Pandoc/LaTeX as applicable |
| `R CMD build` | NOT RUN / LOCAL | local R required |
| `R CMD check --as-cran` on exact built candidate | NOT RUN / LOCAL | local R required |
| formal 1.0.0 tarball frozen | NOT RUN / LOCAL | only after local validation |

## Interpretation

The source tree has passed all checks that can be truthfully performed
without R. This does **not** establish numerical equivalence, runtime
correctness, backend compatibility, convergence, vignette executability,
CRAN readiness, or formal release status.

The current package version therefore remains `1.0.0.9000`. Promotion to
`1.0.0` is conditional on the complete procedure in
`LOCAL_VALIDATION.md` and a successful final check of the exact
immutable formal source tarball.
