## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
collapse = TRUE,
comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  sel <- template_standard_curve$target_name == 'target_1'
#  tmp_n_copies <- template_standard_curve$n_copies[sel]
#  tmp_ct_value <- template_standard_curve$ct_value[sel]
#  
#  est_amplification_efficiency(n_copies = tmp_n_copies,
#                               ct_value = tmp_ct_value)
#  
#  $mean
#  [1] 0.956834
#  
#  $ci_lo
#  [1] 1.409495
#  
#  $ci_hi
#  [1] 0.5041726

## ----eval=FALSE---------------------------------------------------------------
#  apply_amplification_efficiency(template_standard_curve)
#  
#    target_name     mean    ci_lo     ci_hi
#  1    target_0 1.098055 1.461838 0.7342719
#  2    target_1 0.956834 1.409495 0.5041726
#  3    target_2 1.280836 1.886246 0.6754255
#  4    target_3 1.099861 1.562983 0.6367384

