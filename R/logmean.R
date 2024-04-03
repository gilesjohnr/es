#' Calculate the mean in log space
#'
#' This function gives the mean taken in log-scale for a set of numeric values. Values less than
#' or equal to zero are ignored as NA. Best suited for values taken from a highly skewed distribution,
#' as Ct values often are.
#'
#' @param x A vector containing numeric values
#'
#' @returns Scalar
#'
#' @examples
#' \dontrun{
#'
#' logmean(c(24.3, 10.3, 40, NA, 0, -1, 0.05))
#'
#' }

logmean <- function(x) {

     x <- as.numeric(x)
     x[x <= 0] <- NA
     m <- exp(mean(log(x), na.rm=TRUE))
     if (is.nan(m)) m <- NA
     return(m)

}
