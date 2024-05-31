#' Download administrative boundaries from geoBoundaries API
#'
#' This function takes a single ISO country code and downloads the corresponding
#' high resolution administrative boundary [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON) files from the [www.geoBoundaries.org](https://www.geoboundaries.org/) API
#' hosted at GitHub [HERE](https://github.com/wmgeolab/geoBoundaries/tree/9469f09592ced973a3448cf66b6100b741b64c0d). If the
#' desired administrative level is not available the next most detailed administrative level is returned.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' @param admin_level An integer specifying the administrative level. It should be between 0 and 5.
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)).
#' @param release A character string specifying the release type on the geoBoundaries API. It should be one of 'gbOpen',
#' 'gbHumanitarian', or 'gbAuthoritative'.  Release types are described at [https://www.geoboundaries.org/api.html#api](https://www.geoboundaries.org/api.html#api).
#' @param path_output A character string giving the file path of an output directory to save downloaded data.
#' @param simplified Logical indicating whether to download simplified administrative boundaries instead of high resolution. Default is FALSE.
#'
#' @returns NULL. Administrative boundaries are downloaded in .geojson format.
#'
#' @examples
#'
#' \dontrun{
#' download_admin_data(iso3 = 'ITA',
#'                     admin_level = 2,
#'                     release = 'gbOpen',
#'                     path_output = getwd())
#' }
#'

download_admin_data <- function(iso3,
                                admin_level,
                                release,
                                path_output,
                                simplified=FALSE
) {

     if (!is.character(iso3)) stop('iso3 code(s) must be character')
     if (!dir.exists(path_output)) stop('path_output does not exist')

     release_map <- c('gbOpen', 'gbHumanitarian', 'gbAuthoritative')
     if (!(release %in% release_map)) stop(paste("Error: release should be one of", paste(release_map, collapse = ', ')))
     if (admin_level < 0 | admin_level > 5) stop("Error: admin_level should be an integer between 0 and 5")

     # Get metadata from geoBoundaries API
     api_data <- es::get_geoboundaries_api_data(iso3=iso3,
                                                admin_level=admin_level,
                                                release=release)

     url <- ifelse(simplified,
                   api_data$simplifiedGeometryGeoJSON,
                   api_data$gjDownloadURL)

     # Download to path_output
     download.file(url = url,
                   destfile = file.path(path_output, basename(url)),
                   method='auto',
                   quiet = FALSE,
                   mode = "wb",
                   cacheOK = TRUE,
                   extra = getOption("download.file.extra"))

     message('Done.')
     message(glue::glue("Data saved here: {path_output}/{basename(url)}"))
     return(file.path(path_output, basename(url)))

}
