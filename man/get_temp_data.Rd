% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_temp_data.R
\name{get_temp_data}
\alias{get_temp_data}
\title{Get temperature data}
\usage{
get_temp_data(lon, lat, dates, intervals = NULL)
}
\arguments{
\item{lon}{A numeric vector giving the longitude of the sampling sites in Decimal Degrees.}

\item{lat}{A numeric vector giving the latitude of the sampling sites in Decimal Degrees.}

\item{dates}{A character or date vector of dates giving the date when each sample was
collected (format is YYYY-MM-DD)}

\item{intervals}{An integer vector giving a set of time intervals over to calculate accumulated degree-days. Default
is NULL where the interval is 0 (returns the daily temperature in degrees Celsius at time t). If \code{intervals}=3 then the accumulated
degree-days for the preceding 3 days is returned.}
}
\value{
data.frame
}
\description{
This function takes information of where and when a set of environmental samples were
collected and retrieves temperature data (measured in accumulated degree-days) for those locations and times. Data come from
the Open-Meteo Historical Weather API (\url{https://open-meteo.com/en/docs/historical-weather-api})
via the \href{https://cran.r-project.org/web/packages/openmeteo/index.html}{\code{openmeteo}} R package. The optional \code{intervals} argument
specifies a set of intervals over which the function will calculate the accumulated temperature in the form of Accumulated Thermal Units (ATUs) for each interval.
}
\examples{
\dontrun{

d <- get_temp_data(lon = c(30.0281, -52.9857),
lat = c(15.9094, -25.8756),
dates = c("2020-08-01", "2020-12-31"),
intervals = c(1,5,10))

head(d)

ggplot2::ggplot(d, aes(x = date)) +
     geom_line(aes(y = temp_daily_atu_10, col='Accumulated temperature 10 days')) +
     geom_line(aes(y = temp_daily_atu_5, col='Accumulated temperature 5 days')) +
     geom_line(aes(y = temp_daily_atu_1, col='Accumulated temperature 1 day')) +
     geom_line(aes(y = temp_daily_atu)) +
     facet_grid(rows=vars(id)) +
     labs(x="", y = "Accumulated Thermal Units (ATUs)") +
     theme_bw() +
     theme(legend.position = 'bottom',
           legend.title = element_blank())

}
}
