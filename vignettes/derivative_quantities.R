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

## ----eval=FALSE---------------------------------------------------------------
#  library(mgcv)
#  library(ggplot2)
#  library(cowplot)
#  
#  # Estimate amplification efficiency
#  pae <- apply_amplification_efficiency(template_es_data)
#  
#  # Calculate standard delta delta Ct
#  ddct_standard <- apply_delta_delta_ct(df = df_example,
#                                        target_names = c('target_1', 'target_2', 'target_3'),
#                                        reference_names = rep('target_0', 3))
#  
#  # Calculate adjusted delta delta Ct
#  ddct_adjusted <- apply_delta_delta_ct(df = df_example,
#                                        target_names = c('target_1', 'target_2', 'target_3'),
#                                        reference_names = rep('target_0', 3),
#                                        pae_names = pae$target_name,
#                                        pae_values = pae$mean)
#  
#  # Combine results
#  colnames(ddct_standard)[colnames(ddct_standard) == 'delta_delta_ct'] <- 'delta_delta_ct_standard'
#  colnames(ddct_adjusted)[colnames(ddct_adjusted) == 'delta_delta_ct'] <- 'delta_delta_ct_adjusted'
#  ddct <- merge(ddct_standard, ddct_adjusted, by=c('location_id', 'sample_date', 'target_name'), all=T)
#  ddct <- merge(template_es_data, ddct, by=c('location_id', 'sample_date', 'target_name'), all.x=T)
#  
#  # Fit time series models to delta delta Ct to visualize time trends
#  fit_gam <- function(x) {
#  
#       require(mgcv)
#  
#       # Fit GAMs with a Gaussian process smoothing term and a Gamma link function
#       mod_standard <- gam(delta_delta_ct_standard ~ s(as.numeric(sample_date), bs = "gp"), family = Gamma(link = "inverse"), data = x, method = "REML", na.action = na.exclude)
#       mod_adjusted <- gam(delta_delta_ct_adjusted ~ s(as.numeric(sample_date), bs = "gp"), family = Gamma(link = "inverse"), data = x, method = "REML", na.action = na.exclude)
#  
#       # Add model predictions to data
#       x$pred_delta_delta_ct_standard <- predict(mod_standard, newdata = x, type='response', se.fit=F)
#       x$pred_delta_delta_ct_adjusted <- predict(mod_adjusted, newdata = x, type='response', se.fit=F)
#  
#       return(x)
#  
#  }
#  
#  # Apply GAMs by location
#  tmp <- ddct[ddct$target_name %in% c('target_2'),]
#  tmp <- lapply(split(tmp, factor(tmp$location_id)), fit_gam)
#  tmp <- do.call(rbind, tmp)
#  
#  # Visualize result
#  p1 <- ggplot(ddct[ddct$target_name %in% c('target_0', 'target_2'),],
#         aes(x = sample_date)) +
#       geom_point(aes(y = ct_value), alpha = 0.6, shape = 16, size = 2) +
#       facet_grid(rows = vars(target_name), cols = vars(location_id)) +
#       theme_bw(base_size = 15) +
#       theme(panel.grid.major = element_line(size = 0.25, linetype = 'solid', color = 'grey80'),
#             panel.grid.minor = element_blank(),
#             panel.border = element_blank(),
#             axis.line = element_line(size = 0.5, linetype = 'solid', color = 'black'),
#             legend.position = "bottom",
#             legend.title = element_blank(),
#             strip.background = element_rect(fill = "white", color = "white", size = 0.5),
#             axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) +
#       labs(x = element_blank(),
#            y = "Ct value",
#            subtitle = "Raw Ct values") +
#       scale_x_date(date_breaks = "3 month", date_labels = "%b %Y")
#  
#  
#  p2 <- ggplot(tmp, aes(x = sample_date)) +
#       geom_point(aes(y = delta_delta_ct_standard, color = 'Standard'), alpha = 0.6, shape = 16, size = 2) +
#       geom_point(aes(y = delta_delta_ct_adjusted, color = 'Adjusted'), alpha = 0.6, shape = 17, size = 2) +
#       geom_line(aes(y = pred_delta_delta_ct_standard, color = 'Standard'), size = 1) +
#       geom_line(aes(y = pred_delta_delta_ct_adjusted, color = 'Adjusted'), size = 1) +
#       facet_grid(rows = vars(target_name), cols = vars(location_id)) +
#       theme_bw(base_size = 15) +
#       theme(panel.grid.major = element_line(size = 0.25, linetype = 'solid', color = 'grey80'),
#            panel.grid.minor = element_blank(),
#            panel.border = element_blank(),
#            axis.line = element_line(size = 0.5, linetype = 'solid', color = 'black'),
#            legend.position = "bottom",
#            legend.title = element_blank(),
#            strip.background = element_rect(fill = "white", color = "white", size = 0.5),
#            axis.text.x = element_text(angle = 45, hjust = 1, size = 10)) +
#       labs(x = element_blank(),
#            y = expression(2^{-Delta * Delta * Ct}),
#            subtitle = "Comparison of standard and adjusted values") +
#       scale_color_manual(values = c("Standard" = "dodgerblue", "Adjusted" = "tomato2")) +
#       scale_x_date(date_breaks = "3 month", date_labels = "%b %Y")
#  
#  plot_grid(p1, p2, nrow=2, align='v', rel_heights = c(1.1,1))
#  

