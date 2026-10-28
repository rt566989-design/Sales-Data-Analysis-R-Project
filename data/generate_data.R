# ==============================================================================
# Script: generate_data.R
# Purpose: Generate realistic Retail & E-Commerce Sales Dataset for Analysis
# ==============================================================================

set.seed(42)

n_records <- 2500

# Dates across 2 years (2023 to 2024)
start_date <- as.Date("2023-01-01")
end_date   <- as.Date("2024-12-31")
date_seq   <- seq(start_date, end_date, by = "day")
order_dates <- sample(date_seq, n_records, replace = TRUE)
order_dates <- sort(order_dates)

# Customer Pool
n_customers <- 300
customer_ids <- sprintf("CUST-%04d", 1:n_customers)
first_names <- c("Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan", "Krishna", "Ishaan",
                 "Diya", "Saanvi", "Ananya", "Aadhya", "Pari", "Chiara", "Riya", "Myra", "Isha", "Tara",
                 "Rohan", "Pooja", "Vikram", "Neha", "Rahul", "Priya", "Amit", "Sneha", "Karan", "Sunita")
last_names  <- c("Sharma", "Verma", "Patel", "Gupta", "Singh", "Kumar", "Mehta", "Chopra", "Joshi", "Bose",
                 "Reddy", "Nair", "Iyer", "Rao", "Das", "Tiwari", "Mishra", "Pandey", "Yadav", "Tripathi")

customer_names <- paste(sample(first_names, n_customers, replace = TRUE),
                        sample(last_names, n_customers, replace = TRUE))
cust_df <- data.frame(
  Customer_ID = customer_ids,
  Customer_Name = customer_names,
  Customer_Segment = sample(c("Consumer", "Corporate", "Home Office", "Small Business"), 
                            n_customers, replace = TRUE, prob = c(0.45, 0.30, 0.15, 0.10)),
  stringsAsFactors = FALSE
)

# Geographic Pool (India major hubs across regions)
geo_data <- data.frame(
  City = c("Mumbai", "Pune", "Ahmedabad", "Delhi", "Jaipur", "Lucknow", "Chandigarh",
           "Bengaluru", "Hyderabad", "Chennai", "Kochi", "Kolkata", "Bhubaneswar", "Patna", "Indore", "Bhopal"),
  Region = c("West", "West", "West", "North", "North", "North", "North",
             "South", "South", "South", "South", "East", "East", "East", "Central", "Central"),
  stringsAsFactors = FALSE
)

# Product Catalog
products_catalog <- data.frame(
  Category = c(
    rep("Electronics", 6),
    rep("Furniture", 4),
    rep("Office Supplies", 5),
    rep("Clothing & Apparel", 4),
    rep("Home Appliances", 4)
  ),
  Sub_Category = c(
    "Smartphones", "Laptops", "Tablets", "Headphones", "Smartwatches", "Accessories",
    "Chairs", "Office Desks", "Bookcases", "Sofas",
    "Printers", "Paper", "Binders", "Storage", "Pens & Stationery",
    "Men's Casual", "Women's Ethnic", "Sportswear", "Winter Jackets",
    "Air Conditioners", "Microwaves", "Coffee Makers", "Vacuum Cleaners"
  ),
  Product_Name = c(
    "Galaxy Note Ultra", "ProBook 15 G8", "iPad Air 10.9", "Noise-Cancelling Pro ANC", "Fitness Tracker FitPlus", "USB-C Fast Charger 65W",
    "Ergonomic Mesh Chair", "Adjustable Standing Desk", "Modular 4-Shelf Bookcase", "3-Seater Comfort Couch",
    "All-in-One Inkjet Printer", "Eco White A4 Ream (500 sheets)", "Heavy-Duty Ring Binder", "Clear Stackable Storage Box", "Luxury Executive Pen Set",
    "Cotton Slim-Fit Shirt", "Designer Silk Kurti", "DryFit Athletic Joggers", "Insulated Windbreaker",
    "Dual-Inverter AC 1.5T", "Convection Microwave 28L", "Espresso Barista Machine", "Robot Smart Vacuum"
  ),
  Base_Cost = c(
    28000, 42000, 32000, 4200, 2100, 600,
    5500, 9500, 3800, 14000,
    7200, 240, 180, 450, 350,
    800, 1100, 650, 1800,
    26000, 7500, 5200, 12500
  ),
  stringsAsFactors = FALSE
)
# Markup to get base price (approx 20% to 55% margin)
products_catalog$Base_Price <- round(products_catalog$Base_Cost * runif(nrow(products_catalog), 1.25, 1.55), -1)

# Generate Transactions
sampled_cust_idx <- sample(1:nrow(cust_df), n_records, replace = TRUE)
sampled_cust <- cust_df[sampled_cust_idx, ]

sampled_geo_idx  <- sample(1:nrow(geo_data), n_records, replace = TRUE, 
                           prob = c(0.12, 0.07, 0.06, 0.13, 0.05, 0.05, 0.04, 
                                    0.13, 0.09, 0.08, 0.04, 0.06, 0.03, 0.02, 0.03, 0.02))
sampled_geo <- geo_data[sampled_geo_idx, ]

sampled_prod_idx <- sample(1:nrow(products_catalog), n_records, replace = TRUE,
                           prob = c(0.08, 0.06, 0.05, 0.07, 0.06, 0.08,
                                    0.05, 0.04, 0.03, 0.02,
                                    0.04, 0.08, 0.06, 0.05, 0.07,
                                    0.05, 0.05, 0.04, 0.03,
                                    0.02, 0.03, 0.02, 0.02))
sampled_prod <- products_catalog[sampled_prod_idx, ]

# Quantities and Discounts
quantity <- sample(1:8, n_records, replace = TRUE, prob = c(0.40, 0.25, 0.15, 0.08, 0.05, 0.03, 0.02, 0.02))
discount_rates <- sample(c(0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30), n_records, replace = TRUE,
                         prob = c(0.35, 0.20, 0.18, 0.12, 0.08, 0.04, 0.03))

payment_methods <- sample(c("UPI / QR Code", "Credit Card", "Debit Card", "Net Banking", "Cash on Delivery"),
                          n_records, replace = TRUE, prob = c(0.38, 0.28, 0.14, 0.12, 0.08))

order_ids <- sprintf("ORD-%d-%05d", lubridate::year(order_dates), 1:n_records)

unit_price <- sampled_prod$Base_Price
unit_cost  <- sampled_prod$Base_Cost
gross_sales <- unit_price * quantity
discount_amount <- round(gross_sales * discount_rates, 2)
net_sales <- gross_sales - discount_amount
total_cost <- unit_cost * quantity
profit <- round(net_sales - total_cost, 2)
profit_margin <- round((profit / net_sales) * 100, 2)

sales_df <- data.frame(
  Order_ID        = order_ids,
  Order_Date      = as.character(order_dates),
  Customer_ID     = sampled_cust$Customer_ID,
  Customer_Name   = sampled_cust$Customer_Name,
  Customer_Segment= sampled_cust$Customer_Segment,
  Region          = sampled_geo$Region,
  City            = sampled_geo$City,
  Category        = sampled_prod$Category,
  Sub_Category    = sampled_prod$Sub_Category,
  Product_Name    = sampled_prod$Product_Name,
  Unit_Cost       = unit_cost,
  Unit_Price      = unit_price,
  Quantity        = quantity,
  Discount        = discount_rates,
  Gross_Sales     = gross_sales,
  Discount_Amount = discount_amount,
  Sales           = net_sales,
  Total_Cost      = total_cost,
  Profit          = profit,
  Profit_Margin   = profit_margin,
  Payment_Method  = payment_methods,
  stringsAsFactors = FALSE
)

# Save to CSV
write.csv(sales_df, file = "data/sales_data.csv", row.names = FALSE)
cat(sprintf("Successfully generated %d sales transactions saved to data/sales_data.csv\n", nrow(sales_df)))
cat(sprintf("Date Range: %s to %s\n", min(sales_df$Order_Date), max(sales_df$Order_Date)))
cat(sprintf("Total Revenue: INR %.2f\n", sum(sales_df$Sales)))
cat(sprintf("Total Profit: INR %.2f (Avg Margin: %.2f%%)\n", sum(sales_df$Profit), mean(sales_df$Profit_Margin)))

