
# GOAL - CREATE A DATAFRAME AND REFORMAT TO XTS OBJET

library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 
library(timetk)
# library(timeSeries)


setwd("~/Desktop/Meow/TradeAnalytics")

# Source Stock Baskets
source("TradeNow/stock_download.R") 



###################################### NEW ################################################

initdate <- "2017-01-01"
from <- "2018-01-01" #start of backtest
to <- Sys.Date() #end of backtest

Sys.setenv(TZ= "UTC") #Set up environment for timestamps
currency("USD") #Set up environment for currency to be use


# Source Stock Baskets
source("TradeNow/stock_download.R")

symbols <- mary_jane #symbols used in our backtest

# fetch data
batch.out <- BatchGetSymbols(tickers = symbols,
                         first.date = initdate,
                         last.date = to, 
                         thresh.bad.data = 0.25,
                         do.complete.data = TRUE, # If TRUE, all missing pairs of ticker-date will be replaced by NA or closest price
                         do.fill.missing.prices = FALSE, # Finds all missing prices and replaces them by their closest price with preference for the previous price
                         do.cache=FALSE)

stock_valid_summary <- (batch.out$df.control)

stock_batch <- (batch.out$df.tickers)

stock_batch_join <- left_join(stock_batch, stock_valid_summary, by = 'ticker')

# remove missing and identify stocks to analyze 
stock_valid <- stock_batch_join %>% 
  na.omit() %>% 
  filter(volume > 0) %>%
  group_by(ticker) %>%
  distinct(ticker) 
  

getSymbols(Symbols = stock_valid$ticker, 
           src = "yahoo", 
           from=from, 
           to=to, 
           strict = TRUE, # stop conversion of NA values
           missing = c('remove'),
           adjust = TRUE) #receive data from yahoo finance,  adjusted for splits/dividends, xts format


###############################################################################################

