## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
collapse = TRUE,
comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  library(es)
#  library(sp)
#  library(sf)
#  library(raster)
#  library(ggplot2)
#  library(ggrepel)

## ----eval=FALSE---------------------------------------------------------------
#  # Get data frame of simulated environmental sampling data
#  df <- es::template_es_data
#  head(df)
#  
#  date location_id  lat   lon target_name ct_value
#  1 2020-03-07           1 23.8 90.37    target_0       NA
#  2 2020-03-07           1 23.8 90.37    target_0       NA
#  3 2020-03-07           1 23.8 90.37    target_0       NA
#  4 2020-03-07           1 23.8 90.37    target_0 29.95670
#  5 2020-03-07           1 23.8 90.37    target_1 31.60111
#  6 2020-03-07           1 23.8 90.37    target_1 32.20208
#  
#  # Create a directory to download spatial data and save intermediate output
#  dir.create(file.path(getwd(), 'tmp'))
#  
#  # Download population raster data from Worldpop
#  es::download_worldpop_data(
#       iso3 = 'BGD',
#       year = 2020,
#       constrained = FALSE,
#       UN_adjusted = FALSE,
#       path_output = file.path(getwd(), 'tmp')
#  )
#  
#  # Download a DEM for the area surrounding sampling sites
#  es::download_elevation_data(
#       lon = df$lon,
#       lat = df$lat,
#       path_output = file.path(getwd(), 'tmp')
#  )

## ----eval=FALSE---------------------------------------------------------------
#  # Delineate drainage catchments and calculate the population size within them
#  pop_catchment <- es::get_population_catchment(
#       lon = df$lon,
#       lat = df$lat,
#       path_pop_raster = file.path(getwd(), 'tmp/bgd_ppp_2020.tif'),
#       path_dem_raster = file.path(getwd(), 'tmp/dem.tif'),
#       path_output = file.path(getwd(), 'tmp')
#  )
#  
#  pop_catchment
#  
#  lon   lat catchment_area_km2 population_catchment
#  1 90.37 23.80              712.2                69635
#  2 90.38 23.80               31.0                 2834
#  3 90.37 23.81                5.2                  279
#  
#  pop_radius <- es::get_population_radius(
#       lon = df$lon,
#       lat = df$lat,
#       radius = 300,
#       path_pop_raster = file.path(getwd(), 'tmp/bgd_ppp_2020.tif'),
#       path_output = file.path(getwd(), 'tmp')
#  )
#  
#  pop_radius
#  
#      lon   lat population_radius_300
#  1 90.37 23.80                 62868
#  2 90.38 23.80                 38588
#  3 90.37 23.81                 21450
#  
#  # Merge with environmental sampling data
#  result <- merge(df, pop_catchment, by=c('lon', 'lat'), all.x=T)
#  result <- merge(result, pop_radius, by=c('lon', 'lat'), all.x=T)
#  head(result)
#  
#      lon  lat       date location_id target_name ct_value catchment_area_km2 population_catchment population_radius_300
#  1 90.37 23.8 2020-03-07           1    target_0       NA              712.2                69635                 62868
#  2 90.37 23.8 2020-03-07           1    target_0       NA              712.2                69635                 62868
#  3 90.37 23.8 2020-03-07           1    target_0       NA              712.2                69635                 62868
#  4 90.37 23.8 2020-03-07           1    target_0 29.95670              712.2                69635                 62868
#  5 90.37 23.8 2020-03-07           1    target_1 31.60111              712.2                69635                 62868
#  6 90.37 23.8 2020-03-07           1    target_1 32.20208              712.2                69635                 62868
#  

