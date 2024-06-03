#' Estimate PCR amplification efficiency
#'
#' This function takes a set of serial diluted concentrations of target nucleic acid from a standard curve assay and their associated Ct values and
#' estimates the percentile amplification efficiency using a linear model as described in [Yuan et al. (2008)](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-7-85).
#' Note that the model uses a log base 2 transform which assumes that serial dilutions double with each increase in concentration. The function also
#' requires a minimum of 5 observations.
#'
#' @param n_copies A numeric vector giving the serial diluted concentration of target nucleic acid
#' @param ct_value A numeric vector giving the measured Ct value for each serial dilution in the standard curve design
#'
#' @return List containing the mean, and low and high of the 95% confidence interval for the percentile amplification efficiency.
#'
#' @examples
#' \dontrun{
#'
#' sel <- template_standard_curve$target_name == 'target_1'
#' tmp_n_copies <- template_standard_curve$n_copies[sel]
#' tmp_ct_value <- template_standard_curve$ct_value[sel]
#'
#' est_amplification_efficiency(n_copies = tmp_n_copies,
#'                              ct_value = tmp_ct_value)
#'
#' }


est_amplification_efficiency <- function(n_copies, ct_value) {

     check <- length(n_copies) == length(ct_value)
     if (!check) stop('n_copies and ct_value args must be equal in length')
     if (!is.numeric(n_copies) | !is.numeric(ct_value)) stop('n_copies and ct_value args must be numeric')
     if (any(is.na(ct_value))) stop('ct_value must not have missing values')
     if (length(ct_value) < 5) warning('Amplification estimation works best when there are at least 5 observations in the standard curve')

     mod <- lm(ct_value ~ log(n_copies, base=2), data=data.frame(n_copies, ct_value))
     ci <- confint(mod, level=0.95)

     mu <- coef(mod)[2]
     names(mu) <- NULL

     out <- list(mean = -1*mu,
                 ci_lo = -1*ci[2,1],
                 ci_hi = -1*ci[2,2])

     return(out)

}
