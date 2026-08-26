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
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec6db142f.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec6db142f.source.Rmd 
#> object hash: cb69036fc3fde4664630fe1b7201c065 
# Example 2: reduced section inventory.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html", sections=c("model","prediction","plots"))
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec1c2f6932.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec1c2f6932.source.Rmd 
#> object hash: cb69036fc3fde4664630fe1b7201c065 
# Example 3: explicit title and reproducibility seed.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), title="Agronomic treatment-control synthesis", seed=2026)
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec70d839da.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpcjLDfO/filebec70d839da.source.Rmd 
#> object hash: cb69036fc3fde4664630fe1b7201c065 
```
