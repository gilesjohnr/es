#' Template standard curve data
#'
#' The `template_standard_curve` object provides a template of the data format required
#' by the `es` package for standard curve values. These data are only required when calculating the
#' number of gene copies using the `calc_n_copies` function.
#'
#' @format ## `template_standard_curve`
#' A data frame with 3 columns:
#' \describe{
#'   \item{target_name}{The unique name of the gene target for which the Ct values correspond.}
#'   \item{n_copies}{The number of gene copies represented in the particular dilution.}
#'   \item{ct_value}{The Cycle Threshold (Ct) of the qPCR assay.}
#' }
"template_standard_curve"
