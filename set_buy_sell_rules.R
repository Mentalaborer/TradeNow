

######## DEPRECATE - THIS IS NOW FUNCTIONALIZED ######



# Purpose:  create trading signal based on simple filter rule. Recall that simple 
#filter rule suggests buying when the price increases a lot compared to the yesterday price


# source('global_filters.R')

###### Generate Day Trading Signals ###### 

# ### Signal 1: Based on Simple Filter Rule ###
# for (i in 2: length(price)){
#   if (price_change[i] > delta){
#     signal[i]<- 1
#   } else
#     signal[i]<- 0
# }
# 
# # Assign time to action variable using reclass;
# signal<-reclass(signal, price)
# colnames(signal) <- 'price_change_met'
# 
# ## Apply Trading Rule
# 
# # buying when the price increases a lot (by the threshold)
# trade <- lag(signal, 1) # trade based on yesterday's signal
# stock_return<-dailyReturn(focal_stock_adjusted)*trade # daily profit rate = daily return (close - open / open)
# names(stock_return)<-'filter'

# # Chart with New Trading Rule
# chartSeries(focal_stock_adjusted,
#             type = 'line',
#             subset='2020',
#             plot = TRUE,
#             theme=chartTheme('black'))
# 
# addTA(signal,type='S',col='red')
# 
# #Performance Summary
# charts.PerformanceSummary(stock_return, main="Naive Buy Rule")

## Create Simple Filter Buy-Sell Rule ##

# Goal:  create trading signal based on simple filter rule. 
#         Recall that simple filter rule suggests buying when the price 
#         increases a lot compared to the yesterday price and selling 
#         when price decreases a lot

# # Signal 2: Based on Simple Filter (Naive)
# for (i in 2: length(price)){
#   if (price_change[i] > delta){
#     signal[i]<- 1
#   } else if (price_change[i]< -delta){
#     signal[i]<- -1
#   } else
#     signal[i]<- 0
# }
# 
# ## Apply Trading Rule
# signal_buy_sell<-reclass(signal, price)
# trade_2 <- Lag(signal_buy_sell)
# stock_return_2<-dailyReturn(focal_stock_adjusted)*trade_2
# names(stock_return_2) <- 'Naive'
# charts.PerformanceSummary(stock_return_2)

### Signal 3: Based on RSI ###
# for (i in (day+1): length(price)){
#   if (rsi[i] < rsi_buy_cutpoint){     #buy if rsi < rsi_cutpoint
#     signal[i] <- 1
#   }else {                         #no trade all if rsi > rsi_cutpoint
#     signal[i] <- 0
#   }
# }
# 
# ## Apply Trading Rule
# signal_rsi<-reclass(signal, price)
# trade_3 <- Lag(signal_rsi)
# 
# #construct a new variable ret2
# ret2 <- dailyReturn(price)*trade_2
# names(ret2) <- 'Naive'
# # construct a new variable ret3
# ret3 <- dailyReturn(price)*trade_3
# names(ret3) <- 'RSI'

#  compare strategies with filter rules
# signal_compare <- cbind(ret2, ret3)
# charts.PerformanceSummary(signal_compare,
#                           main="Naive v.s. RSI")

### Signal 4: Based on EMA and RSI ###

# Buy signal based on EMA rule
# Sell signal based on RSI rule

# for (i in (day+1):length(price)){
#   if (price_change[i] > delta){
#     signal_combine[i]<- 1
#   } else if (rsi[i] > rsi_sell_cutpoint){
#     signal_combine[i]<- -1
#   } else
#     signal_combine[i]<- 0
# }
# signal_combine<-reclass(signal_combine,price)
# 
# 
# ## Apply Trading Rule
# trade_4 <- Lag(signal_combine)
# ret4<-dailyReturn(focal_stock_adjusted)*trade_4 
# names(ret4) <- 'Combine'
# retall <- cbind(ret2, ret3, ret4)
# 
# charts.PerformanceSummary(
#   retall, main="Naive v.s. RSI v.s. Combine",
#   colorset=bluefocus)
