# Load R packages
renv::load()

library(shiny)
library(shinythemes)
library(ollamar)

# Initialization
test_connection()
chat_model <- "llama3.1"

# Define UI
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Chatbot Example"),
  sidebarLayout(
    sidebarPanel(
      textInput("user_input", "Your Message:", ""),
      actionButton("send", "Send")
    ),
    mainPanel(
      h4("Chatbox:"), 
      verbatimTextOutput("txtout", placeholder = TRUE)
    )
  )
)


# Define server function  
server <- function(input, output, session) {
  models <- list_models()
  model_name <- c(models[1][1,], models[1][2,])
  
  chat <- reactiveVal("")
  bot_response <- reactiveVal("")
  
  observeEvent(input$send, {
    input_msg <- input$user_input
    user_message <- paste0("User: ", input$user_input)
    updated_chat <- paste(chat(), user_message, sep = "\n")
    chat(updated_chat)
    # clear input field
    updateTextInput(session, "user_input", value = "")
    print(paste("User message:", input_msg))
    
    # Generate bot response
    bot_reply <- generate(chat_model, input_msg, output = "text")
    bot_message <- paste0("Bot: ", bot_reply)
    updated_chat <- paste(chat(), bot_message, sep = "\n")
    chat(updated_chat)
    print(paste("Bot response:", bot_reply))
  })
  
  output$txtout <- renderText({
    chat()
  })
}


# Create Shiny object
shinyApp(ui = ui, server = server)