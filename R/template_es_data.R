#' Template environmental sampling data
#'
#' The `template_es_data` object provides a template of the data format required by the `es` package.
#'
#' @format ## `template_es_data`
#' A data frame with 6 columns:
#' \describe{
#'   \item{date}{The date each sample was collected. Formate is "YYYY-MM-DD".}
#'   \item{location_id}{A unique identifier for each of the sampling locations.}
#'   \item{lat}{The lattitude of the sampling location in decimal degrees.}
#'   \item{lon}{The longitude of the sampling location in decimal degrees.}
#'   \item{target_name}{The unique name of the gene target for which the Ct values correspond.}
#'   \item{ct_value}{The Cycle Threshold (Ct) of the qPCR assay.}
#' }
"template_es_data"
