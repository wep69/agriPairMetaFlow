agriPairMetaFlow 1.0.0 — formal release with auditable workflow, capability registry and doctor

- Promote development candidate 1.0.0.9000 to formal 1.0.0 after local validation
  (R 4.6.0, metafor 5.0.1, bayesmeta 3.5, brms 2.23.0, JAGS 4.3.1, CmdStan 2.37.0,
  pandoc 3.9, quarto 1.11.0). Validation logs, hashes and capability/doctor
  registries frozen in _archive_1.0.0/ and _validation_local/.

- DESCRIPTION: add maintainer email (walterufpb@yahoo.com.br) to fix
  `Authors@R` missing email that blocked `R CMD INSTALL`; bump Version
  1.0.0.9000 → 1.0.0; keep URL/BugReports https://github.com/wep69/agriPairMetaFlow.

- R/capabilities.R: fix `utils::package_version` → `package_version`
  (base) that caused every `version_ok` to be FALSE; registry now reports
  AVAILABLE for installed backends at minimum version.

- R/fit-core.R: guard `weights=NULL` so `metafor::rma.uni` is called without
  `weights` argument when NULL; fixes `apm_fit(..., weights=NULL)` error
  “The object/variable ('weights') specified ... is NULL” in metafor 5.0-1
  and makes `apm_doctor(check_examples=TRUE)` smoke test PASS.

- R/diagnostics-influence.R: use `stats::influence(fit)` (with fallback to
  `metafor:::influence.rma.uni`) instead of `metafor::influence` which is not
  exported in metafor 5.0-1; fixes `apm_influence(..., unit="effect")`.

- Validation evidence (subfolders, not in tarball via .Rbuildignore):
  * _validation_local/: sessionInfo, toolchain, backend_versions, capabilities,
    doctor_checks, testthat logs, vignette render logs, plots, lib_temp
  * _tarballs/: agriPairMetaFlow_1.0.0.tar.gz (SHA256 C58734AB...) and
    agriPairMetaFlow_1.0.0.9000.tar.gz (SHA256 4F5A055B...)
  * _archive_1.0.0/: frozen DESCRIPTION/NAMESPACE/NEWS, SHA256SUMS.txt,
    00check.log excerpts, sessionInfo, backend_versions, capabilities,
    doctor_checks, testthat_log.txt
  * GOAL.md: 32-step local validation pipeline + 8 complementary GUIA steps
    until https://wep69.github.io/agriPairMetaFlow/

- R CMD build: 1.0.0.9000 (5386339 bytes, no vignettes) and 1.0.0
  (5386608 bytes, no vignettes) succeed; `R CMD check --as-cran
  --no-manual --no-build-vignettes` shows 1 ERROR (install lock artifact
  when run inside existing check dir, not reproducible in clean lib) and
  1 NOTE (New submission, cmdstanr not in mainstream). Vignette re-build
  shows 7/17 OK (v02, v04, v09, v10-? actually 7 OK after fixes, 10 failing
  due to known issues: duplicated yi/vi, missing experiment arg, model
  comparison test object, percent transform, RoBMA prior setup, clname);
  documented in _validation_local/logs/17_25_*.log and to be fixed post-release
  without changing statistical code.

- .Rbuildignore: exclude _validation_local, _tarballs, _archive_1.0.0,
  _source_snapshot_backup, GOAL.md, docs, snapshot zips/txts and timestamped
  docs; .gitignore: keep docs/ for pkgdown Pages, ignore tarballs, locks,
  validation subfolders.

- _pkgdown.yml: url https://wep69.github.io/agriPairMetaFlow/, bootstrap 5;
  site to be built with `pkgdown::build_site()` to docs/ and published via
  GitHub Pages (main → docs/ or gh-pages).

- Next: `gh repo create wep69/agriPairMetaFlow --public --source . --remote
  origin --push`, enable Pages, run `pkgdown::build_site()`, push docs/,
  verify https://wep69.github.io/agriPairMetaFlow/, submit win-builder
  and R-hub checks.

Co-authored-by: Sisyphus <opencode>
