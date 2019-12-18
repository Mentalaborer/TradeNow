
# References
# tidyquant moving averages: https://rdrr.io/cran/TTR/man/MovingAverages.html
# core tidyquant functions:
    # https://www.rdocumentation.org/packages/tidyquant/versions/0.5.1/vignettes/TQ01-core-functions-in-tidyquant.Rmd
# https://cran.r-project.org/web/packages/BatchGetSymbols/vignettes/BatchGetSymbols-vignette.html
# https://rdrr.io/cran/BatchGetSymbols/man/BatchGetSymbols.html
# Examples for quantstrat package: https://ntguardian.wordpress.com/2017/04/24/order-type-parameter-optimization-quantstrat/



library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 


# set tickers - in order of highest growth companies since 8/2019

tickers <- c('FB',
             'ARNA',
             'IAN',
             'CARA',
             'GWPH',
             'HEXO',
             'OGI',
             'TGOD',
             'ACRG',
             'WEED',
             'ACB',
             'CURA',
             'KSHB',
             'NWKRF',
             'GTII',
             'IIPR',
             'HARV',
             'CRON',
             'TLRY',
             'LABS',
             'SMG',
             'CRBP',
             'CVSI',
             'APHA',
             'CWEB',
             'VFF')

# set parameters
first.date <- Sys.Date()-60 #last 60 days
last.date <- Sys.Date()
freq.data <- 'daily'

# fetch data
l.out <- BatchGetSymbols(tickers = tickers,
                         first.date = first.date,
                         last.date = last.date, do.cache=FALSE)

print(l.out$df.control)
weed <- print(l.out$df.tickers)

# graph

weed %>%
  ggplot(aes(x = ref.date, y = price.close, color = ticker)) + 
  geom_line()

# graph 2
weed %>% 
  ggplot(aes(x = ref.date, y = price.close)) + 
  geom_line(color="darkorange") + 
  geom_smooth(method="lm") +
  theme_dark() + 
  labs(caption="Source: Yahoo") +
  facet_wrap(~ticker, scales = 'free_y') 


weed %>%
  ggplot(aes(x = ref.date, y = price.close)) +
  geom_barchart(aes(open = price.open, high = price.high, low = price.low, close = price.close)) +
  labs(title = "Bar Chart", y = "Closing Price", x = "") + 
  theme_tq() +
  facet_wrap(~ticker, scales = 'free_y') 


# candlestick

weed %>%
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

weed %>% 
  ggplot(aes(x = ref.date, y = price.adjusted)) + 
  geom_line() +                         # Plot stock price
  geom_ma(ma_fun = SMA, n = 20) +                 # Plot 50-day SMA
  geom_ma(ma_fun = SMA, n = 30, color = "red") + # Plot 200-day SMA
  #coord_x_date(xlim = c(today() - weeks(60), today()),
  #             ylim = c(100, 130))  + 
  facet_wrap(~ticker, scales = 'free_y') 

class(weed)




