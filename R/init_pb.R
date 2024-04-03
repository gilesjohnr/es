#' Initialize a progress bar
#'
#' A wrapper function of the 'progress' package to initialize a default progress bar for long for loops
#'
#' @param x Integer giving length of the for loop
#'
#' @returns NULL
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#'      len <- 100
#'      pb <- .init_pb(len)
#'      for (i in 1:len) {
#'           pb$tick()
#'           Sys.sleep(0.01)
#'           }
#' }
#'
#' @export

.init_pb <- function(x) {

     return(
          progress::progress_bar$new(format = "[:bar] :percent | Elapsed: :elapsedfull | Remaining: :eta",
                                     total = x,
                                     complete = "=",
                                     incomplete = " ",
                                     current = " ",
                                     clear = FALSE,
                                     width = 90,
                                     force = TRUE)
     )
}
