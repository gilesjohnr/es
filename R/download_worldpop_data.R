#' Download WorldPop population raster data
#'
#' This function takes a single ISO country code and downloads the appropriate population count raster data (100m grid cell resolution)
#' from the WorldPop FTP data server. Note that these data are spatial disaggregations of census data using random forest models described in
#' [Lloyd et al. 2019](https://www.tandfonline.com/doi/full/10.1080/20964471.2019.1625151) and available for manual download at
#' [https://hub.worldpop.org/geodata/listing?id=29](https://hub.worldpop.org/geodata/listing?id=29). Downloaded data sets are
#' saved to the \code{path_output} directory in .tif format.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)). Can accept a vector of multiple ISO codes.
#' @param year A numeric or integer scalar giving the year of WorldPop data to download (as of 2024-05-15, years 2000-2020 are available)
#' @param constrained Logical indicating whether to get population counts estimated using constrained models (details [HERE](https://www.worldpop.org/methods/top_down_constrained_vs_unconstrained/)).
#' Default is FALSE.
#' @param UN_adjusted Logical indicating whether to get population counts that are adjusted to match United Nations national population estimates
#' (details [HERE](https://hub.worldpop.org/project/categories?id=3)). Default is FALSE.
#' @param path_output A character string giving the file path of an output directory to save downloaded data.
#'
#' @returns Character string giving path to downloaded data.
#'
#' @examples
#' \dontrun{
#'
#' download_worldpop_data(iso3='TWN',
#'                        year=2020,
#'                        constrained=FALSE,
#'                        UN_adjusted=FALSE,
#'                        path_output=getwd())
#'
#' }

download_worldpop_data <- function(iso3,
                                   year,
                                   constrained=FALSE,
                                   UN_adjusted=FALSE,
                                   path_output
){

     # Checks
     if (!is.character(iso3)) stop('iso3 code(s) must be character')
     if (length(iso3) != 1) stop('one iso3 code at a time')
     if (!(is.integer(year) | is.numeric(year))) stop('year must be integer')
     if (length(year) != 1) stop('one year at a time')
     if (!is.logical(constrained)) stop('constrained must be logical')
     if (!is.logical(UN_adjusted)) stop('UN_adjusted must be logical')
     if (!is.character(path_output)) stop('path_output code(s) must be a character string')
     if (!dir.exists(path_output)) stop('path_output does not exist')

     message("Checking availability of the country and year...")

     # Set base url
     url_base <- "https://data.worldpop.org/GIS/Population"
     sub_dir_global_data <- "Global_2000_2020"
     if (constrained) sub_dir_global_data <- glue::glue("{sub_dir_global_data}_Constrained")

     # Check years exist
     tmp <- RCurl::getURL(glue::glue("{url_base}/{sub_dir_global_data}/"), header=FALSE)
     tmp <- XML::getHTMLLinks(tmp)
     tmp <- gsub("/", "", tmp)
     years_available <- suppressWarnings(na.omit(as.integer(tmp)))
     if (constrained) years_available <- "2020"
     if (!(year %in% years_available)) stop('year not available. Only 2020 available for type constrained') else message(glue::glue("{year} found"))

     # Set url of iso dirs
     url_iso <- glue::glue("{url_base}/{sub_dir_global_data}/{year}/")
     if (constrained) url_iso <- glue::glue("{url_iso}BSGM/")

     # Check iso3 exists
     tmp <- RCurl::getURL(url_iso)
     tmp <- XML::getHTMLLinks(tmp)
     iso3_available <- as.vector(gsub("/", "", tmp))
     if (!(iso3 %in% iso3_available)) stop('iso3 not available') else message(glue::glue("{iso3} found"))

     # Set file name
     file_name <- glue::glue("{tolower(iso3)}_ppp_{year}")
     if (UN_adjusted) file_name <- glue::glue("{file_name}_UNadj")
     if (constrained) file_name <- glue::glue("{file_name}_constrained")
     file_name <- glue::glue("{file_name}.tif")

     # Set full url path to the data
     url_data <- glue::glue("{url_iso}{iso3}/{file_name}")

     # Download to path_output
     download.file(url = url_data,
                   destfile = file.path(path_output, file_name),
                   method='auto',
                   quiet = FALSE,
                   mode = "wb",
                   cacheOK = TRUE,
                   extra = getOption("download.file.extra"))

     message('Done.')
     message(glue::glue("Data saved here: {path_output}/{file_name}"))
     return(file.path(path_output, file_name))

}
