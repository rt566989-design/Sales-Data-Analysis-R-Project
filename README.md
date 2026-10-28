# SalesPulse Analytics | Sales Data Analysis (Full-Stack R Mini Project)

An interactive, enterprise-grade **Sales Data Analysis & Business Intelligence Web Application** built with **R Shiny**, featuring a clean separation of **Frontend (UI)** and **Backend (Server Logic & Analytics Engine)**.

---

## 📌 Project Overview
The objective of this mini-project is to analyze retail sales and transactional data to extract actionable business insights. The application enables business managers, analysts, and stakeholders to:
- Monitor key financial and operational metrics (Revenue, Profit, Margin, Order Volume, AOV).
- Analyze performance across product categories, sub-categories, and geographic regions.
- Evaluate customer lifetime value across segments (Consumer, Corporate, Home Office, Small Business).
- Conduct **"What-If" strategic simulations** to project the financial impact of discount changes and demand elasticity.
- Filter, search, explore, and export transactional data on the fly.

---

## 🏗️ Architecture: Frontend vs. Backend Separation

```
+---------------------------------------------------------------------------------+
|                                FRONTEND (ui.R)                                  |
|   - Theme & Styles (bslib Bootstrap 5, custom.css)                              |
|   - Interactive Navbar: Overview, Product Analytics, Customer Insights,         |
|     What-If Simulator, Data Explorer, About Documentation                       |
|   - Dynamic Sidebar Filters: Date Range, Region, Category, Segment, Payment     |
|   - Dynamic File Input: Upload custom CSV dataset                               |
|   - Visual Output Placeholders: plotlyOutput, DTOutput, uiOutput (KPI Cards)    |
+---------------------------------------------------------------------------------+
                                      ▲  │  (Reactive Bindings: input$ & output$)
                                      │  ▼
+---------------------------------------------------------------------------------+
|                                BACKEND (server.R)                               |
|   - Reactive Pipeline: filtered_df() reacts to filter controls                  |
|   - Business Analytics Engine (R/analytics.R): KPIs, time series, rankings      |
|   - Data Management (R/data_loader.R): validation, cleaning, factor formatting  |
|   - Chart Generation (R/plots.R): Plotly interactive charts with tooltips       |
|   - Scenario Engine: What-if price elasticity & volume simulation               |
|   - Data Export Stream: downloadHandler for CSV generation                      |
+---------------------------------------------------------------------------------+
```

### 1. Frontend Layer (`ui.R`, `www/custom.css`)
- **Modern Bootstrap 5 UI**: Designed using `bslib` with custom typography, clean white cards, and vibrant KPI value boxes.
- **Responsive Layout**: Adapts seamlessly to standard desktops, laptops, and tablet displays.
- **Interactive Widgets**: Date range pickers, multi-select tag inputs, simulation sliders, and real-time validation badges.

### 2. Backend Layer (`server.R`, `R/`)
- **Reactive Data Pipelines**: Leverages Shiny's reactive graphs (`reactive`, `reactiveVal`, `observeEvent`) to avoid redundant calculations.
- **Modular Data Engineering (`R/data_loader.R`)**: Handles CSV parsing, schema validation, date conversions (`lubridate`), and datatype enforcement.
- **Statistical & Aggregation Engine (`R/analytics.R`)**: High-performance aggregation using `dplyr` for monthly time series, category rollups, and customer metrics.
- **Interactive Visualizations (`R/plots.R`)**: Renders hardware-accelerated interactive web charts using `plotly`.
- **Data Export**: Server-side streaming CSV download with `downloadHandler`.

---

## 📁 Project Directory Structure

```
Sales Data Analysis R project/
│
├── app.R                      # Main application entry point
├── ui.R                       # Frontend: UI layout, Navigation, Sidebar & Cards
├── server.R                   # Backend: Reactive logic, Aggregations, Handlers
├── global.R                   # Global configurations, Library loading & Datasets
├── test_app.R                 # Automated test script to verify app integrity
├── run_app.R                  # R script to launch the app in browser
├── run_app.bat                # 1-Click Windows Batch launcher
├── README.md                  # Comprehensive Documentation & Viva Guide
│
├── data/
│   ├── sales_data.csv         # Realistic transactional sales dataset (2,500 records)
│   └── generate_data.R        # Dataset generation script (re-run to generate fresh data)
│
├── R/
│   ├── data_loader.R          # Backend data parsing, cleaning, and validation
│   ├── analytics.R            # KPI computation, aggregations, and simulation logic
│   └── plots.R                # Plotly & ggplot2 visualization functions
│
└── www/
    └── custom.css             # Custom CSS styling (gradients, KPI cards, tables)
```

---

## 🚀 How to Run the Project

### Method 1: One-Click Launch on Windows (Recommended)
Simply double-click the **`run_app.bat`** file in the project folder. It will detect your R installation, start the Shiny server, and automatically launch your default web browser at `http://127.0.0.1:7860`.

### Method 2: From RStudio
1. Open RStudio.
2. Open `app.R` (or `ui.R` / `server.R`).
3. Click the **"Run App"** button in the top-right corner of the editor.

### Method 3: From Terminal / Command Prompt
Run the following command:
```bash
Rscript run_app.R
```

---

## 📊 Dashboard Modules & Features

| Tab Name | Key Features & Visualizations |
| :--- | :--- |
| **1. Executive Overview** | • 6 KPI Value Cards (Revenue, Profit, Margin %, Total Orders, Units Sold, Avg Order Value)<br>• Monthly Sales & Profit Line Chart (Plotly dual series)<br>• Payment Method Share Donut Chart<br>• Category Performance & Regional Sales Bar Charts |
| **2. Product Analytics** | • Top 10 Best-Selling Products by Revenue (Horizontal Bar Chart)<br>• Profit Margin vs Discount Scatter Plot (Product-level margin analysis)<br>• Sub-Category Detailed Summary Table |
| **3. Customer Insights** | • Customer Segment Revenue & Profit Comparison<br>• Top 10 High-Value Customers (Customer Lifetime Value Table)<br>• Regional Matrix Table |
| **4. What-If Simulator** | • Interactive Discount Adjustment slider (-15% to +15%)<br>• Sales Volume Growth slider (-30% to +50%)<br>• Real-time financial outcome cards (Projected vs Actual Revenue & Profit)<br>• Comparative Visual Chart |
| **5. Data Explorer** | • Searchable, paginated DT Data Table with multi-column filtering<br>• Instant "Download Filtered Data (CSV)" button |
| **6. About Project** | • Full project architecture documentation, tech stack breakdown, and analytical methodologies |

---

## 🛠️ Tech Stack & Dependencies

- **Language**: R (version 4.0+)
- **Core Web Framework**: `shiny` (v1.14+)
- **Frontend & Styling**: `bslib` (Bootstrap 5 theme), `htmltools`, `custom.css`
- **Data Manipulation & Pipeline**: `dplyr`, `lubridate`
- **Interactive Visualization**: `plotly`, `ggplot2`, `scales`
- **Interactive Tables**: `DT` (DataTables wrapper)

---

## 🎓 College Viva & Presentation Q&A Guide

### Q1: What is the difference between Frontend and Backend in R Shiny?
> **Answer**: In R Shiny:
> - **Frontend (`ui.R`)** defines the presentation layout, input controls (date pickers, dropdowns, sliders), CSS styling, and output display containers (`plotlyOutput`, `DTOutput`, `uiOutput`).
> - **Backend (`server.R`)** contains the application logic, executes R code, listens for changes in UI inputs through reactive programming (`reactive`, `observeEvent`), processes and filters data using `dplyr`, and computes visual plots and statistical metrics to send back to the frontend.

### Q2: What is Reactivity in R Shiny?
> **Answer**: Reactivity is an event-driven programming paradigm. When an input control (e.g. changing the Region filter) is modified by the user on the frontend, Shiny automatically detects the dependency and re-executes only the downstream reactive expressions (`filtered_df()`) and output renderers that depend on that specific input, ensuring high performance.

### Q3: How does the "What-If" Simulator work?
> **Answer**: The simulator models price elasticity and promotional discounts. When the user modifies the discount shift ($\Delta D$) or unit volume growth ($\Delta V$), the backend simulates the new gross sales, adjusted discount amount, net sales, and total cost of goods sold (COGS) to calculate projected profit and margin change.

### Q4: Can the user upload their own data?
> **Answer**: Yes. The sidebar features a file upload control (`fileInput("user_csv", ...)`). The backend validates required columns (`Order_Date`, `Sales`, `Profit`, etc.) in `R/data_loader.R`, parses the file, updates the reactive dataset, and automatically refreshes all KPI cards, charts, and tables without restarting the server.

