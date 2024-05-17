#' Get precipitation data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves precipitation data (in millimeters) for those locations and times. Data come from
#' the Open-Meteo Historical Weather API ([https://open-meteo.com/en/docs/historical-weather-api](https://open-meteo.com/en/docs/historical-weather-api))
#' via the [`openmeteo`](https://cran.r-project.org/web/packages/openmeteo/index.html) R package.
#' Additionally, the optional `intervals` argument specifies a set of intervals over which the function
#' will calculate the cumulative sum of precipitation in millimeters (mm) for the previous X number of
#' days for each location.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param dates A character or date vector of dates giving the date when each sample was
#' collected (format is YYYY-MM-DD)
#' @param intervals An integer vector giving a set of time intervals over which to sum the
#' precipitation data. Default is NULL where the interval is 0 (returns the precipitation value at time t). If `intervals`=3
#' then the cumulative precipitation over the preceding 3 days is returned.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' d <- get_precip_data(lon = c(-56.0281, -54.9857),
#'                      lat = c(-2.9094, -2.8756),
#'                      dates = c("2017-12-01", "2017-12-31"),
#'                      intervals = c(1,3,7))
#'
#' head(d)
#'
#' ggplot2::ggplot(d, aes(x = date)) +
#'      geom_line(aes(y = precip_daily_sum_7, col='Cumulative sum 7 days')) +
#'      geom_line(aes(y = precip_daily_sum_3, col='Cumulative sum 3 days')) +
#'      geom_line(aes(y = precip_daily_sum_1, col='Cumulative sum 1 day')) +
#'      geom_line(aes(y = precip_daily_sum)) +
#'      facet_grid(rows=vars(id)) +
#'      labs(x="", y = "Precipitation (mm)") +
#'      theme_bw() +
#'      theme(legend.position = 'bottom',
#'            legend.title = element_blank())
#'
#' }

get_precip_data <- function(lon,
                            lat,
                            dates,
                            intervals=NULL
){

     # Checks
     check <- length(lat) == length(lon) & length(lat) == length(dates)
     if (!check) stop('lat, lon, and dates must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     dates <- as.Date(dates, format='%Y-%m-%d')
     if (all(is.na(dates))) stop('Cannot identify date format')

     if (is.null(intervals)) intervals <- 0

     # Get distinct coordinate sets
     unique_latlon <- data.frame(lat, lon)
     unique_latlon <- dplyr::distinct(unique_latlon)

     date_range <- c(min(dates)-max(intervals), max(dates))

     n_locations <- nrow(unique_latlon)
     n_dates <- (date_range[2] - date_range[1]) + 1

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message(glue::glue("Date range = {paste(c(min(dates), max(dates)), collapse=' -- ')}"))
     message("Downloading precipitation data from the Historical Weather API...")

     data_precip <- data.frame()

     for (i in 1:nrow(unique_latlon)) {

          tmp <- openmeteo::weather_history(
               location = c(unique_latlon$lat[i], unique_latlon$lon[i]),
               start = date_range[1],
               end = date_range[2],
               daily = "precipitation_sum"
          )

          data_precip <- rbind(
               data_precip,
               data.frame(id=i,
                          lat = lat[i],
                          lon = lon[i],
                          tmp)
          )

     }


     check_1 <- length(intervals) > 1
     check_2 <- FALSE
     if (length(intervals) == 1) if(intervals != 0) check_2 <- TRUE

     if (check_1 | check_2) {

          message(glue::glue("Calculating cumulative sums from the following intervals: {paste(intervals, collapse = ', ')}"))

          return_j <- function(x) {
               colnames(x) <- paste('precip_daily_sum', intervals, sep='_')
               return(x)
          }

          return_k <- function(x) as.data.frame(x)

          tmp <-
               foreach(i=unique(data_precip$id), .combine='rbind') %:%
               foreach(j=intervals, .combine='cbind', .final=return_j) %:%
               foreach(k=1:n_dates, .combine='c', .final=return_k) %do% {

                    x <- data_precip[data_precip$id == i,]

                    if (k > j) {

                         precip_sum <- sum(x[(k-j):k, 'daily_precipitation_sum'], na.rm=TRUE)

                    } else {

                         precip_sum <- NA

                    }

                    precip_sum
               }


          data_precip <- cbind(data_precip, as.data.frame(tmp))

     }

     # Clean up
     sel_cols <- which(!(colnames(data_precip) %in% c('id', 'lon', 'lat', 'date')))
     sel_rows <- which(data_precip$date < min(dates))
     data_precip[sel_rows, sel_cols] <- NA
     data_precip <- data_precip[complete.cases(data_precip),]
     colnames(data_precip)[colnames(data_precip) == 'daily_precipitation_sum'] <- 'precip_daily_sum'

     return(as.data.frame(data_precip))

}
