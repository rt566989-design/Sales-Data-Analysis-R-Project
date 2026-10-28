# ==============================================================================
# Script: run_app.R
# Purpose: Start the Shiny Sales Data Analysis Application in Web Browser
# ==============================================================================

cat("\n========================================================\n")
cat("   SalesPulse Analytics - Sales Data Analysis Mini Project\n")
cat("========================================================\n\n")

# Required Packages Check
required_pkgs <- c("shiny", "bslib", "dplyr", "plotly", "DT", "lubridate", "scales")
missing_pkgs  <- required_pkgs[!required_pkgs %in% rownames(installed.packages())]

if (length(missing_pkgs) > 0) {
  cat("Installing missing packages:", paste(missing_pkgs, collapse = ", "), "\n")
  install.packages(missing_pkgs, repos = "https://cloud.r-project.org")
}

cat("Initializing application and starting local server...\n")
cat("Press Ctrl + C or Esc in the console to stop the app.\n\n")

library(shiny)

# Launch Shiny app with automatic browser opening
shiny::runApp(
  appDir = ".",
  launch.browser = TRUE,
  host = "127.0.0.1",
  port = 7860
)

