
# GOAL - FETCH DATA FROM YAHOO AS A DATAFRAME AND REFORMAT TO XTS OBJET

library(BatchGetSymbols)
library(dplyr)
library(tidyverse)
library(lubridate)
library(tidyquant) 
library(timetk)
library(timeSeries)


####################################### Fetch Data ########################################################################################

# fetch a specific stock 
data_env <- new.env()

# call a specific symbol directly
focal_stock <- getSymbols(stock, src = "yahoo", from = first.date,
           auto.assign = F, return.class = "xts", env = data_env)

colnames(focal_stock) <- paste("focal",
                             c("Open", "High", "Low", "Close", "Volume", "Adjusted"),
                             sep = "_")

# selct adjusted column only
focal_stock_adjusted <- focal_stock$focal_Adjusted

####### Grab a basket of stocks ####### 

## basket of stocks to explore ##
l.out <- BatchGetSymbols(tickers = tickers,
                         first.date = first.date,
                         last.date = last.date, do.cache=FALSE)

print(l.out$df.control)
stock_historical <- print(l.out$df.tickers)


## END ############################################################################################

