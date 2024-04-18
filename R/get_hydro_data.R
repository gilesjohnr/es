#' Get hydrological data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves a suite of topographical and hydrological variables for each unique
#' location. The variables include: elevation, slope, aspect, Topographical Wetness Index (TWI),
#' flow accumulation, total flow accumulation within 500m, and distance to the nearest stream.
#' The DEM is acquired via [`elevatr::get_elev_raster`](https://www.rdocumentation.org/packages/elevatr/versions/0.99.0/topics/get_elev_raster)
#' and the suite of variables are calculated using functions from the ['WhiteboxTools'](https://cran.r-project.org/web/packages/whitebox/index.html)
#' R frontend.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param save_data Logical indicating whether to save the intermediate raster layers used to
#' calculate the hydrological variables at each point. Default is `FALSE` where the temp directory is deleted.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' get_hydro_data(lon = template_es_data$lon,
#'                lat = template_es_data$lat,
#'                save_data = FALSE)
#'
#' }

get_hydro_data <- function(lon,
                           lat,
                           save_data=FALSE
){

     # Checks
     check <- length(lat) == length(lon)
     if (!check) stop('lat and lon args must be equal in length')

     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
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


     message("Getting DEM raster")

     rast_dem <- elevatr::get_elev_raster(locations = xy,
                                          prj = sf::st_crs(sp::CRS(wgs_proj_string)),
                                          src = 'aws',
                                          z = 10,
                                          expand = 0.05,
                                          clip = 'bbox',
                                          verbose = FALSE)

     raster::writeRaster(rast_dem, filename=file.path(tmp_path, 'dem.tif'), overwrite=TRUE)


     message('Calculating hydrological variables...')


     # DEM modifications

     whitebox::wbt_fill_single_cell_pits(
          dem = file.path(tmp_path, 'dem.tif'),
          output = file.path(tmp_path, 'dem_filled.tif'),
          verbose_mode = FALSE
     )

     whitebox::wbt_breach_depressions_least_cost(
          dem = file.path(tmp_path, 'dem_filled.tif'),
          output = file.path(tmp_path, 'dem_filled_breached.tif'),
          dist = 10,
          fill = TRUE,
          verbose_mode = FALSE
     )


     # Slope and aspect

     whitebox::wbt_slope(
          dem = file.path(tmp_path, 'dem_filled_breached.tif'),
          output = file.path(tmp_path, 'slope.tif'),
          units = "degrees",
          verbose_mode = FALSE
     )

     whitebox::wbt_aspect(
          dem = file.path(tmp_path, 'dem_filled_breached.tif'),
          output = file.path(tmp_path, 'aspect.tif'),
          zfactor = 1,
          verbose_mode = FALSE
     )


     # Flow accumulation

     whitebox::wbt_d_inf_flow_accumulation(
          input = file.path(tmp_path, 'dem_filled_breached.tif'),
          output = file.path(tmp_path, 'flow_acc.tif'),
          out_type = 'cells',
          clip = TRUE,
          verbose_mode = FALSE
     )


     # TWI

     whitebox::wbt_wetness_index(
          sca = file.path(tmp_path, 'flow_acc.tif'),
          slope = file.path(tmp_path, 'slope.tif'),
          output = file.path(tmp_path, 'twi.tif'),
          verbose_mode = FALSE
     )


     # Stream delineation

     whitebox::wbt_extract_streams(
          flow_accum = file.path(tmp_path, 'flow_acc.tif'),
          output = file.path(tmp_path, 'streams.tif'),
          threshold = 1000,
          verbose_mode = FALSE
     )

     whitebox::wbt_d8_pointer(
          dem = file.path(tmp_path, 'dem_filled_breached.tif'),
          output = file.path(tmp_path, 'dem_pointer.tif'),
          verbose_mode = FALSE
     )

     whitebox::wbt_raster_streams_to_vector(
          streams = file.path(tmp_path, 'streams.tif'),
          d8_pntr = file.path(tmp_path, 'dem_pointer.tif'),
          output = file.path(tmp_path, 'streams.shp'),
          verbose_mode = FALSE
     )

     whitebox::wbt_hillshade(
          dem = file.path(tmp_path, 'dem.tif'),
          output = file.path(tmp_path, 'hillshade.tif'),
          azimuth = 315,
          altitude = 30,
          verbose_mode = FALSE
     )

     message('Reloading rasters')

     rast_slp <- raster::raster(file.path(tmp_path, 'slope.tif'))
     rast_asp <- raster::raster(file.path(tmp_path, 'aspect.tif'))
     rast_twi <- raster::raster(file.path(tmp_path, 'twi.tif'))
     rast_acc <- raster::raster(file.path(tmp_path, 'flow_acc.tif'))
     rast_acc_aea <- raster::projectRaster(rast_acc, crs=CRS(albers_proj_string))
     shp_streams <- sf::st_read(file.path(tmp_path, 'streams.shp'), quiet=TRUE)


     message('Extracting point data')
     pts_dem <- raster::extract(rast_dem, xy)
     pts_slp <- raster::extract(rast_slp, xy)
     pts_asp <- raster::extract(rast_asp, xy)
     pts_twi <- raster::extract(rast_twi, xy)
     pts_acc <- raster::extract(rast_acc, xy)


     # Total flow accumulation within 100m of sample location
     pts_acc_500m <-
          foreach::foreach(i=1:nrow(xy), .combine='c') %do% {

               tmp <- sp::SpatialPoints(xy[i,], proj4string=CRS(wgs_proj_string))
               tmp <- sp::spTransform(tmp, CRS(albers_proj_string))
               tmp <- raster::buffer(tmp, 500)
               exactextractr::exact_extract(rast_acc_aea, tmp, 'sum')

          }


     # distance to nearest stream in meters
     dist_to_stream <- sf::st_distance(x = sf::st_as_sf(xy, coords = c("x","y")), y = shp_streams)
     dist_to_stream <- apply(dist_to_stream, 1, min)
     dist_to_stream <- dist_to_stream/0.008 # Approx km


     out <- data.frame(
          lon = xy$x,
          lat = xy$y,
          elevation = round(pts_dem, 2),
          slope = round(pts_slp, 2),
          aspect = round(pts_asp, 2),
          twi = round(pts_twi, 2),
          flow_acc = round(pts_acc, 2),
          flow_acc_500m = round(pts_acc_500m, 2),
          km_to_nearest_stream = round(dist_to_stream, 2)
     )


     message('Done.')

     if (save_data) {

          message(glue::glue("Intermediate raster data is in temp drive {tmp_path}"))

     } else {

          system(command=glue::glue("rm -rf {tmp_path}"))

     }


     return(out)

}
