from pathlib import Path
import re, sys, csv
root=Path(__file__).resolve().parents[1]
exports=['apm_read','apm_validate','apm_audit','apm_plan','apm_recover_uncertainty','apm_effect_size','apm_fit','apm_subgroup','apm_heterogeneity','apm_prediction','apm_threshold','apm_forest','apm_funnel','apm_table','apm_shared_control','apm_vcov','apm_pair_vcov','apm_dependence_audit','apm_rho_sensitivity','apm_multilevel','apm_variance_components','apm_robust','apm_wild_bootstrap','apm_compare_inference','apm_metareg','apm_marginal_effects','apm_interaction','apm_metareg_curve','apm_model_compare','apm_predict_context','apm_curve_features','apm_dose_response','apm_dose_plot','apm_bubble','apm_multivariate','apm_mvcor_sensitivity','apm_prior','apm_prior_check','apm_bayes','apm_bayes_predict','apm_bayes_threshold','apm_bayes_diagnostics','apm_bayes_compare','apm_multivariate_plot','apm_influence','apm_leave_one_out','apm_gosh','apm_bias','apm_funnel_contour','apm_orchard','apm_moderator_screen','apm_report','apm_explain','apm_export','apm_workflow','apm_capabilities','apm_doctor']
checks=[]
def add(name,ok,detail=''): checks.append((name,bool(ok),detail))
ns=(root/'NAMESPACE').read_text()

def code_only(t):
    out=[]
    for line in t.splitlines():
        s=''; quote=None; esc=False
        for ch in line:
            if quote:
                if esc: esc=False
                elif ch=='\\': esc=True
                elif ch==quote: quote=None
                s+=' '
            else:
                if ch in ('"',"'"): quote=ch; s+=' '
                elif ch=='#': break
                else: s+=ch
        out.append(s)
    return '\n'.join(out)

def find_fun_block(fun):
    pat=re.compile(r'^'+re.escape(fun)+r'\s*<-\s*function')
    for p in (root/'R').glob('*.R'):
        lines=p.read_text().splitlines()
        for i,line in enumerate(lines):
            if pat.search(line):
                j=i-1; block=[]
                while j>=0 and lines[j].startswith("#'"):
                    block.append(lines[j]); j-=1
                return p, '\n'.join(reversed(block))
    return None,''

for f in exports:
    add('export:'+f, f'export({f})' in ns)
    p,block=find_fun_block(f)
    add('source:'+f,p is not None)
    add('roxygen:'+f, "#' @export" in block and "#' @examples" in block, p.name if p else '')
    add('3examples:'+f, block.count(f+'(') >= 3, str(block.count(f+'(')))
    manp=root/'man'/f'{f}.Rd'
    add('man:'+f,manp.exists())
    if manp.exists():
        mt=manp.read_text(); add('man-3examples:'+f, mt.count(f+'(') >= 3, str(mt.count(f+'(')))
    vt='\n'.join(q.read_text() for q in (root/'vignettes').glob('*.Rmd'))
    add('vignette-3calls:'+f, vt.count(f+'(') >= 3, str(vt.count(f+'(')))
    add('test:'+f, any(f in q.read_text() for q in (root/'tests/testthat').glob('test-*.R')))
for p in (root/'R').glob('*.R'):
    c=code_only(p.read_text())
    add('delimiter:'+p.name, c.count('{')==c.count('}') and c.count('(')==c.count(')'), f"braces {c.count('{')}/{c.count('}')} parens {c.count('(')}/{c.count(')')}")
for name in ['maize_n_shared','covercrop_variability','irrigation_climate','bioinoculant_multicrop','wheat_paired_blocks','agri_uncertainty_mixed','pest_suppression_binary','agri_effects_benchmark','soil_management_multiresponse','fertilizer_dose_response','biochar_multiresponse']:
    add('extdata:'+name,(root/'inst/extdata'/f'{name}.csv').exists()); add('data-doc:'+name,(root/'man'/f'{name}.Rd').exists())
for v in ['v00-foundations-to-advanced-tutorial.Rmd','v01-data-effect-sizes-uncertainty.Rmd','v02-models-heterogeneity-prediction.Rmd','v03-api-example-reference.Rmd','v03-shared-controls-paired-dependence.Rmd','v04-multilevel-robust-inference.Rmd','v05-meta-regression-quantitative-moderators.Rmd','v06-dose-response-meta-analysis.Rmd','v07-api-example-reference-0.3.Rmd','v08-multivariate-meta-analysis.Rmd','v09-bayesian-meta-analysis.Rmd','v10-api-example-reference-0.4.Rmd','v11-diagnostics-influence-and-gosh.Rmd','v12-publication-bias-and-advanced-visualization.Rmd','v13-exploratory-moderators-reporting-and-export.Rmd','v14-api-example-reference-0.5.Rmd','v15-integration-workflow-and-release-readiness.Rmd']:
    add('vignette:'+v,(root/'vignettes'/v).exists())
readme=(root/'README.md').read_text(); add('runtime-honesty','not installed or executed' in readme and 'Mandatory local gates' in readme and 'local' in readme.lower())
fail=[x for x in checks if not x[1]]
print(f'Static checks: {len(checks)-len(fail)}/{len(checks)} PASS')
for x in fail: print('FAIL',x)
with open(root/'inst/metadata/static_validation.csv','w',newline='') as fh:
    wr=csv.writer(fh); wr.writerow(['check','status','detail']); wr.writerows((n,'PASS' if ok else 'FAIL',d) for n,ok,d in checks)
# Continue to the 0.3.0 extended gates below.

# 0.3.0 release-block static gates (runtime remains local by project decision).
desc=(root/'DESCRIPTION').read_text()
add('version:1.0.0.9000', 'Version: 1.0.0.9000' in desc)
add('suggests:dosresmeta', re.search(r'(?m)^\s*dosresmeta(?:\s*\([^)]*\))?,?\s*$', desc) is not None)
add('suggests:mixmeta', re.search(r'(?m)^\s*mixmeta(?:\s*\([^)]*\))?,?\s*$', desc) is not None)
add('api-count:57', len(set(exports)) == 57)
new03=['apm_metareg','apm_marginal_effects','apm_interaction','apm_metareg_curve','apm_model_compare','apm_predict_context','apm_curve_features','apm_dose_response','apm_dose_plot','apm_bubble']
expected_tests=['test-metareg.R','test-marginal-effects.R','test-interaction.R','test-metareg-curve.R','test-model-compare.R','test-predict-context.R','test-curve-features.R','test-dose-response.R','test-plot-dose.R','test-plot-bubble.R']
for fn in expected_tests:
    add('dedicated-test:'+fn,(root/'tests/testthat'/fn).exists())
for p in (root/'tests/testthat').glob('test-*.R'):
    c=code_only(p.read_text())
    add('test-delimiter:'+p.name,c.count('{')==c.count('}') and c.count('(')==c.count(')') and c.count('[')==c.count(']'),f"braces {c.count('{')}/{c.count('}')} parens {c.count('(')}/{c.count(')')} brackets {c.count('[')}/{c.count(']')}")

# Dose-response teaching-data structural invariants.
try:
    with open(root/'inst/extdata/fertilizer_dose_response.csv',newline='') as fh:
        rows=list(csv.DictReader(fh))
    need={'study_id','N_rate','crop','soil_texture','lnRR','vi','sei','measure','dose_unit','treatment_id','control_id'}
    add('dose-data:required-columns',need.issubset(rows[0].keys()) if rows else False)
    studies=sorted({r['study_id'] for r in rows})
    add('dose-data:8-studies',len(studies)==8)
    add('dose-data:4-doses-per-study',all(len({r['N_rate'] for r in rows if r['study_id']==sid})==4 for sid in studies))
    add('dose-data:study-level-crop',all(len({r['crop'] for r in rows if r['study_id']==sid})==1 for sid in studies))
    add('dose-data:study-level-soil',all(len({r['soil_texture'] for r in rows if r['study_id']==sid})==1 for sid in studies))
    add('dose-data:unit-consistent',len({r['dose_unit'] for r in rows})==1)
except Exception as e:
    add('dose-data:readable',False,str(e))

# Verify extdata hashes produced in this construction environment.
try:
    import hashlib
    hp=root/'inst/metadata/data_hashes.csv'
    with open(hp,newline='') as fh: hrows=list(csv.DictReader(fh))
    ok=True; details=[]
    for r in hrows:
        fp=root/'inst/extdata'/r['file']
        actual=hashlib.sha256(fp.read_bytes()).hexdigest() if fp.exists() else ''
        if actual != r['sha256']:
            ok=False;details.append(r['file'])
    add('extdata:sha256',ok,','.join(details))
except Exception as e:
    add('extdata:sha256',False,str(e))

val=(root/'VALIDATION.md').read_text()
add('local-runtime-policy','NOT RUN / LOCAL' in val and 'does not install or execute R' in val)

# Hardened 0.3.0 scientific-safety gates added before freezing the snapshot.
mc=(root/'R/model-compare.R').read_text()
add('model-compare:design-hashes','design_hashes' in mc and 'fixed_design_changed' in mc)
add('model-compare:column-space-nesting','matrix_rank(cbind(Xj, Xi)) == matrix_rank(Xj)' in mc)
add('model-compare:likelihood-ml-guard','Likelihood-based comparison across different fixed-effect designs requires ML fits' in mc)
pc=(root/'R/predict-context.R').read_text()
add('predict-context:probability-basis','probability_basis' in pc)
add('predict-context:metafor-prob','prob=paste0' in pc.replace(' ',''))
add('predict-context:multi-heterogeneity-guard','multiple heterogeneity components require an explicit prediction-level variance structure' in pc)
dr=(root/'R/dose-response.R').read_text()
add('dose-response:basis-rank-guard','qr(B[ii, , drop = FALSE], tol = 1e-10)$rank < p_basis' in dr)
add('dose-response:row-provenance','reference_rows = reference_idx' in dr and 'analysis_rows = analysis_idx' in dr)
add('dose-response:no-random-intercept-fallback','metafor-fixed-gls' in dr and 'method != "fixed"' in dr and 'random=~1' not in dr.replace(' ',''))
drt=(root/'tests/testthat/test-dose-response.R').read_text()
add('dose-response:test-generic-yi','generic yi column is not silently relabeled as lnRR' in drt)
add('dose-response:test-reference-index','explicit reference rows retain auditable original row provenance' in drt)
add('dose-response:test-rank','each study must identify every dose-basis coefficient' in drt)
add('s3:autoplot-dose','S3method(autoplot,apm_dose)' in ns and 'autoplot.apm_dose' in (root/'R/s3-extract.R').read_text())

# 0.4.0 multivariate and Bayesian static gates.
for pkg in ['bayesmeta','BayesTools','RoBMA','brms','posterior','loo']:
    add('suggests:'+pkg, re.search(r'(?mi)^\s*'+re.escape(pkg)+r'(?:\s*\([^)]*\))?,?\s*$', desc) is not None)
new04=['apm_multivariate','apm_mvcor_sensitivity','apm_prior','apm_prior_check','apm_bayes','apm_bayes_predict','apm_bayes_threshold','apm_bayes_diagnostics','apm_bayes_compare','apm_multivariate_plot']
expected04=['test-multivariate.R','test-sensitivity-mvcor.R','test-bayes-prior.R','test-bayes-prior-check.R','test-bayes-fit.R','test-bayes-predict.R','test-bayes-threshold.R','test-bayes-diagnostics.R','test-bayes-compare.R','test-plot-multivariate.R']
for fn in expected04:
    add('dedicated-test-0.4:'+fn,(root/'tests/testthat'/fn).exists())
add('data-0.4:biochar',(root/'inst/extdata/biochar_multiresponse.csv').exists())
try:
    with open(root/'inst/extdata/biochar_multiresponse.csv',newline='') as fh: br=list(csv.DictReader(fh))
    add('biochar-data:24-rows',len(br)==24)
    add('biochar-data:3-outcomes',len({r['outcome'] for r in br})==3)
    add('biochar-data:8-studies',len({r['study_id'] for r in br})==8)
    add('biochar-data:effect-columns',all(k in br[0] for k in ['lnRR','yi','vi','sei','measure']))
except Exception as e:
    add('biochar-data:readable',False,str(e))
# Guard the semantics of Bayesian prediction against accidental target drift.
bp=(root/'R/bayes-predict.R').read_text()
add('bayesmeta:qposterior-arguments','theta.p = p' in bp and 'mu.p = p' in bp)
add('bayesmeta:bmr-qpredict','qpredict' in bp and 'mean = !predictive' in bp)
add('robma:latent-prediction','ptype <- if (isTRUE(predictive)) "estimate" else "terms"' in bp)
add('brms:latent-prediction','posterior_epred' in bp and 'posterior_predict' not in bp and 'sample_new_levels = "gaussian"' in bp)
add('brms:mean-no-random-effects','re_formula = NA' in bp and 'brms population-level mean effect' in bp)
bf=(root/'R/bayes-fit.R').read_text()
add('robma:no-predictor-standardization','standardize_continuous_predictors=FALSE' in bf.replace(' ',''))
bpr=(root/'R/bayes-prior.R').read_text()
add('bayestools:exp-name','BayesTools::prior("exp"' in bpr)
add('bayestools:uniform-ab','parameters=list(a=spec$min,b=spec$max)' in bpr.replace(' ',''))
bth=(root/'R/bayes-threshold.R').read_text()
add('bayes-threshold:two-sided-outside-band','p <- plo + (1-phi)' in bth)
add('bayes:heavy-backends-suggests',all(x not in desc.split('Suggests:')[0] for x in ['bayesmeta','RoBMA','brms','BayesTools']))
add('mv:sensitivity-inject','rlang::inject(apm_multivariate' in (root/'R/sensitivity-mvcor.R').read_text())
mv=(root/'R/multivariate.R').read_text()
add('mv:mixmeta-ordering','.apm_source_row' in mv and 'fit_V <- fit_V[ord, ord, drop = FALSE]' in mv and 'control = list(addSlist = Slist)' in mv)
add('mv:prediction-intervals','outcome_tab$pi_lower' in mv and 'tau2_outcome' in mv and 'prediction_basis' in mv)
add('namespace:data-pronoun','importFrom(rlang,.data)' in ns)
add('s3:multivariate','S3method(autoplot,apm_multivariate)' in ns and 'S3method(summary,apm_multivariate)' in ns)
bdg=(root/'R/bayes-diagnostics.R').read_text()
add('bayes-diagnostics:verification-gate','diagnostics_verified' in bdg and 'R_hat' in bdg and 'ESS' in bdg and 'nuts_params' in bdg)
bcmp=(root/'R/bayes-compare.R').read_text()
add('bayes-compare:blocks-unverified','diagnostics_verified' in bcmp and 'failed or unverified convergence diagnostics' in bcmp)
add('bayes-compare:robma-loo-waic','RoBMA::add_loo' in bcmp and 'RoBMA::add_waic' in bcmp and 'same supported backend' in bcmp)
add('bayes-compare:stacking','loo_model_weights' in bcmp and 'stacking_weight' in bcmp and 'posterior model probabilities' in bcmp)
add('s3:bayes','S3method(predict,apm_bayes)' in ns and 'S3method(summary,apm_bayes)' in ns)


# 0.5.0 influence, bias sensitivity, visualization and communication gates.
for pkg in ['PublicationBias','meta','metasens','metaforest','orchaRd','caret','ranger','jsonlite','htmlwidgets']:
    add('suggests-0.5:'+pkg, re.search(r'(?mi)^\s*'+re.escape(pkg)+r'(?:\s*\([^)]*\))?,?\s*$', desc) is not None)
expected05=['test-diagnostics-influence.R','test-diagnostics-leave-one-out.R','test-diagnostics-gosh.R','test-publication-bias.R','test-plot-funnel-contour.R','test-plot-orchard.R','test-moderator-screen.R','test-report.R','test-explain.R','test-export.R']
for fn in expected05:
    add('dedicated-test-0.5:'+fn,(root/'tests/testthat'/fn).exists())
fitc=(root/'R/fit-core.R').read_text()
add('diagnostics:fit-preserves-V','V=if(is.null(V))NULLelseVfit' in fitc.replace(' ',''))
loo=(root/'R/diagnostics-leave-one-out.R').read_text(); infl=(root/'R/diagnostics-influence.R').read_text(); gosh=(root/'R/diagnostics-gosh.R').read_text()
add('loo:failed-refits-retained','n_fail' in loo and '.apm_failed_refit_row' in loo)
add('influence:no-auto-removal','No observation is removed automatically' in infl)
add('gosh:seed-provenance','seed=seed' in gosh.replace(' ',''))
bias=(root/'R/publication-bias.R').read_text()
add('bias:caution-not-proof','Funnel asymmetry is never labeled as proof' in bias)
add('bias:method-status','status=status_df' in bias.replace(' ',''))
add('bias:publicationbias-adapter','PublicationBias::pubbias_svalue' in bias and 'PublicationBias::pubbias_meta' in bias)
add('bias:metasens-adapter','metasens::copas' in bias and 'metasens::limitmeta' in bias)
orch=(root/'R/plot-orchard.R').read_text(); mf=(root/'R/moderator-screen.R').read_text()
add('orchard:native-ggplot','ggplot2::ggplot' in orch and 'orchaRd::' not in orch)
add('metaforest:exploratory','exploratory=TRUE' in mf.replace(' ',''))
add('metaforest:cluster-aware','study=clname' in mf.replace(' ',''))
rep=(root/'R/report.R').read_text(); exp=(root/'R/export.R').read_text(); expl=(root/'R/explain.R').read_text()
add('report:no-refit-statement','does not refit the statistical model' in rep)
add('report:provenance','object_hash' in rep and 'package_version' in rep and 'sessionInfo()' in rep)
add('explain:deterministic','deterministic' in expl.lower())
add('export:600dpi','dpi = 600' in exp)
add('export:object-rds','saveRDS' in exp)
add('namespace:0.5',all(('export('+f+')') in ns for f in ['apm_influence','apm_leave_one_out','apm_gosh','apm_bias','apm_funnel_contour','apm_orchard','apm_moderator_screen','apm_report','apm_explain','apm_export','apm_workflow','apm_capabilities','apm_doctor']))


# 1.0.0 integration and release-readiness gates.
expected10=['test-workflow.R','test-capabilities.R','test-doctor.R']
for fn in expected10:
    add('dedicated-test-1.0:'+fn,(root/'tests/testthat'/fn).exists())
for fn in ['apm_workflow','apm_capabilities','apm_doctor']:
    add('namespace-1.0:'+fn,('export('+fn+')') in ns)
    add('manual-1.0:'+fn,(root/'man'/f'{fn}.Rd').exists())
wf=(root/'R/workflow.R').read_text(); cap=(root/'R/capabilities.R').read_text(); doc=(root/'R/doctor.R').read_text()
add('workflow:routing-log','routing_log=route_df' in wf.replace(' ',''))
add('workflow:shared-control-V','apm_vcov' in wf and 'shared_control=TRUE' in wf.replace(' ',''))
add('workflow:paired-explicit-guard','treatment-control labeling alone is not pairing' in (root/'R/plan.R').read_text() and "dependence='paired' requires explicit paired information" in wf)
add('workflow:no-new-estimator',all(x in wf for x in ['apm_effect_size','apm_vcov','apm_fit','apm_multilevel','apm_metareg']))
add('workflow:manual-equivalence-test','manual <- apm_multilevel' in (root/'tests/testthat/test-workflow.R').read_text())
add('capabilities:registry','.apm_capability_registry' in cap and 'validation_tier' in cap and 'minimum_version' in cap)
add('capabilities:no-install','install.packages' not in cap and 'system(' not in cap)
add('doctor:non-mutating','mutated_environment=FALSE' in doc.replace(' ','') and 'utils::install.packages' not in doc and 'cmdstanr::install_cmdstan' not in doc)
add('doctor:status-vocabulary',all(x in doc for x in ['"PASS"','"WARN"','"FAIL"','"NOT RUN"']))
add('doctor:render-gate','pandoc_available' in doc and 'Sys.which("quarto")' in doc)
add('doctor:smoke-not-release','formal testthat remains a separate release gate' in doc)
add('s3:1.0',all(x in ns for x in ['S3method(print,apm_workflow)','S3method(print,apm_capabilities)','S3method(print,apm_doctor)']))
add('vignette:1.0-integration',(root/'vignettes/v15-integration-workflow-and-release-readiness.Rmd').exists())
add('readme:stable-api','57' in readme and '1.0' in readme)

# Rewrite evidence after the additional gates have been appended.
fail=[x for x in checks if not x[1]]
print(f'Extended static checks: {len(checks)-len(fail)}/{len(checks)} PASS')
for x in fail: print('FAIL',x)
with open(root/'inst/metadata/static_validation.csv','w',newline='') as fh:
    wr=csv.writer(fh); wr.writerow(['check','status','detail']); wr.writerows((n,'PASS' if ok else 'FAIL',d) for n,ok,d in checks)
sys.exit(1 if fail else 0)
