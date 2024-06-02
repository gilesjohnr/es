#' Apply the delta delta Ct calculation to a data.frame
#'
#' This function will calculate the delta delta Ct metric for all applicable observations in a data.frame
#' by applying the \code{calc_delta_delta_ct} function. The data.frame must have the following columns:
#' 'location_id', 'sample_date', 'target_name', and 'ct_value'. The relevant target_names and associated reference_names
#' must be provided. The result is a data.frame containing a 'delta_delta_ct' column which can be merge into the source data.frame.
#'
#' @param df A data.frame containing the following columns: 'location_id', 'sample_date', 'target_name', and 'ct_value'.
#' @param target_names Character vector giving the names of the target genes.
#' @param reference_names Character vector giving the names of the reference genes associated with each target gene.
#' @param pae_names Character vector giving the names of the target genes and reference genes for which the percentile amplification efficiency has been estimated. Default is NULL.
#' @param pae_values A numeric scalar giving the estimated PCR amplification efficiency for each of the names in `pae_names`. Defaults is NULL, which assumes 100% efficiency.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' df_example <- template_es_data
#' colnames(df_example)[colnames(df_example) == 'date'] <- 'sample_date'
#'
#' pae <- apply_amplification_efficiency(template_standard_curve)
#'
#' ddct_standard <- apply_delta_delta_ct(df = df_example,
#'                                       target_names = c('target_1', 'target_2', 'target_3'),
#'                                       reference_names = rep('target_0', 3))
#'
#' ddct_adjusted <- apply_delta_delta_ct(df = df_example,
#'                                       target_names = c('target_1', 'target_2', 'target_3'),
#'                                       reference_names = rep('target_0', 3),
#'                                       pae_names = pae$target_name,
#'                                       pae_values = pae$mean)
#'
#' }
#'

apply_delta_delta_ct <- function(df,
                                 target_names,
                                 reference_names,
                                 pae_names=NULL,
                                 pae_values=NULL
){

     cond <- length(target_names) == length(reference_names)
     if (!cond) stop("'target_names' and 'reference_names' lengths unequal")

     cond <- length(pae_names) == length(pae_values)
     if (!cond) stop("'pae_names' and 'pae_values' lengths unequal")

     if (!is.data.frame(df)) stop('df must be data.frame')
     if (!is.character(target_names)) stop('target_names must be character')
     if (!is.character(reference_names)) stop('reference_names must be character')
     if (!is.null(pae_names)) if (!is.character(pae_names)) stop('pae_names must be character')
     if (!is.null(pae_values)) if (!is.numeric(pae_values)) stop('pae_values must be numeric')
     if (sum(c(is.null(pae_names), is.null(pae_values))) == 1) stop('both pae_* args required')
     if (!all(target_names %in% df$target_name)) stop('Not all target_names are found in df')
     if (!all(reference_names %in% df$target_name)) stop('Not all reference_names are found in df')
     if (!is.null(pae_names)) if (!all(target_names %in% pae_names)) stop('Not all target_names foundin pae_names')
     if (!is.null(pae_names)) if (!all(reference_names %in% pae_names)) stop('Not all reference_names foundin pae_names')

     cols_required <- c('location_id', 'sample_date', 'target_name', 'ct_value')
     cond <- all(cols_required %in% colnames(df))
     if (!cond) stop(glue::glue("'df' must contain columns: {paste(cols_required, collapse=', ')}"))

     df <- df[,colnames(df) %in% cols_required]


     sel <- target_names %in% df$target_name & !(reference_names == "NA" | is.na(reference_names))
     target_names <- target_names[sel]
     reference_names <- reference_names[sel]

     # If no PAE value are supplied, calculate standard delta delta Ct
     if (is.null(pae_names)) {
          pae_names <- unique(c(target_names, reference_names))
          pae_values <- rep(1, length(pae_names))
     }

     #df_loc <- df[df$location_id == 1,]

     df_delta <- lapply(split(df, factor(df$location_id)), function(df_loc){

          x <- as.data.frame(data.table::dcast(data = data.table::as.data.table(df_loc),
                                               formula = location_id + sample_date ~ target_name,
                                               value.var = 'ct_value',
                                               fun.aggregate = identity,
                                               drop = FALSE,
                                               fill = NA))

          sel_value_cols <- which(!colnames(x) %in% c('location_id', 'sample_date'))

          out <- x
          out[,sel_value_cols] <- as.numeric(NA)

          for (i in 1:length(target_names)) {

               sel_target_ct <- which(colnames(x) == target_names[i])
               sel_reference_ct <- which(colnames(x) == reference_names[i])
               sel_target_pae <- which(pae_names == target_names[i])
               sel_reference_pae <- which(pae_names == reference_names[i])
               t0 <- which(x$sample_date == min(x$sample_date[!is.na(x$sample_date) & !is.na(x[,sel_target_ct])]))

               for (t in 1:nrow(out)) {

                    out[t, sel_target_ct] <- calc_delta_delta_ct(ct_target_treatment = x[t, sel_target_ct],
                                                                 ct_target_control = x[t0, sel_target_ct],
                                                                 ct_reference_treatment = x[t, sel_reference_ct],
                                                                 ct_reference_control = x[t0, sel_reference_ct],
                                                                 pae_target_treatment = pae_values[sel_target_pae],
                                                                 pae_target_control = pae_values[sel_target_pae],
                                                                 pae_reference_treatment = pae_values[sel_reference_pae],
                                                                 pae_reference_control = pae_values[sel_reference_pae])

               }

          }

          out_wide <- data.table::melt(data = data.table::as.data.table(out),
                                       id.vars = c('location_id', 'sample_date'),
                                       measure.vars = colnames(out)[sel_value_cols],
                                       variable.name = 'target_name',
                                       value.name = 'delta_delta_ct')

          out_wide <- as.data.frame(out_wide[complete.cases(out_wide),])
          return(out_wide)

     })

     df_delta <- do.call(rbind, df_delta)
     return(df_delta)

}
