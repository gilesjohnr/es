#' Apply the delta delta Ct calculation to a data.frame
#'
#' This function will calculate the delta delta Ct metric for all applicable observations in a data.frame
#' by applying the \code{calc_delta_delta_ct} function. The data.frame must have the following columns:
#' 'location_id', 'sample_date', 'target_name', and 'ct_value'. The relevant target_names and and associated reference_names
#' must be provided. The result is a data.frame containing a 'delta_delta_ct' column which can be merge into the source data.frame.
#'
#' @param df A data.frame of class \code{esdata}.
#' @param target_names Character vector giving the names of the target genes.
#' @param reference_names Character vector giving the names of the reference genes associated with each target gene.
#' @param amplification_efficiency A scalar between 0 and 1 giving the assumed PCR amplification efficiency for all samples in the equation. Defaults to 1, which assumes 100% efficiency.
#'
#' @returns data.frame
#'
#' @examples
#' \dontrun{
#'
#' df_example <- data.frame(location_id = c(rep(1,9), rep(2,9), rep(3,9)),
#'                          sample_date = as.Date(rep(c(rep('2024-01-01',3), rep('2024-01-02',3), rep('2024-01-03',3)), 3)),
#'                          target_name = rep(c('gene1', 'gene2', 'housekeeping'), 9),
#'                          ct_value = as.numeric(runif(27, min=5, max=40)))
#'
#' df_result <- apply_delta_delta_ct(df = df_example,
#'                                   target_names = c('gene1', 'gene2'),
#'                                   reference_names = c('housekeeping', 'housekeeping'),
#'                                   amplification_efficiency = 0.95)
#'
#' merge(df_example, df_result, by=c('location_id', 'sample_date', 'target_name'), all.x=TRUE)
#'
#' }

apply_delta_delta_ct <- function(df,
                                 target_names,
                                 reference_names,
                                 amplification_efficiency=1
){

     cond <- length(target_names) == length(reference_names)
     if (!cond) stop("'target_names' and 'reference_names' lengths unequal")

     cols_required <- c('location_id', 'sample_date', 'target_name', 'ct_value')
     cond <- all(cols_required %in% colnames(df))
     if (!cond) stop(glue::glue("'df' must contain columns: {paste(cols_required, collapse=', ')}"))

     df <- df[,colnames(df) %in% cols_required]

     df_delta <- pbapply::pblapply(split(df, factor(df$location_id)), function(df_loc){

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

               sel_target_col <- which(colnames(x) == target_names[i])
               sel_reference_col <- grep(reference_names[i], colnames(x))
               t0 <-  which(x$sample_date == min(x$sample_date[!is.na(x$sample_date) & !is.na(x[,sel_target_col])]))

               for (t in 1:nrow(out)) {

                    out[t, sel_target_col] <- calc_delta_delta_ct(ct_target_t = x[t, sel_target_col],
                                                                  ct_reference_t = logmean(x[t, sel_reference_col]),
                                                                  ct_target_t0 = x[t0, sel_target_col],
                                                                  ct_reference_t0 = logmean(x[t0, sel_reference_col]),
                                                                  amplification_efficiency = amplification_efficiency)

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
