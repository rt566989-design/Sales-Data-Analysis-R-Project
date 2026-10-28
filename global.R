# ==============================================================================
# File: global.R
# Purpose: Global configurations, environment initialization, and dataset loading
# ==============================================================================

# Core Libraries
suppressPackageStartupMessages({
  library(shiny)
  library(bslib)
  library(dplyr)
  library(plotly)
  library(DT)
  library(lubridate)
  library(scales)
})

# Source Backend Modules
source("R/data_loader.R")
source("R/analytics.R")
source("R/plots.R")

# Load Default Dataset
DEFAULT_DATA_PATH <- "data/sales_data.csv"

if (file.exists(DEFAULT_DATA_PATH)) {
  initial_sales_data <- load_sales_data(DEFAULT_DATA_PATH)
} else {
  # Fallback generation if data file does not exist
  source("data/generate_data.R")
  initial_sales_data <- load_sales_data(DEFAULT_DATA_PATH)
}

# Unique Choice Lists for UI Selectors
ALL_REGIONS     <- sort(unique(as.character(initial_sales_data$Region)))
ALL_CATEGORIES  <- sort(unique(as.character(initial_sales_data$Category)))
ALL_SEGMENTS    <- sort(unique(as.character(initial_sales_data$Customer_Segment)))
ALL_PAYMENTS    <- sort(unique(as.character(initial_sales_data$Payment_Method)))
MIN_DATE        <- min(initial_sales_data$Order_Date, na.rm = TRUE)
MAX_DATE        <- max(initial_sales_data$Order_Date, na.rm = TRUE)

# Format currency helper
format_inr <- function(x) {
  paste0("₹", format(round(x, 0), big.mark = ",", scientific = FALSE))
}

