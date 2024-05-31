#' Get administrative data for a set of points
#'
#' This function takes a set of longitude and latitude coordinates and retrieves the administrative
#' units that each point lies within.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param path_admin_data The file path to the admin data. Note that the function expects .shp
#' format output from the \code{download_admin_data} function or from another user supplied source.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' download_admin_data(iso3 = "BGD", path_output = getwd())
#'
#' get_admin_data(lon = template_es_data$lon,
#'                lat = template_es_data$lat,
#'                path_admin_data = file.path(getwd(), 'BGD_admin_levels.shp'))
#'
#' }

get_admin_data <- function(lon,
                           lat,
                           path_admin_data
){

     check <- length(lat) == length(lon) & length(lat)
     if (!check) stop('lat and lon must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
     xy <- data.frame(id=1:nrow(xy), xy)

     # Set PROJ4 strings
     wgs_proj_string <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

     # Get admins
     message("Loading admin data...")
     admin_polygons <- sf::st_read(path_admin_data, quiet=TRUE)

     message("Extracting admin info at point locations...")
     pts <- sf::st_as_sf(xy, coords = c("x", "y"), crs=sp::CRS(wgs_proj_string))
     pts <- sf::st_join(pts, admin_polygons, join = sf::st_within)

     out <- data.frame(id = xy$id,
                       lon = xy$x,
                       lat = xy$y)

     out <- cbind(out, pts[!(colnames(pts) %in% c('id', 'geometry'))])

     message("Done.")
     return(out)

}
