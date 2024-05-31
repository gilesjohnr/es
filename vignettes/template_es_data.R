## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  library(es)
#  head(template_es_data)
#  date location_id  lat   lon target_name ct_value
#  1 2020-03-07           1 23.8 90.37    target_0       NA
#  2 2020-03-07           1 23.8 90.37    target_0       NA
#  3 2020-03-07           1 23.8 90.37    target_0       NA
#  4 2020-03-07           1 23.8 90.37    target_0 29.94516
#  5 2020-03-07           1 23.8 90.37    target_1 31.61178
#  6 2020-03-07           1 23.8 90.37    target_1 32.22351
#  
#  str(template_es_data)
#  'data.frame':	5200 obs. of  6 variables:
#       $ date       : IDate, format: "2020-03-07" "2020-03-07" ...
#  $ location_id: int  1 1 1 1 1 1 1 1 1 1 ...
#  $ lat        : num  23.8 23.8 23.8 23.8 23.8 23.8 23.8 23.8 23.8 23.8 ...
#  $ lon        : num  90.4 90.4 90.4 90.4 90.4 ...
#  $ target_name: chr  "target_0" "target_0" "target_0" "target_0" ...
#  $ ct_value   : num  NA NA NA 29.9 31.6 ...

## ----echo=FALSE---------------------------------------------------------------
x <- data.frame(variable=as.character(),
                class=as.character(),
                description=as.character())

x[1, 'variable'] <- "date"
x[1, 'class'] <- "Date, IDate"
x[1, 'description'] <- "The date the environmental sample was collected. Format is YYY-MM-DD."

x[2, 'variable'] <- "location_id"
x[2, 'class'] <- "Integer, Character"
x[2, 'description'] <- "A unique identifier for each sampling location."

x[3, 'variable'] <- "lat"
x[3, 'class'] <- "Numeric"
x[3, 'description'] <- "The lattitude of the sampling location in Decimal Degrees (DD)"

x[4, 'variable'] <- "lon"
x[4, 'class'] <- "Numeric"
x[4, 'description'] <- "The longitude of the sampling location in Decimal Degrees (DD)"

x[5, 'variable'] <- "target_name"
x[5, 'class'] <- "Character"
x[5, 'description'] <- "The unique name of each gene target in qPCR assays"

x[6, 'variable'] <- "ct_value"
x[6, 'class'] <- "Numeric"
x[6, 'description'] <- "The Cycle Threshold (Ct) value returned by qPCR assays"

knitr::kable(
     x,
     col.names = c("Variable", 
                   "Class", 
                   "Description")
)

## ----eval=FALSE---------------------------------------------------------------
#  library(es)
#  head(template_standard_curve)
#    target_name n_copies ct_value
#  1    target_1    1e+01 31.29322
#  2    target_1    1e+02 27.73392
#  3    target_1    1e+03 23.48097
#  4    target_1    1e+04 18.91412
#  5    target_1    1e+05 16.68971
#  6    target_2    1e+01 32.34237
#  
#  str(template_standard_curve)
#  'data.frame':	15 obs. of  3 variables:
#   $ target_name: chr  "target_1" "target_1" "target_1" "target_1" ...
#   $ n_copies   : num  1e+01 1e+02 1e+03 1e+04 1e+05 1e+01 1e+02 1e+03 1e+04 1e+05 ...
#   $ ct_value   : num  31.3 27.7 23.5 18.9 16.7 ...

## ----echo=FALSE---------------------------------------------------------------
x <- data.frame(variable=as.character(),
                class=as.character(),
                description=as.character())

x[1, 'variable'] <- "target_name"
x[1, 'class'] <- "Character"
x[1, 'description'] <- "The unique name of each gene target in qPCR assays"

x[2, 'variable'] <- "n_copies"
x[2, 'class'] <- "Numeric"
x[2, 'description'] <- "The known number of gene copies for the observation in the standardized qPCR assay"

x[3, 'variable'] <- "ct_value"
x[3, 'class'] <- "Numeric"
x[3, 'description'] <- "The Cycle Threshold (Ct) value returned by qPCR assays"

knitr::kable(
     x,
     col.names = c("Variable", 
                   "Class", 
                   "Description")
)

