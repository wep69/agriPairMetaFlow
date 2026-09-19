# Render a reproducible meta-analysis report without refitting the model

Development-snapshot manual for apm_report. The roxygen source in R/ is
authoritative; regenerate with roxygen2 during local validation.

## Usage

``` r
apm_report(...)
```

## Arguments

- ...:

  See the complete roxygen documentation and vignettes for arguments and
  method-specific assumptions.

## Value

An auditable agriPairMetaFlow result or output object as documented in
the function source.

## Examples

``` r
# Example 1: HTML report from a fitted agronomic meta-analysis.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html")
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc7a81283c.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc7a81283c.source.Rmd 
#> object hash: 71a120556aa55730a55a8ff28f23fb93 
# Example 2: reduced section inventory.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html", sections=c("model","prediction","plots"))
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc7d3d41f5.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc7d3d41f5.source.Rmd 
#> object hash: e336830e556cf4e437fee0d03b6453ff 
# Example 3: explicit title and reproducibility seed.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), title="Agronomic treatment-control synthesis", seed=2026)
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc47eb3f65.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcPJyeJ/filecdc47eb3f65.source.Rmd 
#> object hash: 04353caafdd6915fe47501c57f1affed 
```
