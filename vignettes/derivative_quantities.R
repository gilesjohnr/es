## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
collapse = TRUE,
comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  df <- es::template_es_data
#  head(df)
#  
#  date location_id  lat   lon target_name ct_value
#  1 2020-03-07           1 23.8 90.37    target_0       NA
#  2 2020-03-07           1 23.8 90.37    target_0       NA
#  3 2020-03-07           1 23.8 90.37    target_0       NA
#  4 2020-03-07           1 23.8 90.37    target_0 29.95670
#  5 2020-03-07           1 23.8 90.37    target_1 31.60111
#  6 2020-03-07           1 23.8 90.37    target_1 32.20208
#  
#  sc <- es::template_standard_curve
#  head(sc)
#  
#  target_name n_copies ct_value
#  1    target_0    1e+01 31.54740
#  2    target_0    1e+02 26.95023
#  3    target_0    1e+03 22.39630
#  4    target_0    1e+04 21.47894
#  5    target_0    1e+05 16.04474
#  6    target_1    1e+01 31.85645
#  
#  result <- es::calc_n_copies(ct_values = df$ct_value,
#                              target_names = df$target_name,
#                              standard_curves = sc)
#  
#  df$n_copies <- result
#  head(df)
#  
#  date location_id  lat   lon target_name ct_value n_copies
#  1 2020-03-07           1 23.8 90.37    target_0       NA       NA
#  2 2020-03-07           1 23.8 90.37    target_0       NA       NA
#  3 2020-03-07           1 23.8 90.37    target_0       NA       NA
#  4 2020-03-07           1 23.8 90.37    target_0 29.95670 21.59581
#  5 2020-03-07           1 23.8 90.37    target_1 31.60111 32.99040
#  6 2020-03-07           1 23.8 90.37    target_1 32.20208 21.93164

## ----eval=FALSE---------------------------------------------------------------
#  

## ----eval=FALSE---------------------------------------------------------------
#  

