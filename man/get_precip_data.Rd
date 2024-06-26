% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_precip_data.R
\name{get_precip_data}
\alias{get_precip_data}
\title{Get precipitation data}
\usage{
get_precip_data(lon, lat, dates, intervals = NULL)
}
\arguments{
\item{lon}{A numeric vector giving the longitude of the sampling sites in Decimal Degrees.}

\item{lat}{A numeric vector giving the latitude of the sampling sites in Decimal Degrees.}

\item{dates}{A character or date vector of dates giving the date when each sample was
collected (format is YYYY-MM-DD)}

\item{intervals}{An integer vector giving a set of time intervals over which to sum the
precipitation data. Default is NULL where the interval is 0 (returns the precipitation value at time t). If \code{intervals}=3
then the cumulative precipitation over the preceding 3 days is returned.}
}
\value{
data.frame
}
\description{
This function takes information of where and when a set of environmental samples were
collected and retrieves precipitation data (in millimeters) for those locations and times. Data come from
the Open-Meteo Historical Weather API (\url{https://open-meteo.com/en/docs/historical-weather-api})
via the \href{https://cran.r-project.org/web/packages/openmeteo/index.html}{\code{openmeteo}} R package.
Additionally, the optional \code{intervals} argument specifies a set of intervals over which the function
will calculate the cumulative sum of precipitation in millimeters (mm) for the previous X number of
days for each location.
}
\examples{
\dontrun{

d <- get_precip_data(lon = c(-56.0281, -54.9857),
                     lat = c(-2.9094, -2.8756),
                     dates = c("2017-12-01", "2017-12-31"),
                     intervals = c(1,3,7))

head(d)

ggplot2::ggplot(d, aes(x = date)) +
     geom_line(aes(y = precip_daily_sum_7, col='Cumulative sum 7 days')) +
     geom_line(aes(y = precip_daily_sum_3, col='Cumulative sum 3 days')) +
     geom_line(aes(y = precip_daily_sum_1, col='Cumulative sum 1 day')) +
     geom_line(aes(y = precip_daily_sum)) +
     facet_grid(rows=vars(id)) +
     labs(x="", y = "Precipitation (mm)") +
     theme_bw() +
     theme(legend.position = 'bottom',
           legend.title = element_blank())

}
}
