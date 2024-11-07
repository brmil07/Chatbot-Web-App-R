# Load R packages
library(pacman) 
pacman::p_load(pacman, shiny, shinythemes) 

# Define UI
ui <- fluidPage(theme = shinytheme("cerulean"),
                navbarPage(
                  theme = "cerulean", 
                  "My first webapp",
                  tabPanel("Navbar 1",
                           sidebarPanel(
                             tags$h3("Input:"),
                             textInput("txt1", "Given Name:", ""),
                             textInput("txt2", "Surname:", ""),
                           ),
                           mainPanel(h1("Header 1"),
                                     h4("Output 1"),
                                     verbatimTextOutput("txtout"),
                           )
                  ),
                  tabPanel("Navbar 2", "This bar is blank"),
                )
)


# Define server function  
server <- function(input, output) {
  
  output$txtout <- renderText({
    paste( input$txt1, input$txt2, sep = " " )
  })
}


# Create Shiny object
shinyApp(ui = ui, server = server)