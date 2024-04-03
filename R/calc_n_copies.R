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

     # Checks
     if (!length(ct_values) == length(target_names)) stop("lengths of 'ct_values' and 'target_names' must match")

     pb <- .init_pb(length(ct_values))
     out <- rep(NA, length(ct_values))

     for (i in 1:length(ct_values)) {

          pb$tick()

          # Get ct value and target name
          tmp_ct_value <- ct_values[i]
          tmp_target_name <- target_names[i]

          # Find the concise name or unique name in standard curves
          if (tmp_target_name %in% standard_curves$target_name_concise) {

               sel <- standard_curves$target_name_concise == tmp_target_name

          } else if (tmp_target_name %in% standard_curves$target_name_unique) {

               sel <- standard_curves$target_name_unique == tmp_target_name

          }

          # Make note when target not found in standard curves
          cond <- tmp_target_name %in% standard_curves$target_name_concise |
               tmp_target_name %in% standard_curves$target_name_unique

          if (!cond) {

               warning(glue::glue("Index {i}: {tmp_target_name} not found in standard_curves"))

          } else {

               sc <- standard_curves[sel,]

               sel_ct_value_cols <- grep("ct_value", colnames(sc))
               ct_value_mean <- rep(NA, nrow(sc))

               for (j in 1:nrow(sc)) ct_value_mean[j] <- esdata::logmean(sc[j, sel_ct_value_cols])

               mod <- lm(log(quantity) ~ ct_value_mean, data=data.frame(quantity=sc$quantity, ct_value_mean=ct_value_mean))
               pt_est <- predict(mod, newdata=data.frame(ct_value_mean=tmp_ct_value), type='response')

               if (is.numeric(pt_est)) {

                    out[i] <- exp(pt_est)

               } else {

                    warning(glue::glue("Index {i}: cannot estimate n copies"))

               }

          }

     }

     pb$terminate()
     return(out)

}
