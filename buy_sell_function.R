

source('global_filters.R')

###### Generate Day Trading Signals ###### 

# basic buy function
buy_signal <- function(price){ 
 # price %>%  
    for (i in 2: length(price)){
      if (price_change[i] > delta){ 
        signal_buy[i]<- 1 
        } else 
          signal_buy[i]<- 0 
        }

# Assign time to action variable using reclass;
signal_buy<-reclass(signal_buy, price)
colnames(signal_buy) <- 'price_change_met'

# buying when the price increases a lot (by the threshold)
trade <- lag(signal_buy, 1) # trade based on yesterday's signal
stock_return<-dailyReturn(price)*trade # daily profit rate = daily return (close - open / open)
names(stock_return)<-'filter'
return(stock_return)
}

simple_buy <- buy_signal(price) # move to report and/or global filters

# Signal 2: Based on Simple Filter (Naive)
buy_sell_signal <- function(price){
  for (i in 2: length(price)){
  if (price_change[i] > delta){
    signal_buy_sell[i]<- 1
  } else if (price_change[i]< -delta){
    signal_buy_sell[i]<- -1
  } else
    signal_buy_sell[i]<- 0
  }
  ## Apply Trading Rule
  signal_buy_sell<-reclass(signal_buy_sell, price)
  trade <- Lag(signal_buy_sell)
  stock_return <-dailyReturn(price)*trade
  names(stock_return) <- 'Naive'
  return(stock_return)
}

simple_buy_sell <- buy_sell_signal(price) # move to report and/or global filters

### START signal 3: Based on RSI ###






# visualize

#Performance Summary
charts.PerformanceSummary(simple_buy, main="Naive Buy Rule")
charts.PerformanceSummary(simple_buy_sell)

