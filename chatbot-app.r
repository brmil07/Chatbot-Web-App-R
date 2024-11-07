# Load R packages
renv::load()

library(shiny)
library(shinythemes)
library(ollamar)


# Define UI
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Chatbot Example"),
  sidebarLayout(
    sidebarPanel(
      textInput("user_input", "Your Message:", ""),
      actionButton("send", "Send"),
      br(), 
      h5("Conversation History"), 
      uiOutput("chat_history")
    ),
    mainPanel(
      h4("Chatbot Model:"),
      verbatimTextOutput("response", placeholder = TRUE),
      
      h4("Combined Input:"), 
      verbatimTextOutput("txtout", placeholder = TRUE)
    )
  )
)


# Define server function  
server <- function(input, output) {
  test_connection()
  chat_model <- "llama3.1"
  
  models <- list_models()
  model_name <- c(models[1][1,], models[1][2,])
  output$response <- renderText({ model_name })
  
  
  observeEvent(input$send, {
    user_message <- input$user_input
    print(paste("User message:", user_message))
    
    bot_response <- generate(chat_model, user_message, output="text", stream=TRUE)
    print(paste("Bot response:", bot_response))
    
    output$txtout <- renderText({ bot_response })
  })
  output$txtout <- renderText({
    paste( input$txt1, input$txt2, sep = " " )
  })
}


# Create Shiny object
shinyApp(ui = ui, server = server)