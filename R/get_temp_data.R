#' Get temperature data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves temperature data (measured in accumulated degree-days) for those locations and times. Data come from
#' the Open-Meteo Historical Weather API ([https://open-meteo.com/en/docs/historical-weather-api](https://open-meteo.com/en/docs/historical-weather-api))
#' via the [`openmeteo`](https://cran.r-project.org/web/packages/openmeteo/index.html) R package. The optional `intervals` argument
#' specifies a set of intervals over which the function will calculate the accumulated temperature in the form of Accumulated Thermal Units (ATUs) for each interval.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param dates A character or date vector of dates giving the date when each sample was
#' collected (format is YYYY-MM-DD)
#' @param intervals An integer vector giving a set of time intervals over to calculate accumulated degree-days. Default
#' is NULL where the interval is 0 (returns the daily temperature in degrees Celsius at time t). If `intervals`=3 then the accumulated
#' degree-days for the preceding 3 days is returned.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' d <- get_temp_data(lon = c(30.0281, -52.9857),
#' lat = c(15.9094, -25.8756),
#' dates = c("2020-08-01", "2020-12-31"),
#' intervals = c(1,5,10))
#'
#' head(d)
#'
#' ggplot2::ggplot(d, aes(x = date)) +
#'      geom_line(aes(y = temp_daily_atu_10, col='Accumulated temperature 10 days')) +
#'      geom_line(aes(y = temp_daily_atu_5, col='Accumulated temperature 5 days')) +
#'      geom_line(aes(y = temp_daily_atu_1, col='Accumulated temperature 1 day')) +
#'      geom_line(aes(y = temp_daily_atu)) +
#'      facet_grid(rows=vars(id)) +
#'      labs(x="", y = "Accumulated Thermal Units (ATUs)") +
#'      theme_bw() +
#'      theme(legend.position = 'bottom',
#'            legend.title = element_blank())
#'
#' }

get_temp_data <- function(lon,
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
     message("Downloading temperature data from the Historical Weather API...")

     data_temp <- data.frame()

     for (i in 1:nrow(unique_latlon)) {

          tmp <- openmeteo::weather_history(
               location = c(unique_latlon$lat[i], unique_latlon$lon[i]),
               start = date_range[1],
               end = date_range[2],
               hourly = "temperature_2m"
          )

          tmp <- aggregate(tmp[,'hourly_temperature_2m'],
                           list(date=format(tmp$datetime, '%Y-%m-%d')),
                           mean)

          colnames(tmp)[colnames(tmp) == 'hourly_temperature_2m'] <- 'temp_daily_atu'

          data_temp <- rbind(
               data_temp,
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
               colnames(x) <- paste('temp_daily_atu', intervals, sep='_')
               return(x)
          }

          return_k <- function(x) as.data.frame(x)

          tmp <-
               foreach(i=unique(data_temp$id), .combine='rbind') %:%
               foreach(j=intervals, .combine='cbind', .final=return_j) %:%
               foreach(k=1:n_dates, .combine='c', .final=return_k) %do% {

                    x <- data_temp[data_temp$id == i,]

                    if (k > j) {

                         temp_atu <- sum(x[(k-j):k, 'temp_daily_atu'], na.rm=TRUE)

                    } else {

                         temp_atu <- NA

                    }

                    temp_atu
               }


          data_temp <- cbind(data_temp, as.data.frame(tmp))

     }

     # Clean up
     sel_cols <- which(!(colnames(data_temp) %in% c('id', 'lon', 'lat', 'date')))
     sel_rows <- which(data_temp$date < min(dates))
     data_temp[sel_rows, sel_cols] <- NA
     data_temp <- data_temp[complete.cases(data_temp),]

     data_temp$date <- as.Date(data_temp$date)

     return(as.data.frame(data_temp))

}
