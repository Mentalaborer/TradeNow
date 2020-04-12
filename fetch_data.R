
# GOAL - FETCH DATA FROM YAHOO AS A DATAFRAME AND REFORMAT TO XTS OBJET

library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 
library(timetk)
# library(timeSeries)


setwd("~/Documents/TradeAnalytics")
# Source Stock Baskets
source("TradeNow/stock_download.R")



####################################### Set Date Parameters and Select Basket of Stocks ########################################################
#
# initdate <- "2017-01-01"
from <- "2020-01-01" #start of backtest
to <- Sys.Date() #end of backtest

Sys.setenv(TZ= "UTC") #Set up environment for timestamps
# currency("USD") #Set up environment for currency to be use

symbols <- tech #symbols used in our backtest


####################################### Fetch Data ########################################################################################

# grab adjusted prices for multiple stocks

data_env <- new.env()


# symbols is from teh fetch_data script but should source directly
getSymbols(symbols, src = "yahoo", from = "2019-01-01",
           auto.assign = T, return.class = "xts", env = data_env)


# Extract only the ajusted columns
stock_adj <- do.call(merge, eapply(data_env, Ad))

### stop

batch.out <- BatchGetSymbols(tickers = symbols,
                      #   first.date = initdate,
                         last.date = to, 
                         thresh.bad.data = 0.25, # test to see right threshold
                         do.complete.data = TRUE, # If TRUE, all missing pairs of ticker-date will be replaced by NA or closest price
                         do.fill.missing.prices = FALSE, # Finds all missing prices and replaces them by their closest price with preference for the previous price
                         do.cache=FALSE)

stock_valid_summary <- (batch.out$df.control)

stock_batch <- (batch.out$df.tickers)

stock_batch_join <- left_join(stock_batch, stock_valid_summary, by = 'ticker')


#stock_xts <- xts(stock_batch_join, order.by = as.Date(rownames(stock_batch_join$ref.date), '%m-%d-%Y'))



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


## END ############################################################################################

