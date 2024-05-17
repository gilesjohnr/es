#' Get Evaporative Stress Index (ESI) data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves the Evaporative Stress Index (ESI) for those locations and times.
#' For more information about ESI, see description [HERE](https://climateserv.readthedocs.io/en/latest/user/datasets.html#evaporative-stress-index-esi).
#' Data come from the Climate Hazards Center InfraRed Precipitation with Station data ([CHIRPS](https://www.chc.ucsb.edu/data)) via
#' the [`chirps`](https://docs.ropensci.org/chirps/) R package. Additionally, the optional `intervals` argument
#' specifies a set of intervals over which the function will calculate the average ESI for the previous X number
#' of days for each location.
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param dates A character or date vector of dates giving the date when each sample was
#' collected (format is YYYY-MM-DD)
#' @param intervals An integer vector giving a set of time intervals over which to calculate
#' the average ESI. Default is NULL where the interval is 0 (returns the ESI value at time t). If `intervals`=3
#' then the average ESI over the preceding 3 days is returned.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' d <- get_esi_data(lon = c(-54.9857, -52.9857),
#' lat = c(-5.9094, -25.8756),
#' dates = c("2020-06-01", "2020-10-31"),
#' intervals = c(5,10,20))
#'
#' head(d)
#'
#' ggplot2::ggplot(d, aes(x = date)) +
#'      geom_line(aes(y = esi_daily_avg_20, col='Average ESI 20 days')) +
#'      geom_line(aes(y = esi_daily_avg_10, col='Average ESI 10 days')) +
#'      geom_line(aes(y = esi_daily_avg_5, col='Average ESI 5 days')) +
#'      geom_line(aes(y = esi_daily_avg)) +
#'      facet_grid(rows=vars(id)) +
#'      labs(x="", y = "Evaporative Stress Index (ESI)") +
#'      theme_bw() +
#'      theme(legend.position = 'bottom',
#'            legend.title = element_blank())
#'
#' }

get_esi_data <- function(lon,
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
     unique_lonlat <- data.frame(lon, lat)
     unique_lonlat <- dplyr::distinct(unique_lonlat)

     date_range <- c(min(dates)-(max(intervals)+30), max(dates)+30)

     n_locations <- nrow(unique_lonlat)
     n_dates <- (date_range[2] - date_range[1]) + 1

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message(glue::glue("Date range = {paste(c(min(dates), max(dates)), collapse=' -- ')}"))
     message("Downloading evaporative stress index (ESI) data from SERVIR Global via ClimateSERV API ...")


     data_chirps <- chirps::get_esi(
          object = unique_lonlat,
          dates = as.character(date_range),
          as.data.frame = TRUE
     )

     data_chirps$esi[data_chirps$esi == -9999] <- NA

     tmp <- merge(data_chirps,
                  expand.grid(id=unique(data_chirps$id), date=seq(date_range[1], date_range[2], by=1)),
                  by=c('id', 'date'), all=T)

     tmp <- lapply(split(tmp, factor(tmp$id)), FUN=function(x) {

          x$lon <- na.omit(unique(x$lon))
          x$lat <- na.omit(unique(x$lat))
          x$observed <- ifelse(is.na(x$esi), 0, 1)
          x$esi <- zoo::na.approx(x$esi, na.rm=FALSE)
          x[order(x$date),]
          return(x)

     })

     data_esi <- do.call(rbind, tmp)


     check_1 <- length(intervals) > 1
     check_2 <- FALSE
     if (length(intervals) == 1) if(intervals != 0) check_2 <- TRUE

     if (check_1 | check_2) {

          message(glue::glue("Calculating cumulative sums from the following intervals: {paste(intervals, collapse = ', ')}"))

          return_j <- function(x) {
               colnames(x) <- paste('esi_daily_avg', intervals, sep='_')
               return(x)
          }

          return_k <- function(x) as.data.frame(x)

          tmp <-
               foreach(i=unique(data_esi$id), .combine='rbind') %:%
               foreach(j=intervals, .combine='cbind', .final=return_j) %:%
               foreach(k=1:n_dates, .combine='c', .final=return_k) %do% {

                    x <- data_esi[data_esi$id == i,]

                    if (k > j) {

                         esi_avg <- mean(x[(k-j):k, 'esi'], na.rm=TRUE)

                    } else {

                         esi_avg <- NA

                    }

                    esi_avg
               }

          data_esi <- cbind(data_esi, as.data.frame(tmp))

     }

     # Clean up
     sel_cols <- which(!(colnames(data_esi) %in% c('id', 'lon', 'lat', 'date')))
     sel_rows <- which(data_esi$date < min(dates))
     data_esi[sel_rows, sel_cols] <- NA
     data_esi <- data_esi[complete.cases(data_esi),]
     colnames(data_esi)[colnames(data_esi) == 'esi'] <- 'esi_daily_avg'
     row.names(data_esi) <- NULL

     return(as.data.frame(data_esi))

}
