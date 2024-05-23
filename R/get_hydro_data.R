#' Get hydrological data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves a suite of topographical and hydrological variables for each unique
#' location. The variables include: elevation, slope, aspect, Topographical Wetness Index (TWI),
#' flow accumulation, total flow accumulation within 500m, and distance to the nearest stream.
#' If a DEM is not provided, then a DEM is acquired via [`elevatr::get_elev_raster`](https://www.rdocumentation.org/packages/elevatr/versions/0.99.0/topics/get_elev_raster)
#' and the suite of variables are calculated using functions from the ['WhiteboxTools'](https://cran.r-project.org/web/packages/whitebox/index.html)
#' R frontend.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param path_dem_raster The file path to a Digital Elevation Model (DEM) raster. See \code{download_elevation_data}
#' for methods to download DEM raster data. If NULL, a DEM is downloaded automatically using this function.
#' @param path_output The file path of an output directory where spatial data will be saved.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' dir.create(file.path(getwd(), 'tmp'))
#'
#' get_hydro_data(lon = template_es_data$lon,
#'                lat = template_es_data$lat,
#'                path_output = file.path(getwd(), 'tmp'))
#'
#' }

get_hydro_data <- function(lon,
                           lat,
                           path_dem_raster=NULL,
                           path_output
){

     requireNamespace('whitebox')

     # Checks
     check <- length(lat) == length(lon)
     if (!check) stop('lat and lon args must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)


     # Set PROJ4 strings
     wgs_proj_string <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
     albers_proj_string <- "+proj=aea +lat_1=29.5 +lat_2=42.5"


     if (is.null(path_dem_raster)) {

          message("Getting DEM raster")

          rast_dem <- elevatr::get_elev_raster(locations = xy,
                                               prj = sf::st_crs(sp::CRS(wgs_proj_string)),
                                               src = 'aws',
                                               z = 10,
                                               expand = 0.05,
                                               clip = 'bbox',
                                               verbose = FALSE)

          raster::writeRaster(rast_dem, filename=file.path(path_output, 'dem.tif'), overwrite=TRUE)
          path_dem_raster <- file.path(path_output, 'dem.tif')

     } else {

          rast_dem <- raster::raster(path_dem_raster)

     }







     message('Calculating hydrological variables...')

     s <- 1
     Sys.sleep(s)

     # DEM modifications

     whitebox::wbt_fill_single_cell_pits(
          dem = path_dem_raster,
          output = file.path(path_output, 'dem_filled.tif'),
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     whitebox::wbt_breach_depressions_least_cost(
          dem = file.path(path_output, 'dem_filled.tif'),
          output = file.path(path_output, 'dem_filled_breached.tif'),
          dist = 10,
          fill = TRUE,
          verbose_mode = FALSE
     )

     Sys.sleep(s)


     # Slope and aspect

     whitebox::wbt_slope(
          dem = file.path(path_output, 'dem_filled_breached.tif'),
          output = file.path(path_output, 'slope.tif'),
          units = "degrees",
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     whitebox::wbt_aspect(
          dem = file.path(path_output, 'dem_filled_breached.tif'),
          output = file.path(path_output, 'aspect.tif'),
          zfactor = 1,
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     # Flow accumulation

     whitebox::wbt_d_inf_flow_accumulation(
          input = file.path(path_output, 'dem_filled_breached.tif'),
          output = file.path(path_output, 'flow_acc.tif'),
          out_type = 'cells',
          clip = TRUE,
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     # TWI

     whitebox::wbt_wetness_index(
          sca = file.path(path_output, 'flow_acc.tif'),
          slope = file.path(path_output, 'slope.tif'),
          output = file.path(path_output, 'twi.tif'),
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     # Stream delineation

     whitebox::wbt_extract_streams(
          flow_accum = file.path(path_output, 'flow_acc.tif'),
          output = file.path(path_output, 'streams.tif'),
          threshold = 1000,
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     whitebox::wbt_d8_pointer(
          dem = file.path(path_output, 'dem_filled_breached.tif'),
          output = file.path(path_output, 'dem_pointer.tif'),
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     whitebox::wbt_raster_streams_to_vector(
          streams = file.path(path_output, 'streams.tif'),
          d8_pntr = file.path(path_output, 'dem_pointer.tif'),
          output = file.path(path_output, 'streams.shp'),
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     whitebox::wbt_hillshade(
          dem = file.path(path_output, 'dem.tif'),
          output = file.path(path_output, 'hillshade.tif'),
          azimuth = 315,
          altitude = 30,
          verbose_mode = FALSE
     )

     Sys.sleep(s)

     message('Reloading rasters')

     rast_slp <- raster::raster(file.path(path_output, 'slope.tif'))
     rast_asp <- raster::raster(file.path(path_output, 'aspect.tif'))
     rast_twi <- raster::raster(file.path(path_output, 'twi.tif'))
     rast_acc <- raster::raster(file.path(path_output, 'flow_acc.tif'))
     rast_acc_aea <- raster::projectRaster(rast_acc, crs=CRS(albers_proj_string))
     shp_streams <- sf::st_read(file.path(path_output, 'streams.shp'), quiet=TRUE)


     message('Extracting point data')
     pts_dem <- raster::extract(rast_dem, xy)
     pts_slp <- raster::extract(rast_slp, xy)
     pts_asp <- raster::extract(rast_asp, xy)
     pts_twi <- raster::extract(rast_twi, xy)
     pts_acc <- raster::extract(rast_acc, xy)


     # Total flow accumulation within 500m of sample location
     pts_acc_500m <-
          foreach::foreach(i=1:nrow(xy), .combine='c') %do% {

               tmp <- sp::SpatialPoints(xy[i,], proj4string=sp::CRS(wgs_proj_string))
               tmp <- sp::spTransform(tmp, sp::CRS(albers_proj_string))
               tmp <- raster::buffer(tmp, 500)
               exactextractr::exact_extract(rast_acc_aea, tmp, 'sum')

          }


     # distance to nearest stream in km
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
     return(out)

}
