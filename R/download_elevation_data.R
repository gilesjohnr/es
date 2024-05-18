#' Download DEM from AWS Terrain Tiles
#'
#' This function takes the coordinates of sampling sites (longitude and latitude) and downloads a Digital Elevation Model (DEM)
#' for the surrounding area. The DEM has an approximate spatial resolution of 100 meters. These data are derived from the
#' Shuttle Radar Topography Mission (SRTM) DEM, which is accessible through the Amazon Web Services (AWS) API and the
#' [`elevatr`](https://cran.r-project.org/web/packages/elevatr/index.html) R package.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.Can accept a vector of multiple ISO codes.
#' @param path_output A character string giving the file path of an output directory to save downloaded data.
#'
#' @returns NULL
#'
#' @examples
#' \dontrun{
#'
#' download_elevation_data(lon = template_es_data$lon,
#'                         lat = template_es_data$lat,
#'                         path_output = getwd())
#'
#' }

download_elevation_data <- function(lon,
                                    lat,
                                    path_output
){

     # Checks
     check <- length(lat) == length(lon)
     if (!check) stop('lat and lon args must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')
     if (!dir.exists(path_output)) stop('path_output does not exist')

     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
     n_locations <- nrow(xy)

     message("Getting DEM raster from AWS Terrain Tiles...")

     rast_dem <- elevatr::get_elev_raster(locations = xy,
                                          prj = sf::st_crs(sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")),
                                          src = 'aws',
                                          z = 10,
                                          expand = 0.05,
                                          clip = 'bbox',
                                          verbose = FALSE)

     full_path <- file.path(path_output, 'dem.tif')
     raster::writeRaster(rast_dem, filename=full_path, overwrite=TRUE)
     message(glue::glue("DEM is here: {full_path}"))
     return(full_path)

}
