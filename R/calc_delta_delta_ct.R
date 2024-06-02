#' Calculate delta delta Ct
#'
#' This function calculates relative gene expression using the delta delta Ct method described in
#' [Livak and Schmittgen (2001)](https://www.sciencedirect.com/science/article/abs/pii/S1046202301912629?via%3Dihub).
#' Adjusted delta delta Ct values following [Yuan et al. (2008)](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-7-85)
#' can be calculated by providing estimated values for the percentile amplification efficiency in `pae_*` arguments.
#'
#' @param ct_target_treatment A numeric scalar providing the Ct value of the target gene for an observation in the treatment group
#' @param ct_reference_treatment A numeric scalar providing the Ct value of the reference gene for an observation in the treatment group
#' @param ct_target_control A numeric scalar providing the Ct value of the target gene for the reference observation in the control group
#' @param ct_reference_control A numeric scalar providing the Ct value of the reference gene for the reference observation in the control group
#' @param pae_target_treatment A numeric scalar providing the percentile amplification efficiency for the target gene and the treatment group. Defaults to 1.
#' @param pae_target_control A numeric scalar providing the percentile amplification efficiency for the target gene and the control group. Defaults to 1.
#' @param pae_reference_treatment A numeric scalar providing the percentile amplification efficiency for the reference gene and the treatment group. Defaults to 1.
#' @param pae_reference_control A numeric scalar providing the percentile amplification efficiency for the reference gene and the control group. Defaults to 1.
#'
#' @returns Scalar
#'
#' @examples
#' \dontrun{
#'
#' # Traditional method
#' calc_delta_delta_ct(ct_target_treatment = 32.5,
#'                     ct_reference_treatment = 25,
#'                     ct_target_control = 34,
#'                     ct_reference_control = 30)
#'
#' # Adjusted calculation incorporating amplification efficiency
#' calc_delta_delta_ct(ct_target_treatment = 32.5,
#'                     ct_reference_treatment = 25,
#'                     ct_target_control = 34,
#'                     ct_reference_control = 30,
#'                     pae_target_treatment=0.97,
#'                     pae_target_control=0.98,
#'                     pae_reference_treatment=0.98,
#'                     pae_reference_control=0.99)
#'
#' }

calc_delta_delta_ct <- function(ct_target_treatment,
                                ct_target_control,
                                ct_reference_treatment,
                                ct_reference_control,
                                pae_target_treatment=1,
                                pae_target_control=1,
                                pae_reference_treatment=1,
                                pae_reference_control=1
){

     ct_target_treatment <- as.numeric(ct_target_treatment)
     ct_reference_treatment <- as.numeric(ct_reference_treatment)
     ct_target_control <- as.numeric(ct_target_control)
     ct_reference_control <- as.numeric(ct_reference_control)
     pae_target_treatment <- as.numeric(pae_target_treatment)
     pae_target_control <- as.numeric(pae_target_control)
     pae_reference_treatment <- as.numeric(pae_reference_treatment)
     pae_reference_control <- as.numeric(pae_reference_control)

     if (any(is.na(c(ct_target_treatment, ct_reference_treatment, ct_target_control, ct_reference_control)))) {

          return(NA)

     } else {

          cond <- length(ct_target_treatment) == 1 &
               length(ct_reference_treatment) == 1 &
               length(ct_target_control) == 1 &
               length(ct_reference_control) == 1 &
               length(pae_target_treatment) == 1 &
               length(pae_target_control) == 1 &
               length(pae_reference_treatment) == 1 &
               length(pae_reference_control) == 1
          if (!cond) stop('all args must be scalar')

          delta_ct_target_sample <- ct_target_treatment*pae_target_treatment - ct_reference_treatment*pae_reference_treatment
          delta_ct_reference_sample <- ct_target_control*pae_target_control - ct_reference_control*pae_reference_control
          delta_delta_ct <- delta_ct_target_sample - delta_ct_reference_sample
          out <- 2^-delta_delta_ct
          return(out)

     }

}
