# ==============================================================================
# Module: R/plots.R
# Purpose: Interactive chart generation using Plotly and ggplot2 styling
# ==============================================================================

library(plotly)
library(ggplot2)
library(scales)

# Consistent Brand Color Palette
PALETTE_PRIMARY   <- "#2563eb" # Blue
PALETTE_SUCCESS   <- "#10b981" # Green
PALETTE_WARNING   <- "#f59e0b" # Amber
PALETTE_DANGER    <- "#ef4444" # Red
PALETTE_PURPLE    <- "#8b5cf6" # Indigo/Purple
PALETTE_COLORS    <- c("#2563eb", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6", "#06b6d4")

#' Interactive Monthly Sales & Profit Trend Chart
plot_sales_trend <- function(trend_df) {
  if (nrow(trend_df) == 0) return(plotly_empty(type = "scatter", mode = "lines"))
  
  fig <- plot_ly(data = trend_df, x = ~YearMonth) %>%
    add_trace(
      y = ~Total_Sales,
      name = "Revenue (INR)",
      type = "scatter",
      mode = "lines+markers",
      line = list(color = PALETTE_PRIMARY, width = 3),
      marker = list(size = 6, color = PALETTE_PRIMARY),
      hovertemplate = "<b>%{x}</b><br>Revenue: ₹%{y:,.0f}<extra></extra>"
    ) %>%
    add_trace(
      y = ~Total_Profit,
      name = "Profit (INR)",
      type = "scatter",
      mode = "lines+markers",
      line = list(color = PALETTE_SUCCESS, width = 2.5, dash = "dot"),
      marker = list(size = 5, color = PALETTE_SUCCESS),
      hovertemplate = "<b>%{x}</b><br>Profit: ₹%{y:,.0f}<extra></extra>"
    ) %>%
    layout(
      title = list(text = "<b>Sales & Profit Over Time</b>", font = list(size = 15)),
      xaxis = list(title = "Month", tickangle = -45, gridcolor = "#f1f5f9"),
      yaxis = list(title = "Amount (INR)", tickprefix = "₹", gridcolor = "#f1f5f9"),
      legend = list(orientation = "h", x = 0.1, y = 1.12),
      hovermode = "x unified",
      margin = list(t = 40, b = 60, l = 60, r = 20)
    )
  
  return(fig)
}

#' Interactive Category Performance Bar Chart
plot_category_bar <- function(cat_df) {
  if (nrow(cat_df) == 0) return(plotly_empty(type = "bar"))
  
  fig <- plot_ly(data = cat_df, x = ~reorder(Category, -Total_Sales), y = ~Total_Sales,
                 type = "bar", name = "Revenue",
                 marker = list(color = PALETTE_PRIMARY, opacity = 0.85),
                 hovertemplate = "<b>%{x}</b><br>Revenue: ₹%{y:,.0f}<extra></extra>") %>%
    add_trace(y = ~Total_Profit, name = "Profit",
              marker = list(color = PALETTE_SUCCESS, opacity = 0.85),
              hovertemplate = "<b>%{x}</b><br>Profit: ₹%{y:,.0f}<extra></extra>") %>%
    layout(
      title = list(text = "<b>Revenue vs Profit by Category</b>", font = list(size = 15)),
      barmode = "group",
      xaxis = list(title = ""),
      yaxis = list(title = "Amount (INR)", tickprefix = "₹", gridcolor = "#f1f5f9"),
      legend = list(orientation = "h", x = 0.3, y = 1.12),
      margin = list(t = 40, b = 40, l = 60, r = 20)
    )
  
  return(fig)
}

#' Regional Performance Chart
plot_regional_bar <- function(reg_df) {
  if (nrow(reg_df) == 0) return(plotly_empty(type = "bar"))
  
  fig <- plot_ly(data = reg_df, x = ~Total_Sales, y = ~reorder(Region, Total_Sales),
                 type = "bar", orientation = "h",
                 marker = list(color = PALETTE_PURPLE),
                 hovertemplate = "<b>Region: %{y}</b><br>Sales: ₹%{x:,.0f}<extra></extra>") %>%
    layout(
      title = list(text = "<b>Sales by Region</b>", font = list(size = 15)),
      xaxis = list(title = "Sales (INR)", tickprefix = "₹", gridcolor = "#f1f5f9"),
      yaxis = list(title = ""),
      margin = list(t = 40, b = 40, l = 80, r = 20)
    )
  
  return(fig)
}

#' Payment Method Share Donut Chart
plot_payment_pie <- function(df) {
  if (nrow(df) == 0) return(plotly_empty(type = "pie"))
  
  pay_summary <- df %>%
    dplyr::group_by(Payment_Method) %>%
    dplyr::summarise(Count = dplyr::n(), Volume = sum(Sales, na.rm = TRUE), .groups = "drop")
  
  fig <- plot_ly(pay_summary, labels = ~Payment_Method, values = ~Volume,
                 type = "pie", hole = 0.5,
                 marker = list(colors = PALETTE_COLORS),
                 textinfo = "label+percent",
                 hovertemplate = "<b>%{label}</b><br>Revenue: ₹%{value:,.0f}<br>Share: %{percent}<extra></extra>") %>%
    layout(
      title = list(text = "<b>Payment Methods Share</b>", font = list(size = 15)),
      showlegend = FALSE,
      margin = list(t = 40, b = 20, l = 20, r = 20)
    )
  
  return(fig)
}

#' Top 10 Best-Selling Products Chart
plot_top_products <- function(top_df) {
  if (nrow(top_df) == 0) return(plotly_empty(type = "bar"))
  
  fig <- plot_ly(data = top_df, x = ~Total_Sales, y = ~reorder(Product_Name, Total_Sales),
                 type = "bar", orientation = "h",
                 marker = list(color = PALETTE_PRIMARY,
                               line = list(color = "#1d4ed8", width = 1)),
                 hovertemplate = "<b>%{y}</b><br>Sales: ₹%{x:,.0f}<br>Units: %{customdata[0]}<extra></extra>",
                 customdata = ~Total_Units) %>%
    layout(
      title = list(text = "<b>Top 10 Best-Selling Products</b>", font = list(size = 15)),
      xaxis = list(title = "Total Sales (INR)", tickprefix = "₹", gridcolor = "#f1f5f9"),
      yaxis = list(title = ""),
      margin = list(t = 40, b = 40, l = 160, r = 20)
    )
  
  return(fig)
}

#' Profitability Scatter: Discount vs Profit Margin
plot_profit_scatter <- function(df) {
  if (nrow(df) == 0) return(plotly_empty(type = "scatter"))
  
  # Sample if too large for responsive scatter plot
  plot_data <- if (nrow(df) > 1000) df[sample(nrow(df), 1000), ] else df
  
  fig <- plot_ly(
    data = plot_data,
    x = ~Discount * 100,
    y = ~Profit_Margin,
    color = ~Category,
    colors = PALETTE_COLORS,
    type = "scatter",
    mode = "markers",
    marker = list(size = 7, opacity = 0.7),
    hovertemplate = paste(
      "<b>%{text}</b><br>",
      "Discount: %{x:.1f}%<br>",
      "Margin: %{y:.1f}%<br>",
      "Sales: ₹%{customdata:,.0f}<extra></extra>"
    ),
    text = ~Product_Name,
    customdata = ~Sales
  ) %>%
    layout(
      title = list(text = "<b>Profit Margin vs Discount Rate</b>", font = list(size = 15)),
      xaxis = list(title = "Discount Applied (%)", gridcolor = "#f1f5f9"),
      yaxis = list(title = "Profit Margin (%)", gridcolor = "#f1f5f9", zerolinecolor = "#cbd5e1"),
      legend = list(orientation = "h", x = 0.05, y = 1.15),
      margin = list(t = 50, b = 40, l = 50, r = 20)
    )
  
  return(fig)
}

#' Customer Segment Comparison Chart
plot_segment_comparison <- function(df) {
  if (nrow(df) == 0) return(plotly_empty(type = "bar"))
  
  seg_df <- df %>%
    dplyr::group_by(Customer_Segment) %>%
    dplyr::summarise(
      Revenue = sum(Sales, na.rm = TRUE),
      Profit  = sum(Profit, na.rm = TRUE),
      Orders  = dplyr::n(),
      .groups = "drop"
    )
  
  fig <- plot_ly(data = seg_df, x = ~Customer_Segment, y = ~Revenue,
                 type = "bar", name = "Revenue",
                 marker = list(color = "#3b82f6")) %>%
    add_trace(y = ~Profit, name = "Profit",
              marker = list(color = "#10b981")) %>%
    layout(
      title = list(text = "<b>Performance by Customer Segment</b>", font = list(size = 15)),
      barmode = "group",
      xaxis = list(title = "Customer Segment"),
      yaxis = list(title = "INR", tickprefix = "₹", gridcolor = "#f1f5f9"),
      legend = list(orientation = "h", x = 0.25, y = 1.12),
      margin = list(t = 40, b = 40, l = 60, r = 20)
    )
  
  return(fig)
}

#' Simulation Bar Comparison Chart (Original vs Simulated)
plot_simulation_comparison <- function(sim_res) {
  if (is.null(sim_res)) return(plotly_empty(type = "bar"))
  
  comp_df <- data.frame(
    Scenario = c("Current (Actual)", "Simulated Scenario"),
    Revenue = c(sim_res$original$revenue, sim_res$simulated$revenue),
    Profit  = c(sim_res$original$profit, sim_res$simulated$profit)
  )
  
  fig <- plot_ly(data = comp_df, x = ~Scenario, y = ~Revenue,
                 type = "bar", name = "Revenue",
                 marker = list(color = PALETTE_PRIMARY)) %>%
    add_trace(y = ~Profit, name = "Profit",
              marker = list(color = PALETTE_SUCCESS)) %>%
    layout(
      title = list(text = "<b>Comparison: Actual vs Simulated Outcome</b>", font = list(size = 15)),
      barmode = "group",
      xaxis = list(title = ""),
      yaxis = list(title = "INR", tickprefix = "₹", gridcolor = "#f1f5f9"),
      legend = list(orientation = "h", x = 0.25, y = 1.12),
      margin = list(t = 40, b = 40, l = 60, r = 20)
    )
  
  return(fig)
}

