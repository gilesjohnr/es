#' Download administrative boundaries from geoBoundaries API
#'
#' This function takes a single ISO country code and downloads the corresponding
#' high resolution administrative boundary [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON) files from the [www.geoBoundaries.org](https://www.geoboundaries.org/) API
#' hosted at GitHub [HERE](https://github.com/wmgeolab/geoBoundaries/tree/9469f09592ced973a3448cf66b6100b741b64c0d). If the
#' desired administrative level is not available the next most detailed administrative level is returned.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' @param release A character string specifying the release type on the geoBoundaries API. It should be one of 'gbOpen',
#' 'gbHumanitarian', or 'gbAuthoritative'.  Release types are described at [https://www.geoboundaries.org/api.html#api](https://www.geoboundaries.org/api.html#api).
#' @param path_output A character string giving the file path of an output directory to save downloaded data.
#' @param simplified Logical indicating whether to download simplified administrative boundaries instead of high resolution. Default is FALSE.
#' @param keep_geojson Logical indicating whether to keep the raw geojson files downloaded from geoBoundaries API. Default is FALSE.
#'
#' @returns Character string giving path to downloaded data.
#'
#' @examples
#'
#' \dontrun{
#' download_admin_data(iso3 = 'TWN',
#'                     release = 'gbOpen',
#'                     path_output = getwd())
#' }
#'

download_admin_data <- function(iso3,
                                release,
                                path_output,
                                simplified=FALSE,
                                keep_geojson=FALSE
) {

     if (!is.character(iso3)) stop('iso3 code(s) must be character')
     if (!dir.exists(path_output)) stop('path_output does not exist')

     release_map <- c('gbOpen', 'gbHumanitarian', 'gbAuthoritative')
     if (!(release %in% release_map)) stop(paste("Error: release should be one of", paste(release_map, collapse = ', ')))

     urls <- vector()
     for (i in 5:0) {

          api_data <- es::get_geoboundaries_api_data(iso3=iso3,
                                                     admin_level=i,
                                                     release=release)

          url <- ifelse(simplified,
                        api_data$simplifiedGeometryGeoJSON,
                        api_data$gjDownloadURL)

          urls <- c(urls, url)

     }

     urls <- unique(urls)
     file_names <- file.path(path_output, basename(urls))

     for (i in 1:length(urls)) {

          download.file(url = urls[i],
                        destfile = file_names[i],
                        method='auto',
                        quiet = FALSE,
                        mode = "wb",
                        cacheOK = TRUE,
                        extra = getOption("download.file.extra"))

     }


     for (i in 1:length(file_names)) {

          if (i == 1) {

               out <- sf::read_sf(file_names[i], drivers='geojson', quiet=TRUE)
               shapeType <- out$shapeType[1]
               out <- out[,c('shapeName', 'geometry')]
               colnames(out)[colnames(out) == 'shapeName'] <- shapeType

          } else {

               tmp <- sf::read_sf(file_names[i], drivers='geojson', quiet=TRUE)
               shapeType <- tmp$shapeType[1]
               tmp <- tmp[,c('shapeName', 'geometry')]
               colnames(tmp)[colnames(tmp) == 'shapeName'] <- shapeType

               out <- sf::st_join(out, tmp, join = sf::st_nearest_feature, left = T)

          }

     }

     out$iso3 <- iso3
     colnames(out)[colnames(out) == 'ADM0'] <- 'admin_0'
     colnames(out)[colnames(out) == 'ADM1'] <- 'admin_1'
     colnames(out)[colnames(out) == 'ADM2'] <- 'admin_2'
     colnames(out)[colnames(out) == 'ADM3'] <- 'admin_3'
     colnames(out)[colnames(out) == 'ADM4'] <- 'admin_4'
     colnames(out)[colnames(out) == 'ADM5'] <- 'admin_5'
     out <- out[,order(colnames(out))]

     path_output_shapefile <- file.path(path_output, paste0(iso3, "_admin_levels.shp"))

     sf::st_write(out,
                  dsn = path_output_shapefile,
                  driver = 'ESRI Shapefile',
                  delete_layer = TRUE,
                  append = FALSE,
                  quiet = TRUE)

     if (!keep_geojson) do.call(file.remove, as.list(file_names))

     message('Done.')
     message(glue::glue("Data saved here: {path_output_shapefile}"))
     return(path_output_shapefile)

}
