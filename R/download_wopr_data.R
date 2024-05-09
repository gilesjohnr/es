#' Download population raster data from WorldPop
#'
#' This function takes a single ISO country code, or vector of multiple ISO country codes, and downloads the appropriate
#' 100m resolution population count raster data from the WorldPop REST API. Note that these data are spatial
#' disaggregations of census data using random forest models described in [Lloyd et al. 2019](https://www.tandfonline.com/doi/full/10.1080/20964471.2019.1625151)
#' and available for manual download at [https://hub.worldpop.org/geodata/listing?id=29](https://hub.worldpop.org/geodata/listing?id=29). Downloaded data sets
#' are saved to the \code{output_path} directory in .tif format.
#'
#' @param iso3 A three-letter capitalized character string. Must follow the ISO-3166 Alpha-3 country code
#' standard ([https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)). Can accept a vector of multiple ISO codes.
#' @param output_path A character string giving the file path of an output directory to save downloaded data.
#'
#' @returns NULL
#'
#' @examples
#' \dontrun{
#'
#' download_wopr_data(iso3 = 'FRA', output_path = getwd())
#'
#' }

download_wopr_data <- function(iso3,
                               output_path
){

     if (!is.character(iso3)) stop('iso3 code(s) must be character')
     if (!is.logical(save_data)) stop('save_data must be logical')

     # Create temp dir
     tmp_root <- getwd()
     tmp_time <- as.character(round(Sys.time(), 0))
     tmp_time <- paste(unlist(strsplit(tmp_time, '[:/ -]')), collapse='_')
     tmp_path <- file.path(tmp_root, paste0('es_output_', tmp_time))
     if (!dir.exists(tmp_path)) dir.create(tmp_path)
     if (!dir.exists(file.path(tmp_path, 'wopr'))) dir.create(file.path(tmp_path, 'wopr'))

     # Ping API and check if all iso codes are available
     message("Checking that ISO country codes are available on Worldpop server...")
     wopr_response <- es::query_wopr_api(NULL)
     wopr_response_data <- unlist(wopr_response$data)
     wopr_pop_iso <- unique(wopr_response_data[names(wopr_response_data) == 'iso3'])

     if (!all(iso3 %in% wopr_pop_iso)) {
          stop(glue::glue("Some of the ISO codes are not available in Worldpop API: {paste(iso3[!(iso3 %in% wopr_pop_iso)], collapse=', ')}"))
     } else {
          message(glue::glue("Found: {paste(iso3, collapse=', ')}"))
     }

     for (i in iso3) {

          # Check what wopr data are available
          wopr_response <- es::query_wopr_api(i)
          wopr_response_data <- unlist(wopr_response$data)
          wopr_pop_files <- wopr_response_data[names(wopr_response_data) == 'data_file']
          names(wopr_pop_files) <- NULL

          # Get latest year of data
          tmp <- strsplit(wopr_pop_files, "/")
          tmp <- lapply(tmp, function(x) x[length(x)-2])
          sel_latest_year <- which.max(as.integer(unlist(tmp)))
          wopr_data_file <- wopr_pop_files[sel_latest_year]

          # Get file name
          tmp <- unlist(strsplit(wopr_data_file, "/"))
          wopr_file_name <- tmp[length(tmp)]

          # Download to output_path
          download.file(url = file.path('https://data.worldpop.org', wopr_data_file),
                        destfile = file.path(output_path, 'wopr', wopr_file_name),
                        method='auto',
                        quiet = FALSE,
                        mode = "w",
                        cacheOK = TRUE,
                        extra = getOption("download.file.extra"))

     }

     message('Done.')
     message(glue::glue("Data saved here: {output_path}/wopr"))

}
