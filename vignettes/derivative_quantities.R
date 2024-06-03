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
#  # Standard method
#  calc_delta_delta_ct(ct_target_treatment = 32.5,
#                      ct_reference_treatment = 25,
#                      ct_target_control = 34,
#                      ct_reference_control = 30)
#  
#  [1] 0.08838835

## ----eval=FALSE---------------------------------------------------------------
#  # Adjusted method incorporating amplification efficiency
#  calc_delta_delta_ct(ct_target_treatment = 32.5,
#                      ct_reference_treatment = 25,
#                      ct_target_control = 34,
#                      ct_reference_control = 30,
#                      pae_target_treatment=0.97,
#                      pae_target_control=0.98,
#                      pae_reference_treatment=0.98,
#                      pae_reference_control=0.99)
#  
#  [1] 0.09440454

## ----eval=FALSE---------------------------------------------------------------
#  # Standard temporally-controlled method
#  df_example <- template_es_data
#  colnames(df_example)[colnames(df_example) == 'date'] <- 'sample_date'
#  
#  ddct_standard <- apply_delta_delta_ct(df = df_example,
#                                        target_names = c('target_1', 'target_2', 'target_3'),
#                                        reference_names = rep('target_0', 3))
#  
#  head(ddct_standard)
#  
#    location_id sample_date target_name delta_delta_ct
#  1           1  2020-03-07    target_1       1.000000
#  2           1  2020-03-11    target_1      17.762262
#  3           1  2020-03-23    target_1      29.642154
#  4           1  2020-03-24    target_1      32.191141
#  5           1  2020-03-30    target_1       5.694505
#  6           1  2020-04-03    target_1       8.620370

## ----eval=FALSE---------------------------------------------------------------
#  # Adjusted temporally-controlled method
#  df_example <- template_es_data
#  colnames(df_example)[colnames(df_example) == 'date'] <- 'sample_date'
#  
#  pae <- apply_amplification_efficiency(template_standard_curve)
#  
#  ddct_adjusted <- apply_delta_delta_ct(df = df_example,
#                                        target_names = c('target_1', 'target_2', 'target_3'),
#                                        reference_names = rep('target_0', 3),
#                                        pae_names = pae$target_name,
#                                        pae_values = pae$mean)
#  
#  head(ddct_adjusted)
#  
#    location_id sample_date target_name delta_delta_ct
#  1           1  2020-03-07    target_1       1.000000
#  2           1  2020-03-11    target_1      17.465229
#  3           1  2020-03-23    target_1      26.118476
#  4           1  2020-03-24    target_1      29.213109
#  5           1  2020-03-30    target_1       5.485189
#  6           1  2020-04-03    target_1       7.632729

