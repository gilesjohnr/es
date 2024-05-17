#' Convert coordinates to ISO country code
#'
#' This function takes a set of longitude and latitude coordinates and retrieves the administrative
#' units that each point lies within. The administrative units are given in the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)).
#'
#' @param lat A numeric vector giving the latitude of the sampling sites in Decimal Degrees.
#' @param lon A numeric vector giving the longitude of the sampling sites in Decimal Degrees.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' coords_to_iso3(lon = template_es_data$lon,
#'                lat = template_es_data$lat)
#'
#' }

coords_to_iso3 <-  function(lon,
                            lat
){

     check <- length(lat) == length(lon)
     if (!check) stop('lat and lon args must be equal in length')
     if (!is.numeric(lon) | !is.numeric(lat)) stop('lat and lon args must be numeric')

     countries <- rworldmap::getMap(resolution = 'high')

     pts = sp::SpatialPoints(cbind(x=lon, y=lat),
                             sp::CRS(sp::proj4string(countries)))

     tmp <- sp::over(pts, countries)

     out <- data.frame(
          lon = lon,
          lat = lat,
          admin_0_iso = as.character(tmp$ISO3),
          admin_0_name = as.character(tmp$ADMIN)
     )

     return(out)

}
