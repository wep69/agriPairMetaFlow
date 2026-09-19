# Draw standard or contour-enhanced funnel plots

Draw standard or contour-enhanced funnel plots. This conservative manual
snapshot is regenerated from the authoritative roxygen source before
release.

## Usage

``` r
apm_funnel(model, yaxis = c("se", "vi", "precision", "n"), contour = FALSE, levels = c(0.90, 0.95, 0.99), label = FALSE, interactive = FALSE)
```

## Value

A documented agriPairMetaFlow S3 object or presentation object,
depending on the function.

## Examples

``` r
# Example 1: standard funnel plot.
apm_funnel(apm_fit(agri_effects_benchmark))

# Example 2: contour-enhanced funnel plot.
apm_funnel(apm_fit(agri_effects_benchmark), contour=TRUE)

# Example 3: precision-axis interactive plot when plotly is available.
if (requireNamespace("plotly", quietly=TRUE)) apm_funnel(apm_fit(agri_effects_benchmark), yaxis="precision", interactive=TRUE)

{"x":{"data":[{"x":[0.207013,0.25045299999999998,0.20098299999999999,0.091330999999999996,0.10653,0.29353200000000002,0.046698000000000003,0.136017,0.068557000000000007,-0.065601000000000007,0.28823100000000001,0.054359999999999999,0.058339000000000002,0.131884,0.20388000000000001,0.14185,0.187168,-0.038420999999999997,-0.046390000000000001,-0.15650700000000001,-0.17924399999999999,0.18017900000000001,-0.034403999999999997,0.12156699999999999],"y":[10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949,10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949,10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949,10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949,10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949,10.259783520851542,9.5346258924559226,8.9442719099991592,11.180339887498949],"text":["effect:  0.207013<br />y: 10.259784","effect:  0.250453<br />y:  9.534626","effect:  0.200983<br />y:  8.944272","effect:  0.091331<br />y: 11.180340","effect:  0.106530<br />y: 10.259784","effect:  0.293532<br />y:  9.534626","effect:  0.046698<br />y:  8.944272","effect:  0.136017<br />y: 11.180340","effect:  0.068557<br />y: 10.259784","effect: -0.065601<br />y:  9.534626","effect:  0.288231<br />y:  8.944272","effect:  0.054360<br />y: 11.180340","effect:  0.058339<br />y: 10.259784","effect:  0.131884<br />y:  9.534626","effect:  0.203880<br />y:  8.944272","effect:  0.141850<br />y: 11.180340","effect:  0.187168<br />y: 10.259784","effect: -0.038421<br />y:  9.534626","effect: -0.046390<br />y:  8.944272","effect: -0.156507<br />y: 11.180340","effect: -0.179244<br />y: 10.259784","effect:  0.180179<br />y:  9.534626","effect: -0.034404<br />y:  8.944272","effect:  0.121567<br />y: 11.180340"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(0,0,0,1)","opacity":1,"size":5.6692913385826778,"symbol":"circle","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)"}},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null},{"x":[0.09149549578723408,0.09149549578723408],"y":[8.8324685111241692,11.292143286373939],"text":"xintercept: 0.0914955","type":"scatter","mode":"lines","line":{"width":1.8897637795275593,"color":"rgba(0,0,0,1)","dash":"dash"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":23.305936073059364,"r":7.3059360730593621,"b":37.260273972602747,"l":48.949771689497723},"paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[-0.20288279999999997,0.31717080000000003],"tickmode":"array","ticktext":["-0.2","-0.1","0.0","0.1","0.2","0.3"],"tickvals":[-0.20000000000000001,-0.10000000000000001,0,0.10000000000000003,0.20000000000000001,0.29999999999999999],"categoryorder":"array","categoryarray":["-0.2","-0.1","0.0","0.1","0.2","0.3"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"y","title":{"text":"Effect (lnRR)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[8.8324685111241692,11.292143286373939],"tickmode":"array","ticktext":["9.0","9.5","10.0","10.5","11.0"],"tickvals":[9,9.5,10,10.5,11],"categoryorder":"array","categoryarray":["9.0","9.5","10.0","10.5","11.0"],"nticks":null,"ticks":"","tickcolor":null,"ticklen":3.6529680365296811,"tickwidth":0,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.68949771689498},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(235,235,235,1)","gridwidth":0.66417600664176002,"zeroline":false,"anchor":"x","title":{"text":"precision","font":{"color":"rgba(0,0,0,1)","family":"","size":14.611872146118724}},"hoverformat":".2f"},"shapes":[],"showlegend":false,"legend":{"bgcolor":null,"bordercolor":null,"borderwidth":0,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.68949771689498}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"cdc765266a9":{"x":{},"y":{},"type":"scatter"},"cdc63fb53ee":{"xintercept":{}}},"cur_data":"cdc765266a9","visdat":{"cdc765266a9":["function (y) ","x"],"cdc63fb53ee":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}
```
