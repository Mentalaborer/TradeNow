

# Purpose:  create trading signal based on rule starting with simple to complex. Recall that simple 
#filter rule suggests buying when the price increases a lot compared to the yesterday price


source('global_filters.R')

###### Generate Day Trading Signals ###### 

##  Strategy #1
price_change_strategy <- function(price){ 
  for (i in 2: length(price)){
    if (price_change[i] > delta){ 
      signal_buy[i]<- 1 
    } else 
      signal_buy[i]<- 0 
  }

  signal_buy<-reclass(signal_buy, price)
  colnames(signal_buy) <- 'price_change_met'
  # buying when the price increases a lot (by the threshold)
  trade <- lag(signal_buy, 1) # trade based on yesterday's signal
  return(trade)
}

strategy_pcs <- price_change_strategy(price) 

##  Strategy #2
price_change_buy_sell_strategy <- function(price){
  for (i in 2: length(price)){
    if (price_change[i] > delta){
      signal_buy_sell[i]<- 1
    } else if (price_change[i]< -delta){
      signal_buy_sell[i]<- -1
    } else
      signal_buy_sell[i]<- 0
  }
  
  signal_buy_sell<-reclass(signal_buy_sell, price)
  trade <- Lag(signal_buy_sell)
  names(trade) <- 'naive_trade_rule'
  return(trade)
}

apply_pcbss <- price_change_buy_sell_strategy(price)

##  Strategy #3
rsi_strategy <- function(price){
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
  return(trade_rsi)
}
  
apply_rsi <- rsi_strategy(price)

## Strategy #4

# Buy signal based on EMA rule
# Sell signal based on RSI rule

rsi_ema_strategy <- function(price) {
  for (i in (day+1):length(price)){
    if (price_change[i] > delta){
      signal_combine[i]<- 1
    } else if (rsi[i] > rsi_upper_cutpoint){
      signal_combine[i]<- -1
    } else
      signal_combine[i]<- 0
  }
  signal_combine<-reclass(signal_combine,price)
  trade_4 <- Lag(signal_combine)
  names(trade_4) <- 'ema_rsi_combined'
  return(trade_4)
}

apply_rsi_ema <- rsi_ema_strategy(price)

## Strategy #5
    # Buy one more unit if RSI <30. (lower limit)
    # Keep buying the same if 30 < RSI < 50 
    # Stop trading if RSI >= 50

rsi_upper_lower_strategy <- function(price) { 
  for (i in (day+1): length(price)){ 
    if (rsi[i] < rsi_lower_cutpoint){  #buy one more unit if rsi < lower 
    signal_rsi[i] <- signal_rsi[i-1]+1
  } else if (rsi[i] < rsi_upper_cutpoint){  #no change if rsi < upper
    signal_rsi[i] <- signal_rsi[i-1] 
  } else {         # sell  if rsi > upper
    signal_rsi[i] <- 0
  }
  }
  
trade_size_signal<-reclass(signal_rsi,price)

trade <- lag(trade_size_signal)
names(trade) <- 'rsi_upper_lower'
return(trade)
}

apply_rsi_upper_lower <- rsi_upper_lower_strategy(price)

######################### Application of Strategies to Compute Returns ###################

# Return for price change based on buy rules 
apply_pcs_return <-dailyReturn(price)*price_change_strategy(price) # daily profit rate = daily return (close - open / open)
names(apply_pcs_return)<-'filter'

# Return for price change strategy based on buy sell rules 
apply_pcbss_return <-dailyReturn(price)*price_change_buy_sell_strategy(price)
names(apply_pcbss_return) <- 'Naive'
apply_pcbss_return <- cbind(apply_pcbss_return, apply_pcs_return)

### Return for price change and RSI signals ###
naive_return <- dailyReturn(price)*apply_pcbss$naive_trade_rule
names(naive_return) <- 'Naive'

    # construct a new variable ret2
      rsi_return <- dailyReturn(price)*apply_rsi$rsi_trade_rule
      names(rsi_return) <- 'RSI'

# compare strategies with filter rules
signal_compare <- cbind(naive_return, rsi_return)

# return based on rsi and ema rules 
rsi_ema_return <- dailyReturn(price)*apply_rsi_ema 
names(rsi_ema_return) <- 'ema_rsi_return'
signal_compare_all <- cbind(naive_return, rsi_return, rsi_ema_return)

# return based on equity
close <- focal_stock$focal_Close
open <- focal_stock$focal_Open

for (i in (day+1):length(price)){
  profit[i] <- qty * apply_rsi_upper_lower[i] * (close[i] - open[i])  
  wealth[i] <- wealth[i-1] + profit[i]
  return[i] <- (wealth[i] / wealth[i-1]) -1  
}

equity_based_return <-reclass(return, price)
names(equity_based_return) <- 'rsi_upper_lower_return'





















