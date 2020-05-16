
# References
# tidyquant moving averages: https://rdrr.io/cran/TTR/man/MovingAverages.html
# core tidyquant functions:
    # https://www.rdocumentation.org/packages/tidyquant/versions/0.5.1/vignettes/TQ01-core-functions-in-tidyquant.Rmd
# https://cran.r-project.org/web/packages/BatchGetSymbols/vignettes/BatchGetSymbols-vignette.html
# https://rdrr.io/cran/BatchGetSymbols/man/BatchGetSymbols.html

# Examples for quantstrat package: https://ntguardian.wordpress.com/2017/04/24/order-type-parameter-optimization-quantstrat/
# datacamp quantstrat code https://statsmaths.github.io/stat395-f17/assets/final_project/amarnani.html

# Purpose: To explore a basket of stocks to identify what's up and coming

## NOTE - Must run/source this script through the stock_explore_report.rmd


# libraries 
library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 
library(quantmod)

#source('fetch_data.R')

################# Basket of Stocks Exploration ################# 

# graph
 plot_actual <- 
  stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close, color = ticker)) + 
   theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  geom_line()

# graph 2
plot_trend <- stock_historical %>% 
  ggplot(aes(x = ref.date, y = price.close)) + 
  geom_line(color="darkorange") + 
  geom_smooth(method="lm") +
  theme_dark() + 
  labs(caption="Source: Yahoo") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ticker, scales = 'free_y') 


plot_hi_lo <- stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close)) +
  geom_barchart(aes(open = price.open, high = price.high, low = price.low, close = price.close)) +
  labs(title = "Bar Chart", y = "Closing Price", x = "") + 
  theme_tq() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
  facet_wrap(~ticker, scales = 'free_y') 


# candlestick
plot_candle <- stock_historical %>%
  ggplot(aes(x = ref.date, y = price.close)) +
  geom_candlestick(aes(open = price.open, 
                       high = price.high, 
                       low = price.low, close = price.close),
                   colour_up = 'darkgreen', colour_down = 'darkred',
                   fill_up = 'darkgreen', fill_down = 'darkred') +
  labs(caption="Source: Yahoo") +
  labs(title = "Basket of Stocks over Last 60 Days", y = "Closing Price", x = "") +
  theme_tq() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ticker, scales = 'free_y') 

# Simple Moving Averages
plot_ma <- stock_historical %>% 
  ggplot(aes(x = ref.date, y = price.adjusted)) + 
  geom_line() +                         # Plot stock price
  geom_ma(ma_fun = SMA, n = 20) +                 # Plot 50-day SMA
  geom_ma(ma_fun = SMA, n = 30, color = "red") + # Plot 200-day SMA
  #coord_x_date(xlim = c(today() - weeks(60), today()),
  #             ylim = c(100, 130))  + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  facet_wrap(~ticker, scales = 'free_y') 

# Predict / forecast closing prices: https://otexts.com/fpp2/simple-methods.html



########### PLOTS ###############

# plot_actual
# plot_trend
# plot_hi_lo
# plot_candle
# plot_ma
# plot_actual_focal
# # plot_hi_lo_focal


