# ==============================================================================
# File: server.R
# Purpose: Backend Server Logic - Reactive Data Pipeline, Aggregations & Handlers
# ==============================================================================

library(shiny)
library(dplyr)
library(plotly)
library(DT)

server <- function(input, output, session) {
  
  # ----------------------------------------------------------------------------
  # 1. REACTIVE DATA SOURCE MANAGEMENT
  # ----------------------------------------------------------------------------
  # Holds either the default dataset or the user-uploaded dataset
  master_data <- reactiveVal(initial_sales_data)
  
  # Handle custom CSV upload
  observeEvent(input$user_csv, {
    req(input$user_csv)
    tryCatch({
      uploaded_df <- read.csv(input$user_csv$datapath, stringsAsFactors = FALSE)
      val <- validate_sales_data(uploaded_df)
      if (val$isValid) {
        cleaned <- clean_sales_data(uploaded_df)
        master_data(cleaned)
        
        # Dynamically update filter input limits
        updateDateRangeInput(
          session, "filter_dates",
          start = min(cleaned$Order_Date, na.rm = TRUE),
          end   = max(cleaned$Order_Date, na.rm = TRUE),
          min   = min(cleaned$Order_Date, na.rm = TRUE),
          max   = max(cleaned$Order_Date, na.rm = TRUE)
        )
        
        output$upload_status_ui <- renderUI({
          tags$div(class = "text-success small mt-1", icon("check-circle"), " Uploaded successfully!")
        })
      } else {
        output$upload_status_ui <- renderUI({
          tags$div(class = "text-danger small mt-1", icon("exclamation-triangle"), val$message)
        })
      }
    }, error = function(e) {
      output$upload_status_ui <- renderUI({
        tags$div(class = "text-danger small mt-1", icon("times-circle"), paste("Error:", e$message))
      })
    })
  })
  
  # Reset filters action
  observeEvent(input$btn_reset_filters, {
    df <- master_data()
    updateDateRangeInput(
      session, "filter_dates",
      start = min(df$Order_Date, na.rm = TRUE),
      end   = max(df$Order_Date, na.rm = TRUE)
    )
    updateSelectizeInput(session, "filter_region", selected = sort(unique(as.character(df$Region))))
    updateSelectizeInput(session, "filter_category", selected = sort(unique(as.character(df$Category))))
    updateSelectizeInput(session, "filter_segment", selected = sort(unique(as.character(df$Customer_Segment))))
    updateSelectizeInput(session, "filter_payment", selected = sort(unique(as.character(df$Payment_Method))))
  })
  
  # ----------------------------------------------------------------------------
  # 2. FILTERED REACTIVE DATA PIPELINE
  # ----------------------------------------------------------------------------
  filtered_df <- reactive({
    df <- master_data()
    req(nrow(df) > 0)
    
    # Filter Date Range
    if (!is.null(input$filter_dates) && length(input$filter_dates) == 2) {
      df <- df %>% filter(Order_Date >= input$filter_dates[1] & Order_Date <= input$filter_dates[2])
    }
    
    # Filter Region
    if (!is.null(input$filter_region) && length(input$filter_region) > 0) {
      df <- df %>% filter(Region %in% input$filter_region)
    }
    
    # Filter Category
    if (!is.null(input$filter_category) && length(input$filter_category) > 0) {
      df <- df %>% filter(Category %in% input$filter_category)
    }
    
    # Filter Segment
    if (!is.null(input$filter_segment) && length(input$filter_segment) > 0) {
      df <- df %>% filter(Customer_Segment %in% input$filter_segment)
    }
    
    # Filter Payment Method
    if (!is.null(input$filter_payment) && length(input$filter_payment) > 0) {
      df <- df %>% filter(Payment_Method %in% input$filter_payment)
    }
    
    return(df)
  })
  
  # KPI Aggregation
  kpi_summary <- reactive({
    compute_kpi_summary(filtered_df())
  })
  
  # ----------------------------------------------------------------------------
  # 3. KPI VALUE BOX RENDERERS
  # ----------------------------------------------------------------------------
  output$kpi_card_revenue <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-blue",
      tags$div(class = "kpi-title", icon("wallet"), " Total Net Revenue"),
      tags$div(class = "kpi-value", format_inr(kpi$total_revenue)),
      tags$div(class = "kpi-subtitle", "Gross sales minus promotional discounts")
    )
  })
  
  output$kpi_card_profit <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-green",
      tags$div(class = "kpi-title", icon("chart-line"), " Total Net Profit"),
      tags$div(class = "kpi-value", format_inr(kpi$total_profit)),
      tags$div(class = "kpi-subtitle", "Net earnings after cost of goods sold")
    )
  })
  
  output$kpi_card_margin <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-purple",
      tags$div(class = "kpi-title", icon("percentage"), " Overall Profit Margin"),
      tags$div(class = "kpi-value", paste0(kpi$profit_margin, "%")),
      tags$div(class = "kpi-subtitle", "Return on sales percentage")
    )
  })
  
  output$kpi_card_orders <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-teal",
      tags$div(class = "kpi-title", icon("shopping-bag"), " Total Orders"),
      tags$div(class = "kpi-value", format(kpi$total_orders, big.mark = ",")),
      tags$div(class = "kpi-subtitle", "Total transactions recorded")
    )
  })
  
  output$kpi_card_units <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-amber",
      tags$div(class = "kpi-title", icon("cubes"), " Total Units Sold"),
      tags$div(class = "kpi-value", format(kpi$total_units, big.mark = ",")),
      tags$div(class = "kpi-subtitle", "Quantity of items delivered")
    )
  })
  
  output$kpi_card_aov <- renderUI({
    kpi <- kpi_summary()
    tags$div(
      class = "kpi-card kpi-blue",
      tags$div(class = "kpi-title", icon("receipt"), " Avg Order Value (AOV)"),
      tags$div(class = "kpi-value", format_inr(kpi$avg_order_val)),
      tags$div(class = "kpi-subtitle", "Average revenue per order transaction")
    )
  })
  
  # ----------------------------------------------------------------------------
  # 4. OVERVIEW CHARTS
  # ----------------------------------------------------------------------------
  output$plot_trend <- renderPlotly({
    trend_df <- aggregate_monthly_trend(filtered_df())
    plot_sales_trend(trend_df)
  })
  
  output$plot_payment <- renderPlotly({
    plot_payment_pie(filtered_df())
  })
  
  output$plot_category <- renderPlotly({
    cat_df <- aggregate_category_summary(filtered_df())
    plot_category_bar(cat_df)
  })
  
  output$plot_regional <- renderPlotly({
    reg_df <- aggregate_regional_summary(filtered_df())
    plot_regional_bar(reg_df)
  })
  
  # ----------------------------------------------------------------------------
  # 5. PRODUCT & CATEGORY ANALYTICS
  # ----------------------------------------------------------------------------
  output$plot_top_products_bar <- renderPlotly({
    top_prod <- get_top_products(filtered_df(), n = 10)
    plot_top_products(top_prod)
  })
  
  output$plot_scatter_margin <- renderPlotly({
    plot_profit_scatter(filtered_df())
  })
  
  output$table_subcategory <- renderDT({
    sub_df <- aggregate_subcategory_summary(filtered_df())
    if (nrow(sub_df) == 0) return(datatable(data.frame(Message = "No data available.")))
    
    datatable(
      sub_df %>%
        mutate(
          Total_Sales = paste0("₹", format(round(Total_Sales, 0), big.mark = ",")),
          Total_Profit = paste0("₹", format(round(Total_Profit, 0), big.mark = ",")),
          Units_Sold = format(Units_Sold, big.mark = ",")
        ),
      options = list(pageLength = 8, dom = 'ftp', autoWidth = TRUE),
      rownames = FALSE,
      class = "stripe hover compact"
    )
  })
  
  # ----------------------------------------------------------------------------
  # 6. CUSTOMER & REGIONAL ANALYTICS
  # ----------------------------------------------------------------------------
  output$plot_segment <- renderPlotly({
    plot_segment_comparison(filtered_df())
  })
  
  output$table_top_customers <- renderDT({
    top_cust <- get_top_customers(filtered_df(), n = 10)
    if (nrow(top_cust) == 0) return(datatable(data.frame(Message = "No data available.")))
    
    datatable(
      top_cust %>%
        mutate(
          Total_Spent = paste0("₹", format(round(Total_Spent, 0), big.mark = ",")),
          Total_Profit = paste0("₹", format(round(Total_Profit, 0), big.mark = ","))
        ),
      colnames = c("Customer ID", "Customer Name", "Segment", "Total Spend", "Orders", "Net Profit Generated"),
      options = list(pageLength = 6, dom = 't', autoWidth = TRUE),
      rownames = FALSE,
      class = "stripe compact"
    )
  })
  
  output$table_regional_summary <- renderDT({
    reg_df <- aggregate_regional_summary(filtered_df())
    if (nrow(reg_df) == 0) return(datatable(data.frame(Message = "No data available.")))
    
    datatable(
      reg_df %>%
        mutate(
          Total_Sales = paste0("₹", format(round(Total_Sales, 0), big.mark = ",")),
          Total_Profit = paste0("₹", format(round(Total_Profit, 0), big.mark = ",")),
          Profit_Margin = paste0(Profit_Margin, "%"),
          Orders = format(Orders, big.mark = ",")
        ),
      colnames = c("Region", "Total Revenue", "Net Profit", "Orders", "Profit Margin %"),
      options = list(pageLength = 5, dom = 't', autoWidth = TRUE),
      rownames = FALSE,
      class = "stripe compact"
    )
  })
  
  # ----------------------------------------------------------------------------
  # 7. WHAT-IF SCENARIO SIMULATOR
  # ----------------------------------------------------------------------------
  sim_results <- reactive({
    simulate_scenario(
      filtered_df(),
      discount_shift_pct = input$sim_discount_shift,
      volume_growth_pct  = input$sim_volume_growth
    )
  })
  
  output$sim_val_revenue <- renderUI({
    res <- sim_results()
    if (is.null(res)) return("₹0")
    format_inr(res$simulated$revenue)
  })
  
  output$sim_diff_revenue <- renderUI({
    res <- sim_results()
    if (is.null(res)) return(NULL)
    delta <- res$simulated$delta_revenue
    delta_pct <- res$simulated$delta_revenue_pct
    cls <- if (delta >= 0) "positive" else "negative"
    sign_str <- if (delta >= 0) "+" else ""
    tags$div(
      class = paste("small fw-bold", cls),
      paste0(sign_str, format_inr(delta), " (", sign_str, delta_pct, "%) vs Actual")
    )
  })
  
  output$sim_val_profit <- renderUI({
    res <- sim_results()
    if (is.null(res)) return("₹0")
    format_inr(res$simulated$profit)
  })
  
  output$sim_diff_profit <- renderUI({
    res <- sim_results()
    if (is.null(res)) return(NULL)
    delta <- res$simulated$delta_profit
    delta_pct <- res$simulated$delta_profit_pct
    cls <- if (delta >= 0) "positive" else "negative"
    sign_str <- if (delta >= 0) "+" else ""
    tags$div(
      class = paste("small fw-bold", cls),
      paste0(sign_str, format_inr(delta), " (", sign_str, delta_pct, "%) vs Actual")
    )
  })
  
  output$plot_sim_comparison <- renderPlotly({
    plot_simulation_comparison(sim_results())
  })
  
  # ----------------------------------------------------------------------------
  # 8. RAW DATA EXPLORER & CSV EXPORT
  # ----------------------------------------------------------------------------
  output$table_raw_data <- renderDT({
    display_df <- filtered_df() %>%
      select(Order_ID, Order_Date, Customer_Name, Customer_Segment, Region, City, 
             Category, Sub_Category, Product_Name, Quantity, Sales, Profit, Payment_Method)
    
    datatable(
      display_df,
      filter = "top",
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        lengthMenu = c(10, 25, 50, 100),
        dom = '<"top"lf>rt<"bottom"ip>'
      ),
      rownames = FALSE,
      class = "display compact cell-border"
    ) %>%
      formatCurrency(columns = c("Sales", "Profit"), currency = "₹", digits = 0)
  })
  
  output$btn_download_csv <- downloadHandler(
    filename = function() {
      paste0("sales_analysis_export_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_df(), file, row.names = FALSE)
    }
  )
}

