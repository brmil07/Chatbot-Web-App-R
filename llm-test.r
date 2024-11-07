renv::install("dplyr")
renv::install("httr2")
renv::install("devtools")
renv::install("tidyverse")
renv::install("shiny")
renv::install("shinythemes")
renv::install("pacman")

devtools::install_github("hauselin/ollamar")
library(ollamar)
test_connection()

list_models()

list_models <- list_models()
print(list_models[1][1,])
print(list_models[1][2,])
print(c(list_models[1][1,], list_models[1][2,]))

generate("llama3.1", "How are you today?", output="text", stream=TRUE) 

cat("\014")
