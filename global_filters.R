## NOTE: Enter in Preferences and Run script

library(zoo)
library(tseries)
library(tidyverse)
library(urca)
library(PerformanceAnalytics)
library(quantmod)
library(xts)
library(tseries)
library(quantmod)
library(forecast)
library(sweep)
library(PerformanceAnalytics)
library(TTR)
library(dygraphs)
library(pbapply)


#### Type of Focal Stock to Fetch ####

# focal stock
stock <- "LOGI"

# set historical date parameters and frequency
first.date <- Sys.Date()-365 #last x days
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
# tickers <- pharma

#### Fetch Data ####
source("fetch_data.R")


#### Filters for Technical Indicators ####

# NOTE:  ~20 trading days in a month

short_past_days <- 10  # average of prices in the past n days (averaging over n periods)
long_past_days <- 20
momentum_days = 14 # Number of days of momentum based on closing price
relative_strength_days = 14 # RSI

#### Day Trading Rules ####

# generate buying signal based on filter rule: (set_buy_sell_rules)
price <- focal_stock_adjusted # adjusted close price
price_change <- price/Lag(price) - 1 # % price change
delta <-0.005 # threshold for % change from previous day

# Day Trading Strategies:

# buy signal
signal_buy <- c(0) # first date has no signal

# Buy-Sell Rule
signal_buy_sell <- c(NA)

# RSI Strategy:  
day <-relative_strength_days
price <- focal_stock_adjusted
signal_rsi <- c()                   #initialize vector
rsi <- RSI(price, day)          #rsi is the lag of RSI
rsi_upper_cutpoint <- 81         
rsi_lower_cutpoint <- 60 #automate this somehow

signal_rsi[1:day+1] <- 0            #0 because no signal until day+1

# combine signals
signal_combine <- c()

####################### Trade Size and Strategy Based on Current Equity #################### 

qty <- 5 # number of stocks per trade
day <- day

wealth <- c()
wealth[1:(day+1)] <- 50 # equity to invest

return <- c()
return[1:(day+1)] <- 0 


profit <- c()
profit[1:(day+1)] <- 0



########################### Forecast Options ########################### 
lag.max = 10 # days to look back
h = 5 # days to predict ahead (if change, then need to change dates) 
historical_prices = 30 # x number of days of historical data to plot












