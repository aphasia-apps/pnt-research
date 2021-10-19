#' results tab
#' @export
results_tab_div <- function(){
  fluidRow(
  column(width = 8,offset = 2,
         tabsetPanel(
           tabPanel("Test Completed",
             div(align = "center",
                 br(),br(), br(), br(), br(), br(),
               h1("Test Completed!"),br(),br(),
                 div(style = "font-size:6em;",
                    icon("thumbs-up")
                 )
               )
           ),
           tabPanel("Results",
             div(
               div(align = "center", br(), 
                uiOutput("text_summary")
               ),
               DT::DTOutput("results_table"),
              )
           )
         )
      )
  )
}