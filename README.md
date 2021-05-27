# Functional Dataset Consistency Explorer (FDCE)

Many high-throughput screening studies have been carried out in cancer cell lines to identify therapeutic agents and targets. Existing consistency assessment studies only examined two datasets at a time, with conclusions based on a subset of carefully selected features rather than considering global consistency of all the data. However, poor concordance can still be observed for a large part of the data even when selected features are highly consistent.

We assembled nine compound screening datasets and three functional genomics datasets, and derived direct measures of consistency as well as indirect measures of consistency based on association between functional data and copy number-adjusted gene expression data. These results have been integrated into a web application – the Functional Data Consistency Explorer (FDCE), to allow users to make queries and generate interactive visualizations so that functional data consistency can be assessed for individual features of interest.

This directory contains source codes used to construct shiny app at 
* https://lccl.shinyapps.io/FDCE/. 

Input data files can be found under 
* https://doi.org/10.5061/dryad.95x69p8kq.
