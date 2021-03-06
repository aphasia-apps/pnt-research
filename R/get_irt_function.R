############# return a new slide function script #############

# This is where all the magic happens


# the magic!

#' irt magic function
#'
#' @param all_items everything
#' @param IRT irt yes no
#' @param exclude_previous like name
#' @param previous prev if
#' @param test test
#' @export
irt_function <- function(all_items, IRT = T,  test = NA, exclude_eskimo = T){

      # this is for the out argument. 
      # creates a vector of the items that have already been completed
      # to be fed to IRT so they don't get chosen again
      completed = all_items %>% 
        tidyr::drop_na(response) %>%
        dplyr::pull(item_number)
      
      # dataframe of inputs
      pars = data.frame(a = all_items$discrimination,
                        b = all_items$itemDifficulty, # CHANGE TO T SCORES 50 +/- 10
                        c = rep(1), #1PL has no guessing parameter ,
                        d = rep(0), #1PL has no innatention parameter,
                        cbGroup = rep(1))
      
      # breaks it down into what gets fed into the 1PL IRT
      prov = catR::breakBank(pars)
      bank = prov$itemPar
      rownames(bank) <- all_items$target
      x = all_items$response
       # ability estimate using bayes modal:
      # 10-6 CHANGING TO T ESTIMATES
      
       ability = catR::thetaEst(bank, x, method = "EAP")
       # generates the next item
       # standard error of the mean
       # CHANGE FOR T-SCORE HERE
       sem = catR::semTheta(ability, bank, x, method = "EAP")
       
       if(IRT){
         # removes eskimo
         completed = c(completed, 49)
         
         next_item = if(length(completed)<174){
           # CHANGE FOR T SCORE HERE
           catR::nextItem(itemBank = bank, theta = ability, out = completed,
                          method = "EAP")
         } else {
           NA
         }
       

         tmp_list = list(
         ability,
         next_item,
         sem
         )
       return(tmp_list)
       
    } else if(test == "walker") {
      # randomize? if true, then use random order column
      next_slide_num <- all_items %>%
        dplyr::mutate(next_item = ifelse(!is.na(response), walker_order+1, NA)) %>%
        dplyr::filter(walker_order == max(next_item, na.rm = T)) 
      
      tmp_list = list(
        ability,
        list(
          NA,
          slide_num_out = ifelse(nrow(next_slide_num) < 1, 190, next_slide_num$slide_num)
        ),
        sem
      )
      
      return(tmp_list)
      
    } else { # this is the full PNT
        if(exclude_eskimo){
          
        next_slide_num <- all_items %>%
          dplyr::filter(item_number != 49) %>% 
          dplyr::filter(is.na(response))
        
            if(nrow(next_slide_num)>=1){
              next_slide_num <- next_slide_num %>%
                dplyr::filter(pnt_order == min(pnt_order))
            }
        
        # helps with ending the test
        out_stop = 189
        
        } else {
          
          next_slide_num <- all_items %>%
            dplyr::filter(is.na(response)) 
          
            if(nrow(next_slide_num)>=1){
              next_slide_num <- next_slide_num %>%
                dplyr::filter(pnt_order == min(pnt_order))
            }
        # helps with ending the test. see tmp list
        out_stop = 190
        }
      
      tmp_list = list(
        ability,
        list(
          NA,
          slide_num_out = ifelse(nrow(next_slide_num) < 1, out_stop, next_slide_num$slide_num)
          ),
        sem
      )
      
      return(tmp_list)
      
    }
}







