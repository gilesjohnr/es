#' Get topographical data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves a 100m elevation raster around those locations and then calculates
#' the slope and aspect of each point. The DEM is acquired via `elevatr::get_elev_raster` and
#' topographical variables are calculated using `raster::terrain`.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param show_plots Logical indicating whether to plot the raster and point data.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' get_topo_data(lon = template_es_data$lon,
#'               lat = template_es_data$lat,
#'               show_plots = TRUE)
#'
#' }

get_topo_data <- function(lon,
                          lat,
                          show_plots=FALSE
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

     message("Getting DEM raster")

     wgs_proj_string <- sp::CRS('+proj=longlat +datum=WGS84')

     rast_dem <- elevatr::get_elev_raster(locations = xy,
                                          prj = sf::st_crs(wgs_proj_string),
                                          src = 'aws',
                                          z = 10,
                                          expand = 0.005,
                                          clip = 'bbox',
                                          verbose = FALSE)

     pts_dem <- xy
     pts_dem$dem <- raster::extract(rast_dem, xy)

     tmp <- as.data.frame(rast_dem, xy=TRUE)
     colnames(tmp)[3] <- 'DEM'


     message('Calculating slope raster')
     rast_slope <- raster::terrain(x = rast_dem,
                                   opt = 'slope',
                                   unit = 'degrees',
                                   neighbors = 8)

     message('Extracting slope at points')
     pts_slope <- xy
     pts_slope$slope <- raster::extract(rast_slope, xy)


     message('Calculating aspect raster')
     rast_aspect <- raster::terrain(x = rast_dem,
                                    opt = 'aspect',
                                    unit = 'degrees',
                                    neighbors = 8)

     message('Extracting aspect at points')
     pts_aspect <- xy
     pts_aspect$aspect <- raster::extract(rast_aspect, xy)


     out <- data.frame(
          lon = xy$x,
          lat = xy$y,
          elevation = round(pts_dem$dem, 2),
          slope = round(pts_slope$slope, 2),
          aspect = round(pts_aspect$aspect, 2)
     )


     if (show_plots) {

          plot_base <-
               ggplot2::ggplot() +
               ggrepel::geom_label_repel(box.padding   = 0.5,
                                         point.padding = 0.5,
                                         segment.color = 'black',
                                         segment.size = 0.25) +
               scale_fill_viridis_c(na.value='white') +
               coord_equal() +
               theme_void() +
               theme(plot.title = element_text(hjust = 0.5),
                     legend.position='bottom',
                     legend.title = element_blank(),
                     legend.key.height=unit(7,'pt'),
                     legend.key.width=unit(30,'pt'))


          tmp <- as.data.frame(rast_dem, xy=TRUE)
          colnames(tmp)[3] <- 'DEM'

          plot_dem <-
               plot_base +
               geom_raster(data=tmp, aes(x=x, y=y, fill=DEM)) +
               geom_point(data=out, aes(x=lon, y=lat), pch=1, size=3) +
               ggrepel::geom_label_repel(data=out, aes(x=lon, y=lat, label=elevation)) +
               ggplot2::ggtitle('DEM')


          tmp <- as.data.frame(rast_slope, xy=TRUE)
          colnames(tmp)[3] <- 'slope'

          plot_slope <-
               plot_base +
               geom_raster(data=tmp, aes(x=x, y=y, fill=slope)) +
               geom_point(data=out, aes(x=lon, y=lat), pch=1, size=3) +
               ggrepel::geom_label_repel(data=out, aes(x=lon, y=lat, label=slope)) +
               ggplot2::ggtitle('Slope')


          tmp <- as.data.frame(rast_aspect, xy=TRUE)
          colnames(tmp)[3] <- 'aspect'

          plot_aspect <-
               plot_base +
               geom_raster(data=tmp, aes(x=x, y=y, fill=aspect)) +
               geom_point(data=out, aes(x=lon, y=lat), pch=1, size=3) +
               ggrepel::geom_label_repel(data=out, aes(x=lon, y=lat, label=aspect)) +
               ggplot2::ggtitle('Aspect')

          gridExtra::grid.arrange(plot_dem, plot_slope, plot_aspect, ncol=3)

     }

     return(out)

}
