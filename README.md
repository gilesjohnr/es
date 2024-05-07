<!-- badges: start -->
[![R-CMD-check](https://github.com/gilesjohnr/es/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gilesjohnr/es/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# **es**: an R package for analyzing environmental sampling data <img src="man/figures/logo.png" align="right" height="138" alt="" />

This package provides reproducible functions for parsing and compiling data sets that measure infectious disease burden using Environmental Sampling (ES) methods. The tools here were developed specifically for epidemiological surveillance studies for multiple pathogens in locations such as Dhaka, Bangladesh and Karachi, Pakistan. However, the functions should generalize to other applications provided they use the same data formats. This package is currently in development and maintained by John Giles ([@gilesjohnr](https://github.com/gilesjohnr)), details on data and models below.


## Required data

The tools here are intended to do the heavy lifting when combining data from multiple sources and calculating relevant quantities. However, the use must start by putting their data into the following standard format:

  1. A standardized ES data format
  
  2. For viral load calculations, information on standard curves are also required.



## Methods

#### Derivative quantities

  1. Calculate viral load (requires standard curve data)
  
  2. Calculate delta delta Ct (requires a reference target)
  
#### Adding metadata

  3. Retrieve metadata: 
  
     - Precipitation
     - Temperature
     - Evaporative Stress Index (ESI)
     - Elevation
     - Topography (slope, aspect)
     - Topographical Wetness Index (TWI)
     - Flow Accumulation
     - Discharge of nearest river
     - Catchments
     - Population sizes (catchment, admin unit, within buffer)
     - Flood potential
     - ESA land use type (10m)
     - Administrative units
     - World Bank variables: poverty, access to electricity
     
  
  4. Calculate summary sampling statistics
  
  5. Estimate cross correlations
  
  6. Estimate time series models
  
  7. Estimate models of pathogen presence based on multiple gene targets

## Visualization

  8. Launch Rshiny application

## Examples

For a full demo of the package please see the vignettes located HERE.


## Installation

Use the `devtools` package to install the development version of `es` from the GitHub repository. R version >= 3.5.0 recommended.
```r
install.packages("whitebox", dependencies=TRUE)
whitebox::install_whitebox()
whitebox::wbt_version()

install.packages('devtools')
devtools::install_github("ropenscilabs/geojsonlint", dependencies=TRUE)
devtools::install_github('wpgp/wopr', dependencies=TRUE)
devtools::install_github("gilesjohnr/es", dependencies=TRUE)
```


## Troubleshooting

For general questions, contact John Giles (john.giles@gatesfoundation.org) and/or Jillian Gauld (jillian.gauld@gatesfoundation.org). Note that this software is made available under a [Creative Commons 4.0](https://creativecommons.org/licenses/by/4.0/) license and was developed for specific environmental sampling applications and therefore may not generalize perfectly to all settings.


## Funding

This work was developed at the [Institute for Disease Modeling](https://www.idmod.org/) in support of funded research grants made by the [Bill \& Melinda Gates Foundation](https://www.gatesfoundation.org/).
