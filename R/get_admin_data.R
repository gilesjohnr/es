#' Get administrative data for a set of points
#'
#' This function takes a set of longitude and latitude coordinates and retrieves the administrative
#' units that each point lies within. The high resolution shapefiles used to determine the administrative boundaries
#' are acquired from [https://gadm.org/](https://gadm.org/) via the [`geodata::gadm`](https://rdrr.io/github/rspatial/geodata/man/gadm.html) function.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param path_admin_data The file path to the admin data. Note that the function expects .rds format output from the \code{download_admin_data} function.
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
#'                path_admin_data = file.path(getwd(), 'gadm/gadm41_BGD_4_pk.rds'))
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
     admin_polygons <- terra::unwrap(readRDS(path_admin_data))
     admin_polygons <- sf::st_as_sf(admin_polygons)

     message("Extracting admin info at point locations...")
     pts <- sf::st_as_sf(xy, coords = c("x", "y"), crs=sp::CRS(wgs_proj_string))
     pts <- sf::st_join(pts, admin_polygons, join = sf::st_within)

     out <- data.frame(id = xy$id,
                       lon = xy$x,
                       lat = xy$y)

     out$admin_5 <- out$admin_4_name <- out$admin_3_name <- out$admin_2_name <- out$admin_1_name <- out$admin_0_name <- out$admin_0_iso <- NA
     if ('GID_0' %in% colnames(pts)) out$admin_0_iso <- pts$GID_0
     if ('COUNTRY' %in% colnames(pts)) out$admin_0_name <- pts$COUNTRY
     if ('NAME_1' %in% colnames(pts)) out$admin_1_name <- pts$NAME_1
     if ('NAME_2' %in% colnames(pts)) out$admin_2_name <- pts$NAME_2
     if ('NAME_3' %in% colnames(pts)) out$admin_3_name <- pts$NAME_3
     if ('NAME_4' %in% colnames(pts)) out$admin_4_name <- pts$NAME_4
     if ('NAME_5' %in% colnames(pts)) out$admin_5_name <- pts$NAME_5

     message("Done.")
     return(out)

}
