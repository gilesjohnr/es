#' Get administrative data for a set of points
#'
#' This function takes a set of longitude and latitude coordinates and retrieves the administrative
#' units that each point lies within. The high resolution shapefiles used to determine the administrative boundaries
#' are acquired from [https://gadm.org/](https://gadm.org/) via the [`geodata::gadm`](https://rdrr.io/github/rspatial/geodata/man/gadm.html) function.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param save_data Logical indicating whether to save the shapefiles used to identify administrative units. Default is `FALSE` where the temp directory is deleted.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' get_admin_data(lon = template_es_data$lon,
#'                lat = template_es_data$lat,
#'                save_data = FALSE)
#'
#' }

get_admin_data <- function(lon,
                           lat,
                           save_data=FALSE
){

     check <- length(lat) == length(lon) & length(lat)
     if (!check) stop('lat and lon must be equal in length')

     if (!is.logical(save_data)) stop('save_data must be logical')


     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
     xy <- data.frame(id=1:nrow(xy), xy)
     n_locations <- nrow(xy)

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message("NOTE: Sets of points with very large extents may be prohibitively slow.")

     # Create temp dir
     tmp_root <- getwd()
     tmp_time <- as.character(round(Sys.time(), 0))
     tmp_time <- paste(unlist(strsplit(tmp_time, '[:/ -]')), collapse='_')
     tmp_path <- file.path(tmp_root, paste0('es_output_', tmp_time))
     if (!dir.exists(tmp_path)) dir.create(tmp_path)

     # Set PROJ4 strings
     wgs_proj_string <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
     albers_proj_string <- "+proj=aea +lat_1=29.5 +lat_2=42.5"


     # Get admins

     get_country <-  function(lon, lat){

          countries <- rworldmap::getMap(resolution = 'high') # requires rworldxtra

          pts = sp::SpatialPoints(cbind(x=lon, y=lat),
                                  sp::CRS(sp::proj4string(countries)))

          tmp <- sp::over(pts, countries)

          data.frame(
               lon = lon,
               lat = lat,
               admin_0_iso = as.character(tmp$ISO3),
               admin_0_name = as.character(tmp$ADMIN)
          )

     }

     tmp <- get_country(lon = xy$x, lat = xy$y)
     pts_admin_0_iso <- unique(tmp$admin_0_iso)
     pts_admin_0_name <- unique(tmp$admin_0_name)

     #if (length(unique(tmp$admin_0_iso)) > 1) stop('unique countries > 1')
     message("Getting administrative shapefiles for...")

     for (i in 1:length(pts_admin_0_iso)) {

          message(pts_admin_0_name[i])

          if (pts_admin_0_iso[i] %in% c('FRA', 'RWA')) {
               message("trying level 5...")
               admins <- geodata::gadm(country=pts_admin_0_iso[i], level=5, resolution=1, version='latest', path=tmp_path)
          } else {
               admins <- NULL
          }

          if (is.null(admins)) {
               message("trying level 4...")
               admins <- geodata::gadm(country=pts_admin_0_iso[i], level=4, resolution=1, version='latest', path=tmp_path)
          }

          if (is.null(admins)) {
               message("trying level 3...")
               admins <- geodata::gadm(country=pts_admin_0_iso[i], level=3, resolution=1, version='latest', path=tmp_path)
          }

          if (is.null(admins)) {
               message("trying level 2...")
               admins <- geodata::gadm(country=pts_admin_0_iso[i], level=2, resolution=1, version='latest', path=tmp_path)
          }

          if (is.null(admins)) {
               message("trying level 1...")
               admins <- geodata::gadm(country=pts_admin_0_iso[i], level=1, resolution=1, version='latest', path=tmp_path)
          }

     }

     tmp <- lapply(list.files(file.path(tmp_path, 'gadm'), full.names = TRUE),
                   FUN=function(x) terra::unwrap(readRDS(x)))

     admin_polygons <- do.call(tidyterra::bind_spat_rows, tmp)
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


     if (save_data) {

          message(glue::glue("Intermediate shapefiles are in temp drive {tmp_path}"))

     } else {

          message("Removing intermediate shapefiles...")
          system(command=glue::glue("rm -rf {tmp_path}"))

     }

     message('Done.')
     return(out)

}
