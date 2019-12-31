
# References
# tidyquant moving averages: https://rdrr.io/cran/TTR/man/MovingAverages.html
# core tidyquant functions:
    # https://www.rdocumentation.org/packages/tidyquant/versions/0.5.1/vignettes/TQ01-core-functions-in-tidyquant.Rmd
# https://cran.r-project.org/web/packages/BatchGetSymbols/vignettes/BatchGetSymbols-vignette.html
# https://rdrr.io/cran/BatchGetSymbols/man/BatchGetSymbols.html

# Examples for quantstrat package: https://ntguardian.wordpress.com/2017/04/24/order-type-parameter-optimization-quantstrat/
# datacamp quantstrat code https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html

# Purpose: To explore a basket of stocks to identify what's up and coming

library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 

setwd("~/Desktop/Meow/TradeAnalytics")

# Source Stock Baskets
source("TradeNow/stock_download.R") 

#### Select which basket of stocks want to explore ####

 tickers <- mary_jane
# tickers <- restaurant
# tickers <- real_estate
# tickers <- oil_gas
# tickers <- tech

 
# set parameters
first.date <- Sys.Date()-60 #last 60 days
last.date <- Sys.Date()
freq.data <- 'daily'

# fetch data
l.out <- BatchGetSymbols(tickers = tickers,
                         first.date = first.date,
                         last.date = last.date, do.cache=FALSE)

print(l.out$df.control)
stock_historical <- print(l.out$df.tickers)

# graph

stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close, color = ticker)) + 
  geom_line()

# graph 2
stock_historical %>% 
  ggplot(aes(x = ref.date, y = price.close)) + 
  geom_line(color="darkorange") + 
  geom_smooth(method="lm") +
  theme_dark() + 
  labs(caption="Source: Yahoo") +
  facet_wrap(~ticker, scales = 'free_y') 


stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close)) +
  geom_barchart(aes(open = price.open, high = price.high, low = price.low, close = price.close)) +
  labs(title = "Bar Chart", y = "Closing Price", x = "") + 
  theme_tq() +
  facet_wrap(~ticker, scales = 'free_y') 


# candlestick

stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close)) +
  geom_candlestick(aes(open = price.open, 
                       high = price.high, 
                       low = price.low, close = price.close),
                   colour_up = 'darkgreen', colour_down = 'darkred',
                   fill_up = 'darkgreen', fill_down = 'darkred') +
  labs(caption="Source: Yahoo") +
  labs(title = "Top High Growth Weed Stocks over Last 60 Days", y = "Closing Price", x = "") +
  theme_tq() +
  facet_wrap(~ticker, scales = 'free_y') 

# Simple Moving Averages

stock_historical %>% 
  ggplot(aes(x = ref.date, y = price.adjusted)) + 
  geom_line() +                         # Plot stock price
  geom_ma(ma_fun = SMA, n = 20) +                 # Plot 50-day SMA
  geom_ma(ma_fun = SMA, n = 30, color = "red") + # Plot 200-day SMA
  #coord_x_date(xlim = c(today() - weeks(60), today()),
  #             ylim = c(100, 130))  + 
  facet_wrap(~ticker, scales = 'free_y') 

class(stock_historical)




