#' Calculate sample sizes
#'
#' This function takes a compiled data.frame following the format shown in the `template_es_data` object
#' and calculates basic sample sizes and detection rates for all gene targets.
#'
#' @param df A data.frame produced by the \code{compile_tac_data} function containing 'target_name' and 'ct_value' columns.
#' @param cutoff Numeric scalar giving the cutoff Ct value over which a gene target is deemed absent from a sample. Default is 40.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' calc_sample_sizes(template_es_data)
#'
#' }

calc_sample_sizes <- function(df, cutoff=40) {

     cols_required <- c('target_name', 'ct_value')
     cond <- all(cols_required %in% colnames(df))
     if (!cond) stop(glue::glue("Object 'df' must contain columns: {paste(cols_required, collapse=', ')}"))

     pathogen_names <- unique(df$target_name)
     pathogen_names <- sort(unique(pathogen_names))

     sample_sizes <- data.frame(
          pathogen = pathogen_names,
          n_NA = NA,              # Total number of instances where ct_value is not observed (NA)
          n_total = NA,           # Total number samples with a Ct value
          n_lt_cutoff = NA,       # Total number of samples with Ct value less than cutoff
          n_ge_cutoff = NA,       # Total number of samples with Ct value grater than cutoff
          observation_rate = NA,  # Proportion of instances with an observation
          detection_rate = NA,    # The overall detection rate of each pathogen across all samples
          ct_median = NA,         # Average Ct value for a pathogen across all samples
          ct_hpd_025 = NA,        # Lower 95% interval of the highest posterior density
          ct_hpd_975 = NA         # Upper 95% interval of the highest posterior density
     )

     for (i in seq_along(pathogen_names)) {

          sample_sizes$n_NA[sample_sizes$pathogen == pathogen_names[i]] <- sum(is.na(df[df$target_name == pathogen_names[i], 'ct_value']), na.rm=TRUE)
          sample_sizes$n_total[sample_sizes$pathogen == pathogen_names[i]] <- sum(!is.na(df[df$target_name == pathogen_names[i], 'ct_value']), na.rm=TRUE)
          sample_sizes$observation_rate[sample_sizes$pathogen == pathogen_names[i]] <- sample_sizes$n_total[sample_sizes$pathogen == pathogen_names[i]] /
               (sample_sizes$n_total[sample_sizes$pathogen == pathogen_names[i]] + sample_sizes$n_NA[sample_sizes$pathogen == pathogen_names[i]])

          sample_sizes$n_lt_cutoff[sample_sizes$pathogen == pathogen_names[i]] <- sum(df[df$target_name == pathogen_names[i], 'ct_value'] < cutoff, na.rm=TRUE)
          sample_sizes$n_ge_cutoff[sample_sizes$pathogen == pathogen_names[i]] <- sum(df[df$target_name == pathogen_names[i], 'ct_value'] >= cutoff, na.rm=TRUE)
          sample_sizes$detection_rate[sample_sizes$pathogen == pathogen_names[i]] <- sample_sizes$n_lt_cutoff[sample_sizes$pathogen == pathogen_names[i]] / sample_sizes$n_total[sample_sizes$pathogen == pathogen_names[i]]

          sample_sizes$ct_median[sample_sizes$pathogen == pathogen_names[i]] <- median(df[df$target_name == pathogen_names[i], 'ct_value'], na.rm=TRUE)
          hpd <- HDInterval::hdi(df[df$target_name == pathogen_names[i], 'ct_value'], credMass=0.95)
          sample_sizes$ct_hpd_025[sample_sizes$pathogen == pathogen_names[i]] <- hpd['lower']
          sample_sizes$ct_hpd_975[sample_sizes$pathogen == pathogen_names[i]] <- hpd['upper']

     }

     sample_sizes$observation_rate <- round(sample_sizes$observation_rate, 2)
     sample_sizes$detection_rate <- round(sample_sizes$detection_rate, 2)
     sample_sizes$ct_median <- round(sample_sizes$ct_median, 2)
     sample_sizes$ct_hpd_025 <- round(sample_sizes$ct_hpd_025, 2)
     sample_sizes$ct_hpd_975 <- round(sample_sizes$ct_hpd_975, 2)

     return(sample_sizes)

}
