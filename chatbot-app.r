# Load R packages
renv::load()

library(shiny)
library(shinythemes)
library(ollamar)
library(RSQLite)

# Initialize SQLite connection
db_path <- "chatbot.db"
conn <- dbConnect(SQLite(), db_path)

# Initialization
test_connection()
chat_model <- "llama3.1"

# Create a table if it doesn't exist
dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS chat_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    role TEXT NOT NULL,
    message TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
  )
")

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
  
  # Function to append messages to the database
  store_message <- function(role, message) {
    dbExecute(conn, "INSERT INTO chat_log (role, message) VALUES (?, ?)", params = list(role, message))
  }
  
  # Fetch and update chat history from the database
  update_chat <- function() {
    chat_log <- dbGetQuery(conn, "SELECT role, message FROM chat_log ORDER BY timestamp ASC")
    formatted_chat <- paste0(chat_log$role, ": ", chat_log$message, collapse = "\n")
    chat(formatted_chat)
  }
  
  
  # Process user input and bot response
  observeEvent(input$send, {
    user_message <- input$user_input
    if (user_message == "") return()  # Ignore empty messages
    
    curr_time = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    print(paste("[",curr_time,"]", "User message:", user_message))
    
    # Store and update chat with user's message
    store_message("User", user_message)
    update_chat()
    updateTextInput(session, "user_input", value = "")  # Clear input field
    
    # Generate bot response
    bot_reply <- generate(chat_model, user_message, output = "text")
    curr_time = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    print(paste("[",curr_time,"]", "Bot response:", bot_reply))
    store_message("Bot", bot_reply)
    update_chat()
  })
  
  output$txtout <- renderText({
    chat()
  })
  
  # Initialize chat history when app starts
  update_chat()
}


# Disconnect from database when the app stops
onStop(function() {
  dbDisconnect(conn)
})


# Create Shiny object
shinyApp(ui = ui, server = server)