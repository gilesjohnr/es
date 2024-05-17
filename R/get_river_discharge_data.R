#' Get river discharge data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves daily river discharge data from the nearest river (\eqn{m^3/s}) for those locations and times. Data come from
#' the Open-Meteo Global Flood API ([https://open-meteo.com/en/docs/flood-api](https://open-meteo.com/en/docs/flood-api))
#' via the [`openmeteo`](https://cran.r-project.org/web/packages/openmeteo/index.html) R package.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param dates A character or date vector of dates giving the date when each sample was
#' collected (format is YYYY-MM-DD)
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' d <- get_river_discharge_data(lon = c(-54.9857, -52.9857),
#'                               lat = c(-10.9094, -25.8756),
#'                               dates = c("2020-06-01", "2020-10-31"))
#'
#' head(d)
#'
#' ggplot2::ggplot(d, aes(x = date)) +
#'      geom_line(aes(y = daily_river_discharge)) +
#'      facet_grid(rows=vars(id)) +
#'      labs(x="", y = "Local River Discharge (m^3/s)") +
#'      theme_bw() +
#'      theme(legend.position = 'bottom',
#'            legend.title = element_blank())
#'
#' }

get_river_discharge_data <- function(lon,
                                     lat,
                                     dates
){

     # Checks
     check <- length(lat) == length(lon) & length(lat) == length(dates)
     if (!check) stop('lat, lon, and dates must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     dates <- as.Date(dates, format='%Y-%m-%d')
     if (all(is.na(dates))) stop('Cannot identify date format')

     # Get distinct coordinate sets
     unique_latlon <- data.frame(lat, lon)
     unique_latlon <- dplyr::distinct(unique_latlon)
     date_range <- c(min(dates), max(dates))

     n_locations <- nrow(unique_latlon)
     n_dates <- (date_range[2] - date_range[1]) + 1

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message(glue::glue("Date range = {paste(c(min(dates), max(dates)), collapse=' -- ')}"))
     message("Downloading daily river discharge data from the Global Flood API...")

     data_river <- data.frame()

     for (i in 1:nrow(unique_latlon)) {

          tmp <- openmeteo::river_discharge(
               location = c(unique_latlon$lat[i], unique_latlon$lon[i]),
               start = date_range[1],
               end = date_range[2],
               daily = "river_discharge"
          )

          data_river <- rbind(
               data_river,
               data.frame(id = i,
                          lat = lat[i],
                          lon = lon[i],
                          tmp)
          )

     }

     return(data_river)

}
