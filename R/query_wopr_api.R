#' Query the WorldPop REST API
#'
#' This function queries the WorldPop REST API for all population raster metadata associated with a particular ISO country code.
#' If no ISO country code is provided, the function returns metadata for all available ISO codes on the WorldPop API.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)).
#'
#' @returns list
#'
#' @examples
#' \dontrun{
#'
#' query_wopr_api('USA')
#' query_wopr_api(NULL)
#'
#' }

query_wopr_api <- function(iso3) {

     base_url <- "https://www.worldpop.org/rest/data/pop/wpgp"

     if (!is.null(iso3)) {
          url <- paste(base_url, "?iso3=", iso3, sep="")
     } else {
          url <- base_url
     }

     response <- httr::GET(url)
     status <- httr::status_code(response)

     if (status == 200) {
          data <- httr::content(response, "parsed")
          return(data)
     } else {
          return(paste("Failed to retrieve data: HTTP status code", status))
     }

}
