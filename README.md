
# **es**: an R package for analyzing environmental sampling data

This package provides reproducible functions for parsing and compiling data sets that measure infectious disease burden using Environmental Sampling (ES) methods. The tools here were developed specifically for epidemiological surveillance studies for multiple pathogens in locations such as Dhaka, Bangladesh and Karachi, Pakistan. However, the functions should generalize to other applications provided they use the same data formats. This package is currently in development and maintained by John Giles ([@gilesjohnr](https://github.com/gilesjohnr)), details on data and models below.


## Required data

The tools here are intended to do the heavy lifting when combining data from multiple sources and calculating relevant quantities. However, the use must start by putting their data into the following standard format:

For viral load calculations, information on standard curves are also required:




## Methods

The package also includes methods for calculating basic quantities from qPCR data such as:

  * Viral load
  
  * Delta delta Ct
  
  * Metadata: 
     - Climate variables
     - Topography
     - Catchement population sizes
  
  * Summary sampling statistics
  
  * Cross correlations
  
  * Timeseries models
  

## Visualization

The package launches an Rshiny app blah blah

## Examples

For a full demo of the package please see the vignettes located HERE.


## Installation

Use the `devtools` package to install the development version of `es` from the GitHub repository. R version >= 3.5.0 recommended.
```r
install.packages('devtools')
devtools::install_github("gilesjohnr/es", dependencies=TRUE)
```


## Troubleshooting

For general questions, contact John Giles (john.giles@gatesfoundation.org) and/or Jillian Gauld (jillian.gauld@gatesfoundation.org). Note that this software is made available under a [Creative Commons](https://creativecommons.org/publicdomain/zero/1.0/legalcode.en) license and was developed for specific environmental sampling applications and therefore may not generalize perfectly to all settings.


## Funding

This work was developed at the [Institute for Disease Modeling](https://www.idmod.org/) in support of funded research grants made by the [Bill \& Melinda Gates Foundation](https://www.gatesfoundation.org/).
