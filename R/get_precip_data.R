#' Get precipitation data
#'
#' This function takes information of where and when a set of environmental samples were
#' collected and retrieves precipitation data for those locations and times. Data come from
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#' @param dates A character or date vector of dates giving the date when each sample was
#' collected (format is YYYY-MM-DD)
#' @param intervals An integer vector giving a set of time intervals over which to sum the
#' precipitation data. Defaults to 1 (returns the precipitation value at time t). If `intervals`=3
#' then the cumulative precipitation over the preceding 3 days is returned.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' ll <- data.frame(lon = c(-56.0281, -54.9857),
#'                  lat = c(-2.9094, -2.8756))
#'
#' d <- get_precip_data(lon=ll$lon,
#'                      lat=ll$lat,
#'                      dates = c("2017-12-01", "2017-12-31"),
#'                      intervals = c(1,3,7))
#'
#' head(d)
#'
#' ggplot2::ggplot(d, aes(x = date)) +
#'      geom_line(aes(y = precip_mm_sum_7, col='Cumulative sum 7 days')) +
#'      geom_line(aes(y = precip_mm_sum_3, col='Cumulative sum 3 days')) +
#'      geom_line(aes(y = precip_mm_sum_1, col='Cumulative sum 1 day')) +
#'      geom_line(aes(y = precip_mm)) +
#'      facet_grid(rows=vars(id)) +
#'      labs(x="", y = "Precipitation (mm)") +
#'      theme_bw() +
#'      theme(legend.position = 'bottom',
#'            legend.title = element_blank())
#'
#' }

if (F) {

     lon <- template_es_data$lon
     lat <- template_es_data$lat
     dates <- template_es_data$date
     intervals <- 1

     lon <- ll$lon
     lat <- ll$lat
     dates <- c("2017-12-01", "2017-12-31")

     ll <- data.frame(lon = c(-56.0281, -54.9857),
                      lat = c(-2.9094, -2.8756))

     d <- get_precip_data(lon=ll$lon,
                          lat=ll$lat,
                          dates = c("2017-12-01", "2017-12-31"),
                          intervals = c(1,3,7))

     head(d)

     ggplot2::ggplot(d, aes(x = date)) +
          geom_line(aes(y = precip_mm_sum_7, col='Cumulative sum 7 days')) +
          geom_line(aes(y = precip_mm_sum_3, col='Cumulative sum 3 days')) +
          geom_line(aes(y = precip_mm_sum_1, col='Cumulative sum 1 day')) +
          geom_line(aes(y = precip_mm)) +
          facet_grid(rows=vars(id)) +
          labs(x="", y = "Precipitation (mm)") +
          theme_bw() +
          theme(legend.position = 'bottom',
                legend.title = element_blank())



}

get_precip_data <- function(lon,
                            lat,
                            dates,
                            intervals=NULL
){

     # Checks
     check <- length(lat) == length(lon) & length(lat) == length(dates)
     if (!check) stop('lat, lon, and dates must be equal in length')

     dates <- as.Date(dates, format='%Y-%m-%d')
     if (all(is.na(dates))) stop('Cannot identify date format')

     if (is.null(intervals)) intervals <- 0

     # Get distinct coordinate sets
     tmp <- data.frame(lon, lat)
     tmp <- dplyr::distinct(tmp)

     date_range <- c(min(dates)-max(intervals), max(dates))

     n_locations <- nrow(tmp)
     n_dates <- (date_range[2] - date_range[1]) + 1

     # Download precip data from Climate Hazards Group server
     message(glue::glue("Total locations = {n_locations}"))
     message(glue::glue("Date range = {paste(c(min(dates), max(dates)), collapse=' -- ')}"))
     message("Downloading precipitation data via 'chirps' package")

     data_chirps <- chirps::get_chirps(object=tmp,
                                       dates=as.character(date_range),
                                       server='CHC',
                                       resolution=0.05,
                                       as.data.frame=TRUE)

     check_1 <- length(intervals) > 1
     check_2 <- FALSE
     if (length(intervals) == 1) if(intervals != 0) check_2 <- TRUE

     if (check_1 | check_2) {

          message(glue::glue("Calculating cumulative sums from the following intervals: {paste(intervals, collapse = ', ')}"))

          return_j <- function(x) {
               colnames(x) <- paste('precip', 'mm', 'sum', intervals, sep='_')
               return(x)
          }

          return_k <- function(x) as.data.frame(x)

          tmp <-
               foreach(i=unique(data_chirps$id), .combine='rbind') %:%
               foreach(j=intervals, .combine='cbind', .final=return_j) %:%
               foreach(k=1:n_dates, .combine='c', .final=return_k) %do% {

                    x <- data_chirps[data_chirps$id == i,]

                    if (k > j) {

                         chirp_sum <- sum(x[(k-j):k,'chirps'], na.rm=TRUE)

                    } else {

                         chirp_sum <- NA

                    }

                    chirp_sum
               }


          data_chirps <- cbind(data_chirps, as.data.frame(tmp))

     }

     # Clean up
     sel_cols <- which(!(colnames(data_chirps) %in% c('id', 'lon', 'lat', 'date')))
     sel_rows <- which(data_chirps$date < min(dates))
     data_chirps[sel_rows, sel_cols] <- NA
     data_chirps <- data_chirps[complete.cases(data_chirps),]

     colnames(data_chirps)[colnames(data_chirps) == 'chirps'] <- 'precip_mm'


     return(as.data.frame(data_chirps))

}
