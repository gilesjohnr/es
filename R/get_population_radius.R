#' Get population counts within a radius of sampling sites
#'
#' This function takes vectors of sampling site longitude and latitude and calculates the total population
#' residing within a given radius around each sampling site. Intermediate spatial variables are written to
#' the directory specified in \code{path_output}.
#'
#' @param lat A numeric vector giving the latitudes of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitudes of the sampling sites in Decimal Degrees.
#' @param radius Numeric giving the radius (in meters) around each point to calculate total population
#' @param path_pop_raster The file path to a raster object providing population counts in each grid cell.
#' See \code{download_worldpop_data} for methods to download population raster data.
#' @param path_output The file path of an output directory where spatial data will be saved.
#'
#' @return A \code{data.frame} containing the total population counts for the given radius around each sampling site.
#'
#' @examples
#' \dontrun{
#'
#' dir.create(file.path(getwd(), 'tmp'))
#'
#' download_worldpop_data(iso3 = 'BGD',
#'                        year = 2020,
#'                        constrained = FALSE,
#'                        UN_adjusted = FALSE,
#'                        path_output = file.path(getwd(), 'tmp'))
#'
#' get_population_radius(lon = template_es_data$lon,
#'                       lat = template_es_data$lat,
#'                       radius = 100,
#'                       path_pop_raster = file.path(getwd(), 'tmp/bgd_ppp_2020.tif'),
#'                       path_output = file.path(getwd(), 'tmp'))
#'
#' }


get_population_radius <- function(lon,
                                  lat,
                                  radius,
                                  path_pop_raster,
                                  path_output
) {

     check <- length(lat) == length(lon) & length(lat)
     if (!check) stop('lat and lon must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')
     if (!dir.exists(path_output)) stop('path_output does not exist')


     # Set PROJ4 strings
     wgs_proj_string <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
     albers_proj_string <- "+proj=aea +lat_1=29.5 +lat_2=42.5"


     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
     pts <- sf::st_as_sf(xy, coords = c("x", "y"), crs=sp::CRS(wgs_proj_string))
     pts_buffer <- sf::st_buffer(pts, dist = radius)


     # Get population raster, crop to points and project to planar coords
     rast_pop <- raster::raster(path_pop_raster)
     rast_pop_crop <- raster::crop(x=rast_pop, y=sf::st_buffer(pts, dist = radius*3))
     rast_pop_crop_aea <- raster::projectRaster(rast_pop_crop, crs=CRS(albers_proj_string))


     # Extract raster values
     pop_radius <-
          foreach::foreach(i=1:nrow(xy), .combine='c') %do% {

               tmp <- sp::SpatialPoints(xy[i,], proj4string=sp::CRS(wgs_proj_string))
               tmp <- sp::spTransform(tmp, sp::CRS(albers_proj_string))
               tmp <- raster::buffer(tmp, radius)
               exactextractr::exact_extract(rast_pop_crop_aea, tmp, 'sum')

          }

     pts_buffer$radius <- radius
     pts_buffer$population_radius <- round(pop_radius, 0)


     # Save intermediate data
     sf::st_write(pts,
                  dsn = file.path(path_output, glue::glue("points.shp")),
                  delete_layer = TRUE,
                  quiet = TRUE)

     sf::st_write(pts_buffer,
                  dsn = file.path(path_output, glue::glue("points_buffer_{radius}.shp")),
                  delete_layer = TRUE,
                  quiet = TRUE)

     tmp <- unlist(strsplit(path_pop_raster, "[/.]"))
     rast_pop_filename <- tmp[length(tmp)-1]

     raster::writeRaster(rast_pop_crop, filename=file.path(path_output, glue::glue('{rast_pop_filename}_crop.tif')), overwrite=TRUE)


     out <- data.frame(lon = xy$x,
                       lat = xy$y,
                       tmp = pts_buffer$population_radius)

     colnames(out)[colnames(out) == 'tmp'] <- glue::glue('population_radius_{radius}')

     return(out)

}
