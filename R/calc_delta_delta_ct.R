#' Calculate delta delta Ct
#'
#' This function calculates relative gene expression using the delta delta Ct method described in \url{https://www.sciencedirect.com/science/article/abs/pii/S1046202301912629?via%3Dihub}{Livak & Schmittgen (2001)}.
#'
#' @param ct_target_t A scalar providing the Ct value of the target gene for an observation at time t
#' @param ct_reference_t A scalar providing the Ct value of the reference gene for an observation at time t
#' @param ct_target_t0 A scalar providing the Ct value of the target gene for the reference observation at time t=0
#' @param ct_reference_t0 A scalar providing the Ct value of the reference gene for the reference observation at time t=0
#' @param amplification_efficiency A scalar between 0 and 1 giving the assumed PCR amplification efficiency for all samples in the equation. Defaults to 1, which assumes 100% efficiency.
#'
#' @returns Scalar
#'
#' @examples
#' \dontrun{
#'
#' calc_delta_delta_ct(ct_target_t = 32.5,
#'                     ct_reference_t = 25,
#'                     ct_target_t0 = 34,
#'                     ct_reference_t0 = 30,
#'                     amplification_efficiency = 0.95)
#'
#' }

calc_delta_delta_ct <- function(ct_target_t,
                                ct_reference_t,
                                ct_target_t0,
                                ct_reference_t0,
                                amplification_efficiency=1
){

     ct_target_t <- as.numeric(ct_target_t)
     ct_reference_t <- as.numeric(ct_reference_t)
     ct_target_t0 <- as.numeric(ct_target_t0)
     ct_reference_t0 <- as.numeric(ct_reference_t0)

     if (any(is.na(c(ct_target_t, ct_reference_t, ct_target_t0, ct_reference_t0)))) {

          return(NA)

     } else {

          cond <- length(ct_target_t) == 1 & length(ct_reference_t) == 1 & length(ct_target_t0) == 1 & length(ct_reference_t0) == 1
          if (!cond) stop('all args must be scalar')

          delta_ct_target_sample <- ct_target_t - ct_reference_t
          delta_ct_reference_sample <- ct_target_t0 - ct_reference_t0
          delta_delta_ct <- delta_ct_target_sample - delta_ct_reference_sample
          out <- (1+amplification_efficiency)^-delta_delta_ct
          return(out)

     }

}
