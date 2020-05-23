

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
#  naive_buy_sell(signal_buy_sell)
  ## Apply Trading Rule (turn into function)
  signal_buy_sell<-reclass(signal_buy_sell, price)
  trade <- Lag(signal_buy_sell)
  names(trade) <- 'trade_rule'
   stock_return <-dailyReturn(price)*trade
   names(stock_return) <- 'Naive'
   stock_ret <- cbind(stock_return, trade)
 
  return(stock_ret)
}

simple_buy_sell <- buy_sell_signal(price) # move to report and/or global filters


### Signal 3: Based on RSI ###   [FIXME: rsi = 0, fix outside of function]

buy_sell_rsi <- function(price){
for (i in (day+1): length(price)){
  if ((rsi[i] < rsi_upper_cutpoint) & (rsi[i] > rsi_lower_cutpoint)){     #buy if rsi b/t upper and lower limits
    signal_rsi[i] <- 1
  }else {                         #no trade all if rsi > rsi_cutpoint
    signal_rsi[i] <- 0
  }
}

signal_rsi<-reclass(signal_rsi, price)
trade_rsi <- Lag(signal_rsi)
names(trade_rsi) <- 'rsi_trade_rule'

# return
ret1 <- dailyReturn(price)*simple_buy_sell$trade_rule
names(ret1) <- 'Naive'

# construct a new variable ret2
ret2 <- dailyReturn(price)*trade_rsi
names(ret2) <- 'RSI'

#  compare strategies with filter rules
signal_compare <- cbind(ret1, ret2)

return(signal_compare)

}

rsi_buy_sell <- buy_sell_rsi(price) # move to report and/or global filters

## NEXT - add signal 4 - similar setup to signal 3







# visualize

#Performance Summary
charts.PerformanceSummary(simple_buy, main="Naive Buy Rule")
charts.PerformanceSummary(rsi_buy_sell, 
                          main="Naive v.s. RSI")
