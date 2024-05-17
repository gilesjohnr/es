#' Get population counts for a local area
#'
#'
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param path_output A character string giving the file path of an output directory to save downloaded data.
#'
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' download_wopr_data(iso3 = 'FRA', output_path = getwd())
#'
#' }

get_population_catchment <- function(lon,
                                     lat,
                                     path_population_raster,
                                     path_dem_raster,
                                     path_streams_shapefile=NULL,
                                     path_output
) {

     check <- length(lat) == length(lon) & length(lat)
     if (!check) stop('lat and lon must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')
     if (!dir.exists(path_output)) stop('path_output does not exist')

     # Get distinct coordinate sets
     xy <- data.frame(x=lon, y=lat)
     xy <- dplyr::distinct(xy)
     n_locations <- nrow(xy)

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message("NOTE: Sets of points with very large extents may be prohibitively slow.")

     rast_pop <- raster::raster(path_population_raster)
     rast_dem <- raster::raster(path_dem_raster)


     whitebox::wbt_fill_depressions(
          dem = path_dem_raster,
          output = "dem_filled.tif",
          wd = path_output
     )

     Sys.sleep(0.25)

     whitebox::wbt_d8_pointer(
          dem = "dem_filled.tif",
          output = "dem_pointer.tif",
          wd = path_output
     )

     Sys.sleep(0.25)

     if (is.null(path_streams_shapefile)) {

          whitebox::wbt_d8_flow_accumulation(
               input = "dem_pointer.tif",
               pntr = TRUE,
               output = "flow_acc.tif",
               wd = path_output
          )

          Sys.sleep(0.25)

          whitebox::wbt_extract_streams(
               flow_accum =  "flow_acc.tif",
               threshold = 100,
               output = "streams.tif",
               zero_background = TRUE,
               wd = path_output
          )

          Sys.sleep(0.25)

          whitebox::wbt_raster_streams_to_vector(
               streams = 'streams.tif',
               d8_pntr = 'dem_pointer.tif',
               output = 'streams.shp',
               wd = path_output,
               verbose_mode = FALSE
          )

          Sys.sleep(0.25)

          shp_streams <- sf::st_read(file.path(path_output, 'streams.shp'), quiet=TRUE)
          sf::st_crs(shp_streams) <- sf::st_crs(sp::CRS(wgs_proj_string))



     } else {

          shp_streams <- sf::st_read(path_streams_shapefile, quiet=TRUE)

     }


     # Define outlets (sampling sites) and where they link to drainage network

     outlets <- sf::st_as_sf(xy, coords = c("x", "y"), crs=CRS(wgs_proj_string))

     sf::st_write(outlets,
                  dsn = file.path(path_output, "outlets.shp"),
                  delete_layer = TRUE,
                  quiet = TRUE)


     Sys.sleep(0.25)

     whitebox::wbt_jenson_snap_pour_points(
          pour_pts = "outlets.shp",
          streams = "streams.tif",
          output = "outlets_snapped.shp",
          snap_dist = 0.004,
          wd = path_output
     )

     Sys.sleep(0.25)

     outlets_snapped <- sf::st_read(file.path(path_output, "outlets_snapped.shp"), quiet = TRUE)

     Sys.sleep(0.25)

     # Delineate catchments
     catchments <- sf::st_sfc(crs = sf::st_crs(sp::CRS(wgs_proj_string)))

     for (i in row.names(outlets_snapped)){

          sf::st_write(
               outlets_snapped[i,],
               file.path(path_output, glue::glue("outlet_snapped_{i}.shp")),
               delete_layer = TRUE,
               quiet = TRUE
          )

          whitebox::wbt_watershed(
               d8_pntr = "dem_pointer.tif",
               pour_pts = glue::glue("outlet_snapped_{i}.shp"),
               output = glue::glue("catchment_{i}.tif"),
               wd = path_output
          )

          # Vectorize catchments
          drainage <- stars::read_stars(file.path(path_output, glue::glue("catchment_{i}.tif")))

          contours <- stars::st_contour(drainage, breaks = 1)
          contours <- sf::st_geometry(contours)
          contours <- sf::st_cast(contours, "POLYGON")
          contours <- contours[which.max(sf::st_area(contours))]

          catchments <- rbind(catchments, sf::st_sf(data.frame(id=i, geom = contours)))

     }

     catchments$catchment_area_km2 <- round(as.vector(sf::st_area(catchments))/1000, 1)
     catchments$catchment_population <- raster::extract(rast_pop, catchments, fun=sum, na.rm=TRUE)

     sf::st_write(catchments,
                  dsn = file.path(path_output, "catchments.shp"),
                  delete_layer = TRUE,
                  quiet = TRUE)

     out <- data.frame(
          lon = xy$x,
          lat = xy$y,
          catchment_area_km2 = round(catchments$catchment_area_km2, 2),
          catchment_population = round(catchments$catchment_population, 0)
     )

     return(out)

}
