## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=FALSE---------------------------------------------------------------
x <- data.frame(wrapper_func=as.character(),
                description=as.character(),
                wrapped_pkg=as.character(),
                wrapped_func=as.character(),
                api=as.character())

# get_precip_data

x[1, 'wrapper_func'] <- "[get_precip_data](https://gilesjohnr.github.io/es/reference/get_precip_data.html)"
x[1, 'description'] <- "Cumulative daily millimeters of rainfall"
x[1, 'wrapped_pkg'] <- "[openmeteo](https://cran.r-project.org/web/packages/openmeteo/index.html)"
x[1, 'wrapped_func'] <- "[weather_history](https://rdrr.io/cran/openmeteo/man/weather_history.html)" 
x[1, 'api'] <- "[Open-Meteo Historical Weather API](https://open-meteo.com/en/docs/historical-weather-api)"

# get_temp_data

x[2, 'wrapper_func'] <- "[get_temp_data](https://gilesjohnr.github.io/es/reference/get_temp_data.html)"
x[2, 'description'] <- "[Accumulated Thermal Units (ATUs)](https://en.wikipedia.org/wiki/Accumulated_thermal_unit)"
x[2, 'wrapped_pkg'] <- "[openmeteo](https://cran.r-project.org/web/packages/openmeteo/index.html)"
x[2, 'wrapped_func'] <- "[weather_history](https://rdrr.io/cran/openmeteo/man/weather_history.html)" 
x[2, 'api'] <- "[Open-Meteo Historical Weather API](https://open-meteo.com/en/docs/historical-weather-api)"

# get_esi_data

x[3, 'wrapper_func'] <- "[get_esi_data](https://gilesjohnr.github.io/es/reference/get_esi_data.html)"
x[3, 'description'] <- "[Evapoartive Stress Index (ESI)](https://climateserv.readthedocs.io/en/latest/user/datasets.html#evaporative-stress-index-esi)"
x[3, 'wrapped_pkg'] <- "[chirps](https://docs.ropensci.org/chirps/)"
x[3, 'wrapped_func'] <- "[get_esi](https://docs.ropensci.org/chirps/reference/get_esi.html)" 
x[3, 'api'] <- "[SERVIR ClimateSERV API](https://servirglobal.net/services/climateserv)"

# get_river_discharge_data

x[4, 'wrapper_func'] <- "[get_river_discharge_data](https://gilesjohnr.github.io/es/reference/get_river_discharge_data.html)"
x[4, 'description'] <- "Daily river discharge of the nearest river in cubic meters per second ($m^3/s$)"
x[4, 'wrapped_pkg'] <- "[openmeteo](https://cran.r-project.org/web/packages/openmeteo/index.html)"
x[4, 'wrapped_func'] <- "[river_discharge](https://rdrr.io/cran/openmeteo/man/river_discharge.html)" 
x[4, 'api'] <- "[Open-Meteo Global Flood API](https://open-meteo.com/en/docs/flood-api)"

# get_elevation_data

x[5, 'wrapper_func'] <- "[download_elevation_data](https://gilesjohnr.github.io/es/reference/download_elevation_data.html), [get_elevation_data](https://gilesjohnr.github.io/es/reference/get_elevation_data.html)"
x[5, 'description'] <- "Digital Elevation Model (DEM) giving the height in meters above sea level, spatial resolution is ~100m"
x[5, 'wrapped_pkg'] <- "[elevatr](https://cran.r-project.org/web/packages/elevatr/index.html)"
x[5, 'wrapped_func'] <- "[get_elev_raster](https://www.rdocumentation.org/packages/elevatr/versions/0.99.0/topics/get_elev_raster), [get_elev_point](https://www.rdocumentation.org/packages/elevatr/versions/0.99.0/topics/get_elev_point)"
x[5, 'api'] <- "[Amazon Web Services Terrain Tiles](https://registry.opendata.aws/terrain-tiles/)"

# get_hydro_data

x[6, 'wrapper_func'] <- "[get_hydro_data](https://gilesjohnr.github.io/es/reference/get_hydro_data.html)"
x[6, 'description'] <- "slope, aspect, TWI, flow accumulation, distance to streams"
x[6, 'wrapped_pkg'] <- "[elevatr](https://cran.r-project.org/web/packages/elevatr/index.html), [WhiteboxTools R frontend](https://www.whiteboxgeo.com/wbt-frontends/) "
x[6, 'wrapped_func'] <- "[get_elev_raster](https://www.rdocumentation.org/packages/elevatr/versions/0.99.0/topics/get_elev_raster), [wbt_d_inf_flow_accumulation](https://rdrr.io/rforge/whitebox/man/wbt_d_inf_flow_accumulation.html), [wbt_wetness_index](https://rdrr.io/cran/whitebox/man/wbt_wetness_index.html)"
x[6, 'api'] <- "DEM from [Amazon Web Services Terrain Tiles](https://registry.opendata.aws/terrain-tiles/)"

# get_admin_data

x[7, 'wrapper_func'] <- "[download_admin_data](https://gilesjohnr.github.io/es/reference/download_admin_data.html), [get_admin_data](https://gilesjohnr.github.io/es/reference/get_admin_data.html)"
x[7, 'description'] <- "Names of all administrative areas for each sampling site"
x[7, 'wrapped_pkg'] <- "NA"
x[7, 'wrapped_func'] <- "NA"
x[7, 'api'] <- "GeoJSON files from the [geoBoundaries API](https://www.geoboundaries.org/) (saved as ESRI Shapefiles)"

# download_worldpop_data

x[8, 'wrapper_func'] <- "[download_worldpop_data](https://gilesjohnr.github.io/es/reference/download_worldpop_data.html)"
x[8, 'description'] <- "WorldPop raster data giving estimated population per grid cell"
x[8, 'wrapped_pkg'] <- "NA"
x[8, 'wrapped_func'] <- "NA"
x[8, 'api'] <- "GeoTIFF files from the [WorldPop FTP server](https://hub.worldpop.org/geodata/listing?id=29)"

# get_population_catchment

x[9, 'wrapper_func'] <- "[get_population_catchment](https://gilesjohnr.github.io/es/reference/get_population_catchment.html)"
x[9, 'description'] <- "Area of drainage catchments (sq km) and total population within each"
x[9, 'wrapped_pkg'] <- "[WhiteboxTools R frontend](https://www.whiteboxgeo.com/wbt-frontends/) "
x[9, 'wrapped_func'] <- "[wbt_d_inf_flow_accumulation](https://rdrr.io/rforge/whitebox/man/wbt_d_inf_flow_accumulation.html), [wbt_watershed](https://rdrr.io/cran/whitebox/man/wbt_watershed.html)"
x[9, 'api'] <- "User supplied elevation and population rasters."

# get_population_radius

x[10, 'wrapper_func'] <- "[get_population_radius](https://gilesjohnr.github.io/es/reference/get_population_radius.html)"
x[10, 'description'] <- "Total population within a given radius"
x[10, 'wrapped_pkg'] <- "[raster](https://cran.r-project.org/web/packages/raster/index.html), [exactextractr](https://cran.r-project.org/web/packages/exactextractr/index.html) "
x[10, 'wrapped_func'] <- "[buffer](https://rdrr.io/rforge/whitebox/man/wbt_d_inf_flow_accumulation.html), [exactextractr](https://rdrr.io/cran/exactextractr/man/exact_extract.html)"
x[10, 'api'] <- "User supplied population raster."

knitr::kable(
     x,
     col.names = c("`es` wrapper", 
                   "Description", 
                   "Package", 
                   "Function", 
                   "API"),
     table.attr = "style='width:100%;'"
)



