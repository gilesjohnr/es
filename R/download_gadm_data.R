#' Download administrative boundaries from GADM
#'
#' This function takes a single ISO country code, or vector of multiple ISO country codes, and downloads the corresponding
#' high resolution administrative boundary shapefiles from [https://gadm.org/](https://gadm.org/) via
#' the [`geodata::gadm`](https://rdrr.io/github/rspatial/geodata/man/gadm.html) function. The most detailed administrative
#' units are returned (level 4 for most countries).
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)). Can accept a vector of multiple ISO codes.
#' @param output_path A character string giving the file path of an output directory to save downloaded data.
#'
#' @returns NULL
#'
#' @examples
#' \dontrun{
#'
#' download_gadm_data(iso3 = c('FRA', 'ITA'), output_path = getwd())
#'
#' }

download_gadm_data <- function(iso3,
                               output_path
) {

     message("Getting administrative shapefiles for...")

     for (i in 1:length(iso3)) {

          message(iso3[i])

          message("trying level 5...")
          admins <- geodata::gadm(country=iso3[i], level=5, resolution=1, version='latest', path=output_path)

          if (is.null(admins)) {
               message("trying level 4...")
               admins <- geodata::gadm(country=iso3[i], level=4, resolution=1, version='latest', path=output_path)
          }

          if (is.null(admins)) {
               message("trying level 3...")
               admins <- geodata::gadm(country=iso3[i], level=3, resolution=1, version='latest', path=output_path)
          }

          if (is.null(admins)) {
               message("trying level 2...")
               admins <- geodata::gadm(country=iso3[i], level=2, resolution=1, version='latest', path=output_path)
          }

          if (is.null(admins)) {
               message("trying level 1...")
               admins <- geodata::gadm(country=iso3[i], level=1, resolution=1, version='latest', path=output_path)
          }

     }

     message('Done.')
     message(glue::glue("Data saved here: {output_path}/gadm"))
}
