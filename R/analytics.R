# ==============================================================================
# Module: R/analytics.R
# Purpose: Backend analytical business logic, aggregations, and calculations
# ==============================================================================

library(dplyr)

#' Compute high-level KPI summary cards metrics
#' @param df Filtered sales data frame
#' @return Named list of KPI metrics
compute_kpi_summary <- function(df) {
  if (nrow(df) == 0) {
    return(list(
      total_revenue = 0,
      total_profit = 0,
      profit_margin = 0,
      total_orders = 0,
      total_units = 0,
      avg_order_val = 0
    ))
  }
  
  total_revenue <- sum(df$Sales, na.rm = TRUE)
  total_profit  <- sum(df$Profit, na.rm = TRUE)
  profit_margin <- ifelse(total_revenue > 0, (total_profit / total_revenue) * 100, 0)
  total_orders  <- nrow(df)
  total_units   <- sum(df$Quantity, na.rm = TRUE)
  avg_order_val <- ifelse(total_orders > 0, total_revenue / total_orders, 0)
  
  return(list(
    total_revenue = total_revenue,
    total_profit  = total_profit,
    profit_margin = round(profit_margin, 2),
    total_orders  = total_orders,
    total_units   = total_units,
    avg_order_val = round(avg_order_val, 2)
  ))
}

#' Aggregate monthly sales and profit for time-series trend analysis
#' @param df Filtered sales data frame
#' @return Aggregated data frame grouped by YearMonth
aggregate_monthly_trend <- function(df) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(YearMonth) %>%
    dplyr::summarise(
      Total_Sales  = sum(Sales, na.rm = TRUE),
      Total_Profit = sum(Profit, na.rm = TRUE),
      Orders_Count = dplyr::n(),
      Avg_Order_Value = mean(Sales, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::arrange(YearMonth)
}

#' Aggregate sales and profit by Product Category
#' @param df Filtered sales data frame
#' @return Summary by Category
aggregate_category_summary <- function(df) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(Category) %>%
    dplyr::summarise(
      Total_Sales  = sum(Sales, na.rm = TRUE),
      Total_Profit = sum(Profit, na.rm = TRUE),
      Units_Sold   = sum(Quantity, na.rm = TRUE),
      Profit_Margin = round((sum(Profit, na.rm = TRUE) / sum(Sales, na.rm = TRUE)) * 100, 2),
      .groups = "drop"
    ) %>%
    dplyr::arrange(desc(Total_Sales))
}

#' Aggregate sales by Sub-Category
#' @param df Filtered sales data frame
#' @return Summary by Sub-Category
aggregate_subcategory_summary <- function(df) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(Category, Sub_Category) %>%
    dplyr::summarise(
      Total_Sales  = sum(Sales, na.rm = TRUE),
      Total_Profit = sum(Profit, na.rm = TRUE),
      Units_Sold   = sum(Quantity, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::arrange(desc(Total_Sales))
}

#' Aggregate sales and profit by Region
#' @param df Filtered sales data frame
#' @return Summary by Region
aggregate_regional_summary <- function(df) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(Region) %>%
    dplyr::summarise(
      Total_Sales  = sum(Sales, na.rm = TRUE),
      Total_Profit = sum(Profit, na.rm = TRUE),
      Orders       = dplyr::n(),
      Profit_Margin = round((sum(Profit, na.rm = TRUE) / sum(Sales, na.rm = TRUE)) * 100, 2),
      .groups = "drop"
    ) %>%
    dplyr::arrange(desc(Total_Sales))
}

#' Get Top N best selling products
#' @param df Filtered sales data frame
#' @param n Number of products to return
#' @return Ranked data frame
get_top_products <- function(df, n = 10) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(Product_Name, Category) %>%
    dplyr::summarise(
      Total_Sales  = sum(Sales, na.rm = TRUE),
      Total_Profit = sum(Profit, na.rm = TRUE),
      Total_Units  = sum(Quantity, na.rm = TRUE),
      Avg_Discount = round(mean(Discount, na.rm = TRUE) * 100, 1),
      .groups = "drop"
    ) %>%
    dplyr::arrange(desc(Total_Sales)) %>%
    head(n)
}

#' Get Top N customers by revenue
#' @param df Filtered sales data frame
#' @param n Number of customers to return
#' @return Ranked customer data frame
get_top_customers <- function(df, n = 10) {
  if (nrow(df) == 0) return(data.frame())
  
  df %>%
    dplyr::group_by(Customer_ID, Customer_Name, Customer_Segment) %>%
    dplyr::summarise(
      Total_Spent  = sum(Sales, na.rm = TRUE),
      Total_Orders = dplyr::n(),
      Total_Profit = sum(Profit, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::arrange(desc(Total_Spent)) %>%
    head(n)
}

#' What-if Scenario Simulator: Simulate impact of price change and volume change
#' @param df Filtered dataset
#' @param discount_shift_pct Shift in discount percentage points (e.g., +5 or -5)
#' @param volume_growth_pct Growth in units sold percentage (e.g., +10%)
#' @return List with original and simulated metrics
simulate_scenario <- function(df, discount_shift_pct = 0, volume_growth_pct = 0) {
  if (nrow(df) == 0) return(NULL)
  
  orig_revenue <- sum(df$Sales, na.rm = TRUE)
  orig_profit  <- sum(df$Profit, na.rm = TRUE)
  orig_margin  <- (orig_profit / orig_revenue) * 100
  
  vol_multiplier <- 1 + (volume_growth_pct / 100)
  
  # New simulated values
  sim_quantity <- df$Quantity * vol_multiplier
  sim_discount <- pmax(0, pmin(0.50, df$Discount + (discount_shift_pct / 100)))
  
  sim_gross <- df$Unit_Price * sim_quantity
  sim_sales <- sim_gross * (1 - sim_discount)
  sim_cost  <- df$Unit_Cost * sim_quantity
  sim_profit <- sim_sales - sim_cost
  
  new_revenue <- sum(sim_sales, na.rm = TRUE)
  new_profit  <- sum(sim_profit, na.rm = TRUE)
  new_margin  <- (new_profit / new_revenue) * 100
  
  return(list(
    original = list(
      revenue = orig_revenue,
      profit  = orig_profit,
      margin  = round(orig_margin, 2)
    ),
    simulated = list(
      revenue = new_revenue,
      profit  = new_profit,
      margin  = round(new_margin, 2),
      delta_revenue = new_revenue - orig_revenue,
      delta_profit  = new_profit - orig_profit,
      delta_revenue_pct = round(((new_revenue - orig_revenue) / orig_revenue) * 100, 2),
      delta_profit_pct  = round(((new_profit - orig_profit) / orig_profit) * 100, 2)
    )
  ))
}

