# ==============================================================================
# File: app.R
# Purpose: Main application entry point for Shiny
# ==============================================================================

source("global.R")
source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)

