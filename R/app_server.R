
`%!in%` <- Negate(`%in%`)

#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  ########################## Initialize reactive values ##########################
  # ------------------------------------------------------------------------------
  ################################################################################
  # reactiveValues is a list where elements of the list can change
  values = reactiveValues()
  values$item_difficulty <- items #items...see observe #dataframe of potential values
  values$i = 0 # this is the counter to track the slide number
  values$test_length <- NULL # number of items to test
  values$irt_out <- list(0, 0, 11) # will be overwritten if IRT 
  values$min_sem <- NULL # sem precision
  values$previous <- NULL # previous data if uploaded
  values$num_previous <- 0 # number of previous tests
  values$datetime <- Sys.time() # establishes datetime when app opens for saving
  values$downloadableData = F # will the download data button appear? starts with no. yes after first response. 
  
  ################################## OBSERVERS ###################################
  # ------------------------------------------------------------------------------
  ################################################################################
  
  ###########################Intro tab next and back############################
  
  # includes a few other actions when moving to the last page. 
  observeEvent(input$administer_test,{
    updateTabsetPanel(session, "glide", "glide1")
  })
  
  observeEvent(input$glide_back1,{
    updateTabsetPanel(session, "glide", "glide0")
  })
  
  observeEvent(input$glide_next2,{
    updateTabsetPanel(session, "glide", "glide3")
  })
  
  observeEvent(input$glide_back2,{
    updateTabsetPanel(session, "glide", "glide1")
  })
  ################################ SOUND ON ##### ##############################
  
  observeEvent(input$sound,{
    if(!isTruthy(input$sound)){
      values$sound = "document.getElementById('audio').play();"
    } else {
      values$sound = ""
    }
  })
  
  ##########################NUM ITEMS AND PRECISION#############################
  # enables or disables precision option if SEM is or isn't selected. 
  # also converts the numeric option to a number
  # saves either to values$test_length
  observe({
   if(input$numitems == "175"){
      # full pnt
      values$test_length <- ifelse(input$eskimo, 174, 175)
      shinyjs::show("random")
      shinyjs::show("eskimo")
    } else {
      # fixed length IRT
      values$test_length <- as.numeric(input$numitems)
      shinyjs::hide("eskimo")
    }
  })
  
  #############################START OVER#########################################
  # if start over is hit, go to home page
  # start assessment button then resets everything
  observeEvent(input$start_over,{
    session$reload()
  })
  
  ################################ END TEST ##################################
  
  observeEvent(input$end_test,{
    shinyWidgets::confirmSweetAlert(
      inputId = "confirm_end_test",
      session = session,
      title = "Are you sure you want to stop?",
      text = "Only items with confirmed responses will be saved.",
      type = "warning",
    )
  })
  
  observeEvent(input$confirm_end_test,{
    if(isTruthy(input$confirm_end_test)){
      updateNavbarPage(session, "mainpage",
                       selected = "Results")
    }
  })
  ################################ Displaying key inputs #######################
  
  output$key_feedback_practice <- renderText({
    req(values$key_val)
    values$key_val
  })
  
  output$key_feedback_slides <- renderText({
    req(values$key_val)
    values$key_val
  })
  
  ################################ START PRACTICE ##############################
  observeEvent(input$start_practice,{
    
    # runjs("document.getElementById('audio').play();") # play click
    shinyjs::runjs(values$sound)
    values$i = 1 # reset values$i
    values$n = 130 # reset 
    values$key_val = NULL # keeps track of button press 1 (error), 2 (correct)
    # only use IRT function if NOT 175 items
    # IRT is poorly named - this should say CAT - aka not computer adaptive is CAT = F
    values$IRT = ifelse(input$numitems == "175", FALSE, TRUE)
    shinyjs::show("start_over")
    shinyjs::show("help")
    # go to practice slides
    updateNavbarPage(session, "mainpage",
                     selected = "Practice")
  })
  
  ################################## START ASSESSMENT ############################
  # start button. sets the i value to 1 corresponding to the first slide
  # switches to the assessment tab
  # initialize values in here so that they reset whever someone hits start. 
  observeEvent(input$start, {
    
    # keeps track of button press 1 (error), 2 (correct)
    values$i = 1
    
    # randomly orders stuff if the random order box is checked. only affects 175
    if(isTruthy(input$random)){
      values$item_difficulty <-
        values$item_difficulty %>%
        dplyr::mutate(pnt_order = sample(pnt_order)) %>%
        dplyr::arrange(pnt_order)
    }
    
    values$n = 
      # regular old CAT 
      if(isTruthy(values$IRT)){
      # samples one of four first possible items, unless used previously...
      # returns the first item number
        130
      # walker first item
    } else if (isTruthy(input$random)) {
      # if random, grab first row in values$item_difficulty,
      # which is already randomized in code above
      values$item_difficulty[values$item_difficulty$pnt_order == 1,]$slide_num 
    } else {
      14 #otherwise candle
    }
    # for testing:
    if (isTRUE(getOption("shiny.testmode"))) {
      shinyjs::reset("keys")
    }
    values$irt_out <- list(0, 0, 11) # reset saved data just in case. 
    #play a sound...not working right now :(
    shinyjs::runjs("document.getElementById('audio').play();")
    # got to slides
    # reset keyval
    values$key_val = NULL # keeps track of button press 1 (error) or 2 (correct)
    if (isTRUE(getOption("shiny.testmode"))) {
      shinyjs::reset("keys")
    }
    updateNavbarPage(session, "mainpage", selected = "Assessment")
  })
  
  
  # records the inputted 95% CI width to SEM
  observeEvent(input$ci_95,{
    values$min_sem <- input$ci_95/1.96
  })
  
  
  #############################KEY PRESS##########################################
  # tracks the key inputs
  observeEvent(input$keys, {
    values$key_val = input$keys
  })
  
  #no key presses on home or results page
  observe({
    if(input$mainpage=="Results" || input$mainpage=="Home"){
      keys::pauseKey()
      shinyjs::show("footer_id")
    } else {
      keys::unpauseKey()
      shinyjs::hide("footer_id")
      
    }
  })
  
  ################ THIS IS WHRERE CAT STUFF GETS INCORPORATED ####################
  
  # observe event will take an action if an input changes.
  # here the next button or the enter key
  # This is where the app will interact with the -CAT-IRT algorithm
  observeEvent(input$enter_key, {
    # should the app show another item?
    # if the stopping choice is SEM,
    # check if the current sem is less than the desired precision
    # if its just a static number of items,
    # then check if this number has already been shown
    # returns TRUE or FALSE
    if(input$mainpage=="Practice"){
      # if slide 13, don't iterate, just show a message that says hit start...
      if(values$i == 13){
        showNotification("Press start to start testing", type = "message")
      }
      # essentially, if we're on the first two instruction slides,
      # don't require a 1 or 2..
      else if(values$i %in% c(1, 2)){
        shinyjs::runjs("document.getElementById('audio').play();")
        values$i = ifelse(values$i<13, values$i + 1, values$i)
        # otherwise, (i.e. not a practice slide)
      } else if(is.null(values$key_val)){ 
        # require a key press
        showNotification("Enter a score", type = "error")
        # Remove tank from practice items
      } else if (values$i == 5){
        shinyjs::runjs("document.getElementById('audio').play();")
        #js$click_sound()
        values$i = values$i + 2
        # as long as there's a response or it's an insturction slide...
      } else {
        shinyjs::runjs("document.getElementById('audio').play();")
        #js$click_sound()
        values$i = ifelse(values$i<13, values$i + 1, values$i)
      }
      values$key_val = NULL
      if (isTRUE(getOption("shiny.testmode"))) {
        shinyjs::reset("keys")
      }
    } else {
      # can you download data? yes - will calculate the data to go out. 
      values$downloadableData = T
      shinyjs::show("downloadData")
      
      another_item <- values$i<=values$test_length
      
      # require a key input response
      if(is.null(values$key_val)){ 
        showNotification("Enter a score", type = "error")
        # as long as there's a response or it's an insturction slide...
      } else if (another_item) {
        shinyjs::runjs("document.getElementById('audio').play();")
        # If a key press was detected, store it in our dataframe of items,
        # difficulty, discrimination etc...
        # 1 is incorrect (1) and 2 is correct (0).
        # IRT model reverses 1 and 0...
        values$item_difficulty[values$item_difficulty$slide_num==values$n,]$response <-
          ifelse(values$key_val == incorrect_key_response, 1,
                 ifelse(values$key_val == correct_key_response, 0, "NR"))

        # irt_function: takes in the current data, values$item_difficulty
        # which also includes the most recent response 
        # returns a list of 3 elements
        # element[[1]] is the new ability estimate
        # element[[2]] is a list of info returned by catR::nextSlide(), 
        # including $name, the name of the next item
        # element[[3]] returns the sem after re-estimating the model
        values$irt_out = irt_function(all_items = values$item_difficulty,
                                      IRT = values$IRT,
                                      test = input$numitems,
                                      exclude_eskimo = input$eskimo
        )
        
        # save info to the item_difficulty data_frame
        values$item_difficulty[values$item_difficulty$slide_num == values$n,][9:13] <-
          tibble::tibble(
            # what trial was the item presented
            order = values$i,
            # what was the key press
            key = values$key_val,
            # 1 is incorrect (1) and 2 is correct (0).
            # IRT model reverses 1 and 0...
            resp = ifelse(values$key_val == incorrect_key_response,
                          "incorrect",
                          ifelse(values$key_val == correct_key_response,
                                 "correct", "NR")
            ),
            # NEW ability estimate after model restimation
            ability = round(values$irt_out[[1]],3),
            # NEW sem 
            sem = round(values$irt_out[[3]], 3)
          )
        # pick the next slide using the output of the irt
        # conditional fixes a bug for the last item
        # if the test goes all the way to 175
        values$n = 
          if(isTruthy(values$IRT)){
            if(!is.na(values$irt_out[[2]][[1]])){
              values$item_difficulty[values$item_difficulty$target == values$irt_out[[2]]$name,]$slide_num
            } else {
              190
            }
          } else {
            values$irt_out[[2]][[2]]
          } 
        # iterate the order
        values$i = values$i + 1
      } 
      # prints to the console the last 5 items. DELETE FOR RELEASE
      # print(tail(values$item_difficulty %>% tidyr::drop_na(response) %>%
      #              dplyr::arrange(order), 5))
      # decides whether to cut to the results page or not!
      # returns TRUE or FALSE
      go_to_results <- if(is.na(values$n)){
        TRUE
      } else {
        values$i>values$test_length
      }
      # go to results if indicated
      if (isTruthy(go_to_results)){
        updateNavbarPage(session, "mainpage",
                         selected = "Results")
        shinyjs::show("report")
        shinyjs::hide("help")
      }
      values$key_val = NULL
      #for testing::
      if (isTRUE(getOption("shiny.testmode"))) {
        shinyjs::reset("keys")
      }
    }
    # don't run this on start up. 
  }, ignoreInit = T)
  ################################## REACTIVE DATA ############################### 
  # ------------------------------------------------------------------------------
  ################################################################################
  # holds the item-level responses. 
  results_data_long <- reactive({
    req(isTruthy(values$downloadableData))
    precision = paste0(input$numitems, " items")
    
    tmp = dplyr::bind_rows(values$item_difficulty) %>%
      dplyr::mutate(ci_95 = sem*1.96,
                    precision = precision,
                    name = input$name,
                    date = values$datetime,
                    notes = NA
      ) %>%
      dplyr::arrange(order)
    
    tmp$notes[[1]] = input$notes
    return(tmp)
  })
  
  # holds the mean accuracy
  results_data_summary <- reactive({
    req(input$mainpage=="Results")
    dplyr::bind_rows(values$item_difficulty) %>%
      # have to switch 0s and 1s because IRT is dumb. 
      tidyr::drop_na() %>%
      dplyr::mutate(response = as.numeric(ifelse(response == 0, 1, 0)),
                    ci_95 = sem*1.96) %>%
      dplyr::summarize(accuracy = mean(response)) %>%
      dplyr::pull(accuracy)
  })
  
  # tracks final irt data.
  irt_final <- reactive({
    req(input$mainpage=="Results")
    get_final_numbers(out = values$irt_out)
    
  })
  
  
  ################################## EXPORT TEST DATA ############################
  # ------------------------------------------------------------------------------
  ################################################################################
  # get data into strings for exporting...test only
  observeEvent(input$mainpage=="Results",{
    values$out_words <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                                dplyr::pull(target), collapse = "_")
    values$out_nums <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                               dplyr::pull(response), collapse = "_")
    values$out_ability <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                                  dplyr::pull(ability), collapse = "_")
    values$out_sem <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                              dplyr::pull(sem), collapse = "_")
    values$item_dif <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                               dplyr::pull(itemDifficulty), collapse = "_")
    values$disc <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                           dplyr::pull(discrimination), collapse = "_")
    values$key <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                          dplyr::pull(key), collapse = "_")
    values$order <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                            dplyr::pull(order), collapse = "_")
    values$item_number <- paste(results_data_long() %>% tidyr::drop_na(response) %>%
                                  dplyr::pull(item_number), collapse = "_")
  })
  # This makes the above data available after running unit test.
  exportTestValues(abil = values$out_ability,
                   sem = values$out_sem,
                   words = values$out_words,
                   responses = values$out_nums,
                   itemDifficulty = values$item_dif,
                   discrimination = values$disc,
                   key_press = values$key,
                   order = values$order,
                   item_number = values$item_number
  )

  ################################## DOWNLOAD ####################################  
  # ------------------------------------------------------------------------------
  ################################################################################

  # downloading output
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(gsub(" ", "-", input$name),
            as.character(Sys.Date()),
            "pnt.csv", sep = "_"
      )
    },
    content = function(file) {
      write.csv(get_data_for_download(dat = results_data_long(),
                                      in_progress = input$mainpage,
                                      current_item = values$irt_out[[2]]$name,
                                      IRT = values$IRT), file, row.names = FALSE)
    }
  )
  
  
  ################################## PLOT ######################################## 
  # ------------------------------------------------------------------------------
  ################################################################################
  # plot
  # output$plot <- renderPlot({# Fergadiotis, 2019
  #   req(irt_final())
  #   get_plot(values = values, irt_final = irt_final())
  # })
  
  output$text_summary <- renderUI({
    correct = sum(results_data_long()$resp=="correct", na.rm = T)
    error = sum(results_data_long()$resp=="incorrect", na.rm = T)
    acc = correct/(correct + error)
    return(
      p(paste0("The test accuracy was ", scales::percent(acc), "."))
    )
  })
  
  ################################## TABLE #######################################
  # ------------------------------------------------------------------------------
  ################################################################################
  # outputs a table of the item level responses
  output$results_table <- DT::renderDT({
    results_data_long() %>%
      tidyr::drop_na(response) %>%
      dplyr::select(order, target, resp, key, itemDifficulty, ability, sem)
  }, rownames = F,
  options = list(dom = "tp"))
  
  ################################## TAB UI ######################################
  # ------------------------------------------------------------------------------
  ################################################################################
  # this UI is on the server side so that it can be dynamic based. 
  # see scripts named tab_*.R 
  
  # this shows the practice slides
  output$practice_tab <- renderUI({
    practice_tab_div(values = values)
  })
  
  # UI for assessment slides
  output$slides_tab <- renderUI({
    slides_tab_div(values = values)
  })
  outputOptions(output, "slides_tab", suspendWhenHidden = FALSE)
  outputOptions(output, "results_table", suspendWhenHidden = FALSE)


  # end of app
}
