# ==============================================================================
# File: ui.R
# Purpose: Frontend User Interface (UI) - Layout, Controls, Themes, and Views
# ==============================================================================

library(shiny)
library(bslib)
library(plotly)
library(DT)

# Custom Theme Definition using bslib
dashboard_theme <- bs_theme(
  version = 5,
  bootswatch = "flatly",
  primary = "#2563eb",
  success = "#10b981",
  warning = "#f59e0b",
  danger = "#ef4444",
  base_font = font_google("Inter"),
  heading_font = font_google("Poppins")
)

ui <- page_navbar(
  title = "SalesPulse Analytics | Enterprise Sales BI Dashboard",
  theme = dashboard_theme,
  fillable = FALSE,
  header = tags$head(
    tags$link(rel = "stylesheet", href = "custom.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1")
  ),

  # ----------------------------------------------------------------------------
  # TAB 1: EXECUTIVE OVERVIEW
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Executive Overview",
    icon = icon("chart-line"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Filter Controls",
        width = 280,

        # Dataset upload option
        tags$div(
          class = "mb-3",
          tags$label(class = "form-label fw-bold", icon("upload"), " Upload Custom CSV (Optional)"),
          fileInput("user_csv", NULL, accept = c(".csv"), buttonLabel = "Browse...", placeholder = "Default sales_data.csv"),
          uiOutput("upload_status_ui")
        ),
        tags$hr(),

        # Date Filter
        dateRangeInput(
          "filter_dates",
          label = tags$span(icon("calendar-alt"), " Date Range:"),
          start = MIN_DATE,
          end = MAX_DATE,
          min = MIN_DATE,
          max = MAX_DATE,
          format = "yyyy-mm-dd"
        ),

        # Region Filter
        selectizeInput(
          "filter_region",
          label = tags$span(icon("map-marker-alt"), " Region:"),
          choices = ALL_REGIONS,
          selected = ALL_REGIONS,
          multiple = TRUE,
          options = list(plugins = list("remove_button"))
        ),

        # Category Filter
        selectizeInput(
          "filter_category",
          label = tags$span(icon("tags"), " Category:"),
          choices = ALL_CATEGORIES,
          selected = ALL_CATEGORIES,
          multiple = TRUE,
          options = list(plugins = list("remove_button"))
        ),

        # Segment Filter
        selectizeInput(
          "filter_segment",
          label = tags$span(icon("users"), " Customer Segment:"),
          choices = ALL_SEGMENTS,
          selected = ALL_SEGMENTS,
          multiple = TRUE,
          options = list(plugins = list("remove_button"))
        ),

        # Payment Filter
        selectizeInput(
          "filter_payment",
          label = tags$span(icon("credit-card"), " Payment Method:"),
          choices = ALL_PAYMENTS,
          selected = ALL_PAYMENTS,
          multiple = TRUE,
          options = list(plugins = list("remove_button"))
        ),
        tags$hr(),
        actionButton("btn_reset_filters", "Reset All Filters", icon = icon("redo"), class = "btn btn-outline-secondary w-100")
      ),

      # Main Content Area
      tags$div(
        class = "container-fluid p-0",

        # KPI Value Boxes Row
        fluidRow(
          column(width = 4, uiOutput("kpi_card_revenue")),
          column(width = 4, uiOutput("kpi_card_profit")),
          column(width = 4, uiOutput("kpi_card_margin"))
        ),
        fluidRow(
          column(width = 4, uiOutput("kpi_card_orders")),
          column(width = 4, uiOutput("kpi_card_units")),
          column(width = 4, uiOutput("kpi_card_aov"))
        ),

        # Charts Row 1: Time Series & Payment Methods
        fluidRow(
          column(
            width = 8,
            card(
              card_header(icon("chart-area"), " Revenue & Profit Trajectory Over Time"),
              plotlyOutput("plot_trend", height = "360px")
            )
          ),
          column(
            width = 4,
            card(
              card_header(icon("pie-chart"), " Payment Methods Share"),
              plotlyOutput("plot_payment", height = "360px")
            )
          )
        ),

        # Charts Row 2: Category Breakdown & Regional Sales
        fluidRow(
          column(
            width = 7,
            card(
              card_header(icon("layer-group"), " Performance by Product Category"),
              plotlyOutput("plot_category", height = "340px")
            )
          ),
          column(
            width = 5,
            card(
              card_header(icon("globe"), " Revenue by Geographic Region"),
              plotlyOutput("plot_regional", height = "340px")
            )
          )
        )
      )
    )
  ),

  # ----------------------------------------------------------------------------
  # TAB 2: PRODUCT & CATEGORY DEEP-DIVE
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Product Analytics",
    icon = icon("box-open"),
    tags$div(
      class = "container-fluid mt-3",
      fluidRow(
        column(
          width = 6,
          card(
            card_header(icon("trophy"), " Top 10 Best-Selling Products by Revenue"),
            plotlyOutput("plot_top_products_bar", height = "420px")
          )
        ),
        column(
          width = 6,
          card(
            card_header(icon("dot-circle"), " Profit Margin vs Discount (Product Level)"),
            plotlyOutput("plot_scatter_margin", height = "420px")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          card(
            card_header(icon("table"), " Sub-Category Performance Summary"),
            DTOutput("table_subcategory")
          )
        )
      )
    )
  ),

  # ----------------------------------------------------------------------------
  # TAB 3: CUSTOMER & REGIONAL INSIGHTS
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Customer Insights",
    icon = icon("user-friends"),
    tags$div(
      class = "container-fluid mt-3",
      fluidRow(
        column(
          width = 6,
          card(
            card_header(icon("building"), " Customer Segment Performance"),
            plotlyOutput("plot_segment", height = "380px")
          )
        ),
        column(
          width = 6,
          card(
            card_header(icon("award"), " Top 10 High-Value Customers (Lifetime Value)"),
            DTOutput("table_top_customers")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          card(
            card_header(icon("map-marked-alt"), " Regional Performance Breakdown"),
            DTOutput("table_regional_summary")
          )
        )
      )
    )
  ),

  # ----------------------------------------------------------------------------
  # TAB 4: WHAT-IF SCENARIO SIMULATOR
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "What-If Simulator",
    icon = icon("sliders-h"),
    tags$div(
      class = "container-fluid mt-3",
      tags$div(
        class = "info-callout",
        tags$h5(icon("lightbulb"), " Business Impact Simulator"),
        tags$p(
          "Use the sliders below to simulate business strategies such as adjusting discount strategies ",
          "or forecasting unit volume growth to evaluate impact on total revenue and bottom-line profit."
        )
      ),
      fluidRow(
        column(
          width = 4,
          card(
            card_header(icon("cogs"), " Simulation Parameters"),
            sliderInput(
              "sim_discount_shift",
              "Adjust Discount (% Points):",
              min = -15, max = 15, value = 0, step = 1, post = "%"
            ),
            tags$small(class = "text-muted", "E.g., +5% means offering 5% higher discounts to stimulate demand."),
            tags$br(), tags$br(),
            sliderInput(
              "sim_volume_growth",
              "Projected Sales Volume Growth (%):",
              min = -30, max = 50, value = 10, step = 5, post = "%"
            ),
            tags$small(class = "text-muted", "E.g., +10% expected sales quantity growth from promotional campaign.")
          )
        ),
        column(
          width = 8,
          card(
            card_header(icon("calculator"), " Simulated Financial Outcomes"),
            fluidRow(
              column(
                width = 6,
                tags$div(
                  class = "sim-metric-box",
                  tags$div(class = "text-muted", "Projected Revenue"),
                  tags$div(class = "sim-metric-val", uiOutput("sim_val_revenue")),
                  uiOutput("sim_diff_revenue")
                )
              ),
              column(
                width = 6,
                tags$div(
                  class = "sim-metric-box",
                  tags$div(class = "text-muted", "Projected Profit"),
                  tags$div(class = "sim-metric-val", uiOutput("sim_val_profit")),
                  uiOutput("sim_diff_profit")
                )
              )
            ),
            plotlyOutput("plot_sim_comparison", height = "280px")
          )
        )
      )
    )
  ),

  # ----------------------------------------------------------------------------
  # TAB 5: DATA EXPLORER & EXPORT
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "Data Explorer",
    icon = icon("database"),
    tags$div(
      class = "container-fluid mt-3",
      card(
        card_header(
          class = "d-flex justify-content-between align-items-center",
          tags$span(icon("table"), " Raw Sales Transactions Explorer"),
          downloadButton("btn_download_csv", "Download Filtered Data (CSV)", class = "btn btn-sm btn-primary")
        ),
        tags$p(
          class = "text-muted px-3 pt-2",
          "Explore, sort, search, and paginate through transactional records matching your active filters."
        ),
        DTOutput("table_raw_data")
      )
    )
  ),

  # ----------------------------------------------------------------------------
  # TAB 6: PROJECT DOCUMENTATION & ARCHITECTURE
  # ----------------------------------------------------------------------------
  nav_panel(
    title = "About Project",
    icon = icon("info-circle"),
    tags$div(
      class = "container mt-3",
      card(
        card_header(icon("book"), " Project Architecture: Full-Stack R Shiny Mini-Project"),
        tags$div(
          class = "p-3",
          tags$h4("Sales Data Analysis & Business Intelligence Dashboard"),
          tags$p("This mini-project demonstrates an end-to-end full-stack data science and business analytics web application created using the R programming language."),
          tags$hr(),
          tags$h5(icon("desktop"), " 1. Frontend Architecture (UI Layer)"),
          tags$ul(
            tags$li(tags$b("Framework: "), "Shiny UI with bslib (Bootstrap 5) for responsive grid design."),
            tags$li(tags$b("Components: "), "Dynamic Sidebar filters, KPI Metric value boxes, multi-page Navigation panels."),
            tags$li(tags$b("Interactive Visualizations: "), "Plotly.js via plotly R package for interactive tooltips, panning, and zoomable charts."),
            tags$li(tags$b("Data Grid: "), "DT (DataTables.js wrapper) with client-side & server-side sorting, searching, and pagination.")
          ),
          tags$h5(icon("server"), " 2. Backend Architecture (Server Layer)"),
          tags$ul(
            tags$li(tags$b("Data Engine: "), "dplyr and lubridate for high-speed columnar filtering, aggregation, and group-by calculations."),
            tags$li(tags$b("Reactive Paradigm: "), "Reactive data pipeline (reactiveVal, reactive) recalculates downstream KPIs only when filters change."),
            tags$li(tags$b("Modular Business Logic: "), "Separation of concerns across R/data_loader.R, R/analytics.R, and R/plots.R."),
            tags$li(tags$b("What-If Simulation Engine: "), "Dynamic scenario simulation model computing price elasticity and discount shifts."),
            tags$li(tags$b("Data Export Handler: "), "Streaming CSV generation using Shiny's downloadHandler.")
          ),
          tags$h5(icon("check-circle"), " 3. Key Business Questions Answered"),
          tags$ul(
            tags$li("Which product categories and sub-categories yield the highest profit margins?"),
            tags$li("What are the seasonal sales trends across quarters and months?"),
            tags$li("Which geographic regions and customer segments generate the highest customer lifetime value?"),
            tags$li("Does increasing promotional discounts result in higher net profit or margin erosion?")
          )
        )
      )
    )
  )
)
