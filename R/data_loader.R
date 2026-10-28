# ==============================================================================
# Module: R/data_loader.R
# Purpose: Backend data loading, validation, and transformation pipeline
# ==============================================================================

#' Load and parse sales data from CSV
#' @param filepath Path to the CSV file
#' @return A cleaned and formatted data.frame / tibble
load_sales_data <- function(filepath = "data/sales_data.csv") {
  if (!file.exists(filepath)) {
    stop(sprintf("Data file not found at: %s", filepath))
  }
  
  df <- read.csv(filepath, stringsAsFactors = FALSE)
  df <- clean_sales_data(df)
  return(df)
}

#' Clean and transform sales data with consistent data types
#' @param df Raw data frame
#' @return Processed data frame
clean_sales_data <- function(df) {
  # Ensure proper Date formatting
  if ("Order_Date" %in% colnames(df)) {
    df$Order_Date <- as.Date(df$Order_Date)
    df$Year <- lubridate::year(df$Order_Date)
    df$Month <- lubridate::month(df$Order_Date, label = TRUE, abbr = TRUE)
    df$YearMonth <- format(df$Order_Date, "%Y-%m")
  }
  
  # Ensure numeric columns
  num_cols <- c("Unit_Cost", "Unit_Price", "Quantity", "Discount", 
                "Gross_Sales", "Discount_Amount", "Sales", "Total_Cost", 
                "Profit", "Profit_Margin")
  for (col in num_cols) {
    if (col %in% colnames(df)) {
      df[[col]] <- as.numeric(df[[col]])
    }
  }
  
  # Ensure factors for key categorical variables
  cat_cols <- c("Customer_Segment", "Region", "Category", "Sub_Category", "Payment_Method")
  for (col in cat_cols) {
    if (col %in% colnames(df)) {
      df[[col]] <- as.factor(df[[col]])
    }
  }
  
  # Recalculate profit status for easy categorization
  df$Profit_Status <- ifelse(df$Profit >= 0, "Profitable", "Loss Making")
  
  return(df)
}

#' Validate uploaded dataset structure
#' @param df Data frame to check
#' @return List with isValid (logical) and message (character)
validate_sales_data <- function(df) {
  required_cols <- c("Order_Date", "Sales", "Profit", "Category", "Region", "Quantity")
  missing_cols <- setdiff(required_cols, colnames(df))
  
  if (length(missing_cols) > 0) {
    return(list(
      isValid = FALSE,
      message = paste("Missing required columns:", paste(missing_cols, collapse = ", "))
    ))
  }
  
  return(list(
    isValid = TRUE,
    message = "Dataset validated successfully."
  ))
}

