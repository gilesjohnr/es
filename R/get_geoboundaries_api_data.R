#' Request metadata from GeoBoundaries API
#'
#' This function retrieves GeoBoundaries data from the API based on the specified release, ISO3 country code, and administrative level.
#' If data is not found at the specified administrative level, it attempts to retrieve data from a lower administrative level until data
#' is found or the lowest level is reached.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)).
#' @param admin_level An integer specifying the administrative level. It should be between 0 and 5.
#' @param release A character string specifying the release type. It should be one of 'gbOpen', 'gbHumanitarian', or 'gbAuthoritative'. Default is 'gbOpen'.
#'
#' @return A list containing the GeoBoundaries API data and file paths to admin boundaries in .geojson format.
#'
#' @examples
#'
#' \dontrun{
#' tmp <- get_geoboundaries_api_data('gbOpen', 'ITA', 2)
#' print(tmp)
#' }
#'

get_geoboundaries_api_data <- function(iso3,
                                       admin_level,
                                       release='gbOpen'
) {

     release_map <- c('gbOpen', 'gbHumanitarian', 'gbAuthoritative')
     if (!(release %in% release_map)) stop(paste("Error: release should be one of", paste(release_map, collapse = ', ')))
     if (admin_level < 0 | admin_level > 5) stop("Error: admin_level should be an integer between 0 and 5")

     admin_level_map <- c("ADM0", "ADM1", "ADM2", "ADM3", "ADM4", "ADM5")
     base_url <- "https://www.geoboundaries.org/api/current"

     while (admin_level >= 0) {

          admin_level_str <- admin_level_map[admin_level + 1]
          api_url <- paste0(base_url, "/", release, "/", iso3, "/", admin_level_str, "/")
          response <- httr::GET(api_url)

          if (response$status_code == 200) {

               data <- suppressMessages(httr::content(response, "text"))
               data_parsed <- jsonlite::fromJSON(data)
               return(data_parsed)

          } else if (response$status_code == 404) {

               admin_level <- admin_level - 1 # Try lower admin level

          } else {

               stop("Error: ", response$status_code)

          }
     }

     stop("Error: No valid data found at any admin level.")

}
