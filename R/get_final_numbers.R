#' final numbers
#'
#' @param out out
#' @param previous prev
#' @param num_previous num prev
#' @export
get_final_numbers <- function(out){
  df = tibble::tibble(
    ability = out[[1]],
    sem = out[[3]],
    ci_95 = out[[3]]*1.96
  )

  return(df)
}
