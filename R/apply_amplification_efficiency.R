#' Apply PCR amplification efficiency estimation to a data.frame
#'
#' This function applies the `est_amplification_efficiency()` function to a data.frame object which follows the
#' standardized format shown in the `template_standard_curve` data set.
#'
#' @param standard_curves A data.frame giving the target name, serial diluted concentration of target nucleic acid,
#' and Ct value from a standard curve assay. Must follow the `template_standard_curve` standardized format.
#'
#' @return A data.frame containing the mean, and low and high of the 95% confidence interval of the percentile amplification efficiency for each target name.
#'
#' @examples
#' \dontrun{
#'
#' apply_amplification_efficiency(template_standard_curve)
#'
#' }

apply_amplification_efficiency <- function(standard_curves) {

     if (!is.data.frame(standard_curves)) stop("standard_curves must be data.frame")
     if (!('target_name') %in% colnames(standard_curves)) stop("Expecting 'target_name' to be in standard_curves")
     if (!('n_copies') %in% colnames(standard_curves)) stop("Expecting 'n_copies' to be in standard_curves")
     if (!('ct_value') %in% colnames(standard_curves)) stop("Expecting 'ct_value' to be in standard_curves")

     if (!is.numeric(standard_curves$n_copies) | !is.numeric(standard_curves$ct_value)) stop('n_copies and ct_value args must be numeric')
     if (any(is.na(standard_curves$ct_value))) stop('ct_value must not have missing values')


     data_split <- split(standard_curves, factor(standard_curves$target_name))

     out <- lapply(data_split, function(x) {

          unlist(est_amplification_efficiency(n_copies = x$n_copies,
                                              ct_value = x$ct_value))

     })

     out <- do.call(rbind, out)
     out <- data.frame(target_name=row.names(out), out)
     row.names(out) <- NULL

     return(out)

}
