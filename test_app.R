# Test app integrity
source("global.R")
source("ui.R")
source("server.R")

cat("SUCCESS: global.R, ui.R, and server.R loaded!\n")

kpi <- compute_kpi_summary(initial_sales_data)
cat(sprintf("Test KPI: Revenue = %.2f, Profit = %.2f, Margin = %.2f%%\n", 
            kpi$total_revenue, kpi$total_profit, kpi$profit_margin))

trend <- aggregate_monthly_trend(initial_sales_data)
cat(sprintf("Trend points: %d months\n", nrow(trend)))

sim <- simulate_scenario(initial_sales_data, discount_shift_pct = 5, volume_growth_pct = 10)
cat(sprintf("Simulation Delta Profit: %.2f (%.2f%%)\n", 
            sim$simulated$delta_profit, sim$simulated$delta_profit_pct))

cat("ALL TESTS PASSED SUCCESSFULLY!\n")

