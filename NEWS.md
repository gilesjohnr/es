
# es v1.0.0 released June 04, 2024 (deprecated July 03, 2024)

Welcome to the first release of the `es` R package! Version 1.0.0 contains a collection of basic features that aim to make analyzing environmental sampling data easier and more reproducible. The functionality we have included to kick off the package includes:

  * Detailed descriptions of standard data formats for environmental sampling data and standard curve assays. The functionality of the package requires data to follow these formats.
  * Functions for the absolute and relative quantification of qPCR data which include:
      - Calculating the number of gene copies using Ct values and a standard curve assay
      - Calculating the $\Delta \Delta \text{Ct}$ method for the fold-change in gene expression relative to a reference gene. An efficiency-weighted version is also included.
      - Estimation of the percentile amplification efficiency using a standard curve assay.
  * Functions for downloading covariate data from several open-source APIs and methods for relating these data to environmental sampling observations. These data include:
      - Climate
         * Data from Open-Meteo Historical Weather API
         * cumulative precipitation
         * accumulated thermal units
         * Evaporative Stress Index (ESI)
      - Topology and hydrology
         * Data from Amazon Web Services (AWS) API
         * elevation
         * slope
         * aspect
         * flow accumulation
         * stream networks
         * drainage catchments
      - Local population
         * Data from WorldPop
         * Population counts in drainage catchments
         * Population counts within radius
       - Administrative boundaries
         * Data from geoBoundaries
         * Place names of sampling sites
  * Basic calculation of sample sizes and detection rates
