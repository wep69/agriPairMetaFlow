# GOAL — agriPairMetaFlow 1.0.0 : validação local completa até publicação em https://wep69.github.io/agriPairMetaFlow/

**Data:** 2026-08-26  
**Pasta de origem (única área de trabalho):** `D:\Walter\R\Pacotes_criados\agriPairMetaFlow`  
**Snapshot imutável:** `agriPairMetaFlow_1.0.0.9000_source-snapshot.zip` (SHA256 em `agriPairMetaFlow_1.0.0.9000_ARCHIVE_SHA256.txt`) + `agriPairMetaFlow_1.0.0.9000_source-snapshot.tar.gz`  
**Versão de partida:** `1.0.0.9000` (development candidate, 57 exports)  
**Versão alvo formal:** `1.0.0` (após todos os gates locais PASS)  
**Artefato final exigido:** `agriPairMetaFlow_1.0.0.tar.gz` produzido por `R CMD build` no exato conteúdo congelado, com SHA256 arquivado — **exclusivamente dentro de subfolders da pasta de origem, sem poluir raiz nem criar pastas fora dela.**

## Restrições operacionais

1. **Trabalhar somente na pasta de origem.** Nenhum arquivo temporário, log, library, tarball ou site deve ser criado fora de `D:\Walter\R\Pacotes_criados\agriPairMetaFlow`. Toda saída vai para **subfolders** (ver abaixo).
2. **Outputs em subfolders.** Estrutura padronizada criada na raiz:
   ```
   _validation_local/          # logs, csv, diagnósticos, hashes (ValidationDir interno)
     logs/
     capabilities/
     doctor/
     bayesian/
     plots/
   _tarballs/                  # tarballs built (1.0.0.9000 e 1.0.0 formal)
   _pkgdown_site/              # site pkgdown local (staging antes de docs/)
   docs/                       # site publicado para GitHub Pages (quando habilitado)
   _archive_1.0.0/             # freeze final: 00check.log, sessionInfo, backend_versions, SHA256SUMS
   _source_snapshot_backup/    # backup do snapshot imutável + manifest SHA
   ```
   O `ValidationDir` recomendado pelo documento (`../agriPairMetaFlow-validation-1.0.0`) é **mapeado** para `_validation_local/` para respeitar a restrição do usuário. Todo caminho citado no documento que aponta para `dirname(Pkg)` será traduzido para subfolder interno.
3. **Indicação clara de versão atualizada + TAR.** Ao final, `DESCRIPTION` deve marcar `Version: 1.0.0`, `NEWS.md` com heading `1.0.0`, e o TAR `agriPairMetaFlow_1.0.0.tar.gz` em `_tarballs/` com SHA256 em `_archive_1.0.0/SHA256SUMS.txt`.
4. **Não instalar R no sandbox.** Toda execução R acontece no **PC Windows local** via `C:\Program Files\R\R-4.6.0\bin\x64\Rscript.exe` (PowerShell `&` + aspas simples).

## Fontes normativas

- `agriPairMetaFlow_1.0.0_LOCAL_VALIDATION_DETAILED.md` — 32 etapas autoritativas (1-32), com sub-etapas 8A, 8B, 8C.
- `D:\Walter\R\Pacotes_criados\GUIA_COMPLEMENTAR.md` — fluxo complementar (preparação, dois diretórios adaptado, validação local 3.1-3.4, builders remotos, git/commit/push, CI GitHub Actions pak-matrix, higiene CRAN, tutoriais).
- `ARCHITECTURE.md`, `IMPLEMENTATION_SUMMARY.md`, `STATE_OF_THE_ART.md`, `VALIDATION.md`, `NEWS.md`, `DESCRIPTION`, `_pkgdown.yml`.

## Mapa completo de etapas até https://wep69.github.io/agriPairMetaFlow/

### Fase 0 — Goal e planejamento (este arquivo)
- [x] 0.1 Ler `LOCAL_VALIDATION_DETAILED.md` + `GUIA_COMPLEMENTAR.md` na íntegra
- [x] 0.2 Elaborar este GOAL e lista auditável de etapas
- [ ] 0.3 Criar estrutura de subfolders e congelar snapshot imutável

### Fase 1 — Snapshot imutável e toolchain (LOCAL 1-4 + GUIA 1-2)
1.  **Snapshot imutável** (L1 + G2 adaptado): verificar SHA256 ZIP/TAR.GZ vs `ARCHIVE_SHA256.txt`, verificar manifest `SOURCE_MANIFEST_SHA256.txt` (241 arquivos), descompactar **dentro** da pasta de origem sem contaminar raiz (conteúdo de `agriPairMetaFlow/` → raiz), preservar zip/tar.gz em `_source_snapshot_backup/`.
2.  **Toolchain local** (L2): `sessionInfo()`, `R.version.string`, `Sys.info()`, JAGS, CmdStan/cmdstanr, pandoc, Quarto, compiler; salvar em `_validation_local/logs/sessionInfo.txt` e `toolchain.txt` com data.
3.  **Dependências de validação** (L3 + G1.3-1.4): instalar/verificar perfil core (`metafor`, `testthat`, `roxygen2`, `knitr`, `rmarkdown`, `clubSandwich`, `wildmeta`, `dosresmeta`, `mixmeta`, `plotly`, `gt`, `flextable`, `openxlsx2`, `readxl`, `waldo`, `PublicationBias`, `meta`, `metasens`, `metaforest`, `caret`, `ranger`, `jsonlite`, `htmlwidgets`) + perfil bayes (`bayesmeta`, `BayesTools`, `RoBMA`, `posterior`, `bayesplot`, `loo`, opcional `brms`+Stan). Registrar `backend_versions.csv`.
4.  **Confirmação de versões** (L4): checar mínimos (`metafor>=5.0-1`, `mixmeta>=1.2.2`, `bayesmeta>=3.5`, `BayesTools>=0.3.0`, `RoBMA>=4.0.0`, `PublicationBias>=2.4.0`, `metaforest>=0.1.5`).

### Fase 2 — Documentação autoritativa e parsing (LOCAL 5-7 + GUIA 7)
5.  **Roxygen regeneration** (L5): `roxygen2::roxygenise(Pkg)`, comparar `NAMESPACE`/`man/` com snapshots, validar 12 `stopifnot` de exports (`apm_multivariate`, `apm_bayes`, `predict.apm_bayes`, `autoplot.apm_multivariate`, `apm_influence`, `apm_bias`, `apm_moderator_screen`, `apm_report`, `apm_export`, `apm_workflow`, `apm_capabilities`, `apm_doctor`, `print.apm_workflow`, `print.apm_doctor`) e contagem 57 exports.
6.  **Parse R/** (L6): `parse()` em todo `R/*.R` — zero erros.
7.  **Instalação em library temporária limpa** (L7 + G1.3): `install.packages(Pkg, repos=NULL, type="source", lib=<tmp>)`, checar `packageVersion==1.0.0.9000`.

### Fase 3 — Testes e registries estáveis (LOCAL 8, 8A, 8B, 8C + GUIA 3.1, 3.3)
8.  **testthat completo** (L8): `testthat::test_dir(..., reporter="summary")` — 0 falhas, 0 skips indevidos; repetir com backends opcionais.
8A. **Capability registry** (L8A): `apm_capabilities(installed=TRUE, detail="full")` — >=20 linhas, colunas completas, core `effect-sizes==AVAILABLE`, `dose-response` e `bayesian` como não-core, regras de `NOT INSTALLED`/`VERSION TOO OLD`/CmdStan; salvar `capabilities.csv`.
8B. **apm_doctor non-mutating** (L8B): `apm_doctor(full=FALSE,...)` e `full=TRUE` — status PASS/WARN/FAIL/NOT RUN, `mutated_environment==FALSE`, não instala nada; salvar `doctor_checks.csv`.
8C. **apm_workflow equivalência manual** (L8C): 5 cenários — shared_control vs `apm_effect_size`+`apm_vcov`+`apm_multilevel` (coef `1e-10`, V `1e-12`), auto-routing com `routing_log$source=="auto"`, moderators+threshold, paired design + guard `r_tc==NULL` → try-error, robust e bayesian opcionais.

### Fase 4 — Validação numérica central (LOCAL 9-16)
9.  **Multivariada** (L9): `apm_multivariate` vs `metafor::rma.mv` UN/CS/DIAG (`1e-8`), `apm_mvcor_sensitivity` rho 0/0.25/0.5/0.75 + verificação eigen PSD, `mixmeta` cross-check CS.
10. **Prior / prior-predictive** (L10): `apm_prior` + `apm_prior_check` determinístico (seed idempotente, `ratio` finito, plausibilidade agronômica).
11. **bayesmeta** (L11): intercept vs `bayesmeta::bayesmeta` (`qposterior`/`pposterior` `1e-10`), meta-regression `bmr` + `qpredict` idem.
12. **Threshold bayesiano** (L12): `apm_bayes_threshold` percent/predictive, two-sided vs CDF (`1e-10`).
13. **RoBMA/JAGS** (L13): `apm_bayes(backend="RoBMA", chains=3,iter=5000,warmup=2000)` + `apm_bayes_diagnostics` + `predict(...,type="estimate")` match `1e-8` (se JAGS OK).
14. **BayesTools translation** (L14): 5 priors tau (`halfnormal`, `halft`, `halfcauchy`, `exponential`, `uniform`) via `.apm_to_bayestools_prior`.
15. **brms/Stan opcional** (L15): `apm_bayes(backend="brms", chains=4,iter=4000)` + diagnostics + `posterior_epred` targets (`brms latent true-effect` vs `population-level mean` `1e-8`) se Stan OK.
16. **Model comparison** (L16): `apm_bayes_compare` com `loo`/`waic`/`model_probability`, Pareto-k.

### Fase 5 — Diagnósticos, sensibilidade, visualização, reporting (LOCAL 17-25 + GUIA 3.3, 3.4, 10)
17. **Leave-one-out / influence** (L17): `apm_leave_one_out` vs `metafor::leave1out` (`1e-8`) + `apm_influence` nrow match, cluster-aware V submatrix.
18. **GOSH** (L18): `apm_gosh(subsets=100,seed=2026)` idempotente, cluster-respecting.
19. **Publication bias** (L19): `apm_bias(methods=egger/rank/trimfill/selection)` vs `metafor::regtest/ranktest/trimfill/selmodel`, `PublicationBias::pubbias_svalue`, `metasens::copas/limit`.
20. **Contour funnel / orchard** (L20): `apm_funnel_contour` + `apm_orchard` → ggplot + `apm_plot_data`, checagem visual e vs `orchaRd`.
21. **MetaForest** (L21): `apm_moderator_screen` tune FALSE/TRUE, cluster-aware CV, `exploratory==TRUE`.
22. **Explain / report / export** (L22): `apm_explain` determinístico, `apm_export` rds/csv/json/xlsx, render HTML+DOCX (PDF se LaTeX OK), PNG/TIFF 600dpi + SVG sem clipping.
23. **Vignettes** (L23): `rmarkdown::render` em todo `vignettes/*.Rmd` + blocos bayesianos `eval=FALSE` sob demanda.
24. **Visual inspection** (L24): `apm_multivariate_plot` forest/correlation + `apm_prior_check$plot` — eixos, transformações, linhas de referência.
25. **Examples** (L25): `tools::Rd2ex` + `source` em `man/apm_multivariate.Rd` e `man/apm_bayes.Rd`; definitivo virá do `R CMD check`.

### Fase 6 — Build / Check / Freeze (LOCAL 26-29 + GUIA 3.2, 7)
26. **Build 1.0.0.9000** (L26): `R CMD build agriPairMetaFlow` no parent, capturar filename + SHA256 em `_tarballs/`.
27. **Check --as-cran** (L27): `R CMD check --as-cran agriPairMetaFlow_1.0.0.9000.tar.gz` — alvo 0 ERROR, 0 WARNING; classificar NOTEs (ex. `New submission` ambiental OK, `Examples >5s` investigar).
28. **Re-teste do tarball** (L28): instalar tarball exato em nova library limpa + rerun core/multivariate/bayes/S3.
29. **Freeze evidence** (L29): arquivar `sessionInfo.txt`, `backend_versions.csv`, `roxygen_log.txt`, `testthat_log.txt`, `vignette_render_log.txt`, `R_CMD_build.log`, `R_CMD_check_as_cran.log`, `built_tarball_sha256.txt`, `Bayesian_diagnostics/`, `plot_inspection_notes.md` em `_validation_local/` e `_archive_1.0.0/`.

### Fase 7 — Promoção para 1.0.0 formal (LOCAL 30-32)
30. **Promoção** (L30):
   - 30.1 Editar só `DESCRIPTION` `Version: 1.0.0` + `NEWS.md` heading + data validação, sem alterar código estatístico.
   - 30.2 `roxygen2::roxygenise()` novamente.
   - 30.3 `R CMD build` → `agriPairMetaFlow_1.0.0.tar.gz` em `_tarballs/`, congelar imediatamente.
   - 30.4 `R CMD check --as-cran agriPairMetaFlow_1.0.0.tar.gz`, ler `00check.log`.
   - 30.5 Instalar em `release_lib` limpa, `packageVersion=="1.0.0"`, smoke + workflow + `apm_doctor(full=TRUE)`.
31. **Hash & archive formal** (L31): `Get-FileHash SHA256` para `.tar.gz` + `.zip`, gerar `SHA256SUMS.txt` + arquivar `DESCRIPTION`, `NAMESPACE`, `NEWS.md`, `ARCHITECTURE.md`, `STATE_OF_THE_ART.md`, `IMPLEMENTATION_SUMMARY.md`, `LOCAL_VALIDATION.md`, `VALIDATION.md`, `00check.log`, `sessionInfo`, `backend_versions`, `capabilities`, `doctor_checks`, `testthat_log`, `example_log`, `vignette_render_log`, `plot_inspection_notes`, `Bayesian_diagnostics/`.
32. **Checklist final** (L32): 21 itens PASS (versão 1.0.0, 57 exports, 3 exemplos por função, 3 chamadas vignette por função, S3 dispatch, parse OK, core tests, optional backends, workflow equivalência, shared-control V, robust/dose/multivariate/bayesian/bias/MetaForest, seeds, vignettes OK, frozen results, figuras OK, HTML/DOCX OK, build OK, check --as-cran OK, smoke do tarball OK, hashes/logs arquivados).

### Fase 8 — Publicação GitHub + site pkgdown (GUIA 5-6 + STATUS para https://wep69.github.io/)
33. **Higiene CRAN** (G7): validar nomes de vignette `^[A-Za-z]`, Rd usage ≤90 cols, S3 `\method`, ASCII, `globalVariables`, `.Rbuildignore` vs `.gitignore`, `system2(env=)`, `geom_contour` grade regular etc.
34. **Git** (G5): `git init -b main` se ausente, `.gitignore` (Rhistory, Rcheck, doc/, docs/, *.tar.gz, backups), `git add -A`, `git commit -F COMMIT_MESSAGE.md`, `gh repo create wep69/agriPairMetaFlow --public --source . --remote origin --push` se ainda não existe, senão `git push origin main`, conferir `git log origin/main --oneline -1` + `git status` limpo.
35. **Builders remotos** (G4): `devtools::check_win_devel(manual=TRUE)`, `check_win_release`, `check_mac_release` / `rhub::check_for_cran()` (resultado por e-mail/página).
36. **CI GitHub Actions** (G6): workflow `.github/workflows/R-CMD-check.yaml` pak-matrix (3 jobs `--no-build-vignettes` + 1 Ubuntu release `--as-cran` completo), com `r-lib/actions/setup-r`, `setup-pandoc`, `setup-r-dependencies`/`pak`, `check-r-package` com `args` por matrix; push dispara, monitorar `gh run list/view/watch`.
37. **pkgdown site** (G6 + G10): `_pkgdown.yml` já em `url: https://wep69.github.io/agriPairMetaFlow/`, `pkgdown::build_site()` local, validar `docs/` ou `gh-pages`, ativar GitHub Pages (Settings → Pages → Source `gh-pages` ou `docs/` na branch `main`), push site, conferir `https://wep69.github.io/agriPairMetaFlow/` verde.
38. **README / CITATION / URL hygiene**: `Authors@R` real, `URL`/`BugReports` no DESCRIPTION, `CITATION.cff` se houver.

### Entregáveis finais (na pasta de origem, subfolders)
- Versão indicada: `DESCRIPTION:Version: 1.0.0` (e `packageVersion("agriPairMetaFlow")=="1.0.0"` após instalação do tarball formal)
- TAR de código-fonte: `_tarballs/agriPairMetaFlow_1.0.0.tar.gz` + `_archive_1.0.0/SHA256SUMS.txt` + cópia `_tarballs/agriPairMetaFlow_1.0.0.9000.tar.gz` de referência
- Logs e evidências: `_validation_local/logs/*.txt`, `_archive_1.0.0/00check.log`, `sessionInfo.txt`, `capabilities.csv`, `doctor_checks.csv`, `testthat_log.txt`, `R_CMD_build.log`, `R_CMD_check_as_cran.log`
- Site publicado: `https://wep69.github.io/agriPairMetaFlow/` (pkgdown)

## Critérios de aceite globais (L32 + G11)
- Zero parse errors; 57/57 exports após roxygen; todo S3 dispatch OK; todo R file parse OK.
- `testthat` core 0 FAIL com `skipped:0` nos backends disponíveis; optional só skip se dependência genuinamente ausente.
- Equivalências numéricas dentro de tolerâncias (`1e-8` coef, `1e-10`/`1e-12` bayes/V).
- Vignettes render sem `Execution halted`; `Output created` presente; figuras sem clipping.
- `R CMD check --as-cran` no tarball exato: 0 ERROR, 0 WARNING, NOTEs classificadas; reinstalação do tarball passa smoke.
- Hashes SHA256 idênticos entre ZIP/TAR.GZ por arquivo; tarball final byte-for-byte o mesmo que recebeu `00check.log`.
- Git `main` limpo, push confirmado, CI 4/4 verde, pkgdown publicado e acessível.

## Referência de execução local
```powershell
$env:PATH="C:\Program Files\R\R-4.6.0\bin\x64;C:\rtools45\usr\bin;C:\Program Files\Quarto\bin;"+$env:Path
$env:RSTUDIO_PANDOC="C:\Program Files\Quarto\bin\tools"
$env:_R_CHECK_FORCE_SUGGESTS_="true"
& 'C:\Program Files\R\R-4.6.0\bin\x64\Rscript.exe' -e "sessionInfo()"
```

---
**Próximo passo:** materializar snapshot imutável dentro da pasta de origem, criar subfolders e iniciar Fase 1 (toolchain + dependências).
