#' Intro doc
#' @export
intro_tab_div <- function(){
  
  column(width = 12,
         fluidRow(
           column(width = 12,
              tabsetPanel(type="hidden", id = "glide",
                  tabPanelBody(value = "glide0",
                               fluidRow(
                                 column(align = "center", width = 12,
                                        div(
                                          style = "width:50%;",
                                          div(
                                            h5(
                                              "Welcome to the computer adaptive version of the",
                                              tags$a(href = "https://mrri.org/philadelphia-naming-test/",
                                                     HTML("Philadelphia&nbsp;Naming&nbsp;Test."),
                                                     target = "_blank", style = "text-decoration: underline;cursor: pointer;")
                                            )
                                          )
                                        )
                                 )
                               ),br(),
                               fluidRow(
                                   column(width = 6, offset = 3,
                                          includeMarkdown(
                                                system.file("app/www/intro.md",
                                                 package = "pnt.research")
                                   ),
                                   div(align="center",
                                       actionButton("administer_test", "Administer PNT"),
                                   ))
                               )
                  ),
                  tabPanelBody(value = "glide1",
                           div(align = "center",
                               div(style="display: inline-block; text-align: left;",
                                   h5("Input participant information"), br(),
                                   textInput("name", "Enter a Name"),
                                   textInput("notes", "Enter any notes"),
                                   h5("Choose test options"), br(),
                                   ### Use this to set how many items to run.
                                   radioButtons(inputId = "numitems",
                                                label = "Number of items (10 is for testing)",
                                                choices = c("10-item PNT-CAT" = "10",
                                                            "30-item PNT-CAT" = "30",
                                                            "60-item PNT-CAT" = "60",
                                                            "175-item full PNT" = "175"),
                                                selected = "10",
                                                inline = F),
                                   # randomize PNT order if doing the full 175 item test?
                                   shinyjs::hidden(
                                     checkboxInput("random",
                                                   "Random Order (175 only)",
                                                   value = F)
                                   ),
                                   shinyjs::hidden(
                                     checkboxInput("eskimo",
                                                   'Exclude item "Eskimo"',
                                                   value = T
                                     )
                                   ),
                                   checkboxInput("sound",
                                                 "Mute sound",
                                                 value = F),
                                   div(align = "center",
                                       actionButton("glide_back1", "Back"),
                                       actionButton("glide_next2", "Next")
                                   )
                                   
                               )
                           )
                  ),
                  tabPanelBody(value = "glide3",
                           div(align = "center",
                               div(style="display: inline-block; text-align: left;",
                                   h5("Instructions:"),
                                   tags$ul(
                                     tags$li("Click Start Practice to get started"),
                                     tags$li("Press Enter or Space-bar to advance the screen"),
                                     tags$li("Press 1 for incorrect and 2 for correct"),
                                     tags$li("A 1 or 2 will appear in the top-right of the screen to show the key entered."),
                                     tags$li("Remember to score the first complete response"),
                                     tags$li("Press Enter or Space-bar to advance the screen"),
                                     tags$li("Press Esc. to end the test."),
                                   ),br(),
                                   # start!
                                   div(align = "center",
                                       actionButton("glide_back2", "Back"),
                                       actionButton("start_practice",
                                                    "Start Practice")
                                   )
                               )
                           )
                  )
              )

           )
         )
  )
}


