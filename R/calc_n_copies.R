#' Calculate number of target copies
#'
#' This function calculates the quantitative value of the qPCR Ct value. Cycle threshold here is converted into
#' the estimated number of gene target copies (e.g. viral load for a viral pathogen) by fitting a log linear model
#' to the standard curve data and then using that model to find a point estimate for the provided Ct values.
#'
#' @param ct_values A numeric vector giving the Ct value for each observation.
#' @param target_names A character vector giving the target names for each element in 'ct_values'.
#' @param standard_curves A data.frame containing results from standard curve dilution experiment.
#' Elements in 'target_names' must map to either 'target_name_unique' or 'target_name_concise'. See package
#' data object `standard_curves_dhaka` for template.
#'
#' @returns Vector
#'
#' @examples
#' \dontrun{
#'
#' compiled_tac <- read.csv('/Users/tac/compiled_tac.csv')
#'
#' test <- calc_n_copies(ct_values = compiled_tac$ct_value,
#'                       target_names = compiled_tac$target_name,
#'                       standard_curves = standard_curves_dhaka)
#'
#' compiled_tac$n_copies <- test
#'
#' }

calc_n_copies <- function(ct_values,
                          target_names,
                          standard_curves
){

     if (!is.data.frame(standard_curves)) stop("standard_curves must be data.frame")
     if (!length(ct_values) == length(target_names)) stop("lengths of 'ct_values' and 'target_names' must match")
     if (!('target_names') %in% colnames(standard_curves)) stop("Expecting 'target_names' to be in standard_curves")
     if (!('n_copies') %in% colnames(standard_curves)) stop("Expecting 'n_copies' to be in standard_curves")
     if (!('ct_value') %in% colnames(standard_curves)) stop("Expecting 'ct_value' to be in standard_curves")

     out <- rep(NA, length(ct_values))

     for (i in 1:length(ct_values)) {

          # Get ct value and target name
          tmp_ct_value <- ct_values[i]
          tmp_target_name <- target_names[i]

          # Find the target name in standard curves
          sel <- standard_curves$target_name == tmp_target_name

          # Make note when target not found in standard curves
          cond <- tmp_target_name %in% standard_curves$target_name

          if (!cond) {

               warning(glue::glue("Index {i}: {tmp_target_name} not found in standard_curves"))

          } else {

               mod <- lm(
                    log(n_copies) ~ ct_value,
                    data = data.frame(n_copies = standard_curves$n_copies[sel],
                                      ct_value = standard_curves$ct_value[sel])
               )

               pt_est <- predict(mod, newdata=data.frame(ct_value=tmp_ct_value), type='response')

               if (is.numeric(pt_est)) {

                    out[i] <- exp(pt_est)

               } else {

                    warning(glue::glue("Index {i}: cannot estimate n copies"))

               }

          }

     }

     return(out)

}
