## NOTE: Enter in Preferences and Run script


# NEXT STEPS:

# 1. create new .RMD file and include only chart explore objects
# 2. add new exploration charts to stock_explore- 
# https://bookdown.org/kochiuyu/Technical-Analysis-with-R/charting.html




#### Type of Focal Stock to Fetch ####

# focal stock
stock <- "WORK"

# set historical date parameters and frequency
first.date <- Sys.Date()-60 #last 60 days
last.date <- Sys.Date()
freq.data <- 'daily'

# Source Stock Baskets
source("stock_download.R")

#### Select which basket of stocks want to explore ####

# tickers <- mary_jane
# tickers <- restaurant
# tickers <- real_estate
# tickers <- oil_gas
 tickers <- tech

#### Fetch Data ####
source("fetch_data.R")

#### Exploration ####
source("stock_explore.R")

#### Forecast Options ####
lag.max = 10 # days to look back
h = 5 # days to predict ahead (if change, then need to change dates) 
historical_prices = 30 # x number of days of historical data to plot



