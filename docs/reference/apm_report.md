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
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c8829ee5537.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c8829ee5537.source.Rmd 
#> object hash: bb3d449ff41cc0107737293d3eb9fb98 
# Example 2: reduced section inventory.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), format="html", sections=c("model","prediction","plots"))
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c88460e4ee6.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c88460e4ee6.source.Rmd 
#> object hash: 319645fddbc7812fb0c7838ce6213f59 
# Example 3: explicit title and reproducibility seed.
if(requireNamespace("rmarkdown",quietly=TRUE)) apm_report(apm_fit(agri_effects_benchmark), tempfile(fileext=".html"), title="Agronomic treatment-control synthesis", seed=2026)
#> <apm_report>
#> file: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c8868c03213.html 
#> source: C:/Users/wep69/AppData/Local/Temp/RtmpkZHCoR/file5c8868c03213.source.Rmd 
#> object hash: cf547882b393bcf5a7ec43433982b0e0 
```
