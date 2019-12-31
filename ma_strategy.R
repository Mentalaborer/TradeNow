
# code reference: http://past.rinfinance.com/agenda/2018/BrianPeterson.html#15



#  install.packages("devtools") # if not installed
#  require(devtools)
# # install.packages("FinancialInstrument") #if not installed
# # install.packages("PerformanceAnalytics") #if not installed
# # 
# # # next install blotter from GitHub
# # devtools::install_github("braverock/blotter") # reinstall HERE
# # # next install quantstrat from GitHub
#  devtools::install_github("braverock/quantstrat") # reinstall

 
 ### START:
 # get quanstrat library (done)
 # finish and test this script (done)
 # rename strategy as moving average (done)
 # allow for pulling data for multiple stocks - maybe use batch symbols function
 # functionalize
 # create a cover page that sources each strategy script / function
 

#libraries
library(quantmod)
library(quantstrat)
library(TTR)
library(png)
library(IKTrading)



################################################ Strategy Overview ################################################ 


# Buy When: SMA-50 > SMA-200 AND the RSI < 20
# Sell When: SMA-50 < SMA-200 OR RSI > 80





################################################ Initialization ############################################ 

# rm(list = ls(.blotter), envir = .blotter) # remove blotter from global env but will cause errors when initialize strategt
 if (!exists('.blotter')) .blotter <- new.env() # adds blotter back to environment

#removes old portfolio and strategy from environment
# rm.strat(portfolio.st)
# rm.strat(strategy.st) 
 if (!exists('.strategy')) .strategy <- new.env() 
 
 # Source Stock Baskets
 source("TradeNow/stock_download.R")


initdate <- "2015-01-01"
from <- "2017-01-01" #start of backtest
to <- Sys.Date() #end of backtest

Sys.setenv(TZ= "UTC") #Set up environment for timestamps
currency("USD") #Set up environment for currency to be use

################################################ Get Data ################################################ 

symbols <- mary_jane #symbols used in our backtest
getSymbols(Symbols = symbols, 
           src = "yahoo", 
           from=from, 
           to=to, 
           strict = TRUE, # stop conversion of NA values
         #  missing = na.approx(),
           adjust = TRUE) #receive data from yahoo finance,  adjusted for splits/dividends, xts format

stock(symbols, currency = "USD", multiplier = 1) #tells quanstrat what instruments present and what currency to use

focal_stock <- c('SMG', 'CVSI', 'CWEB')

################################################ set account parameters ################################### 

tradesize <-500 #default trade size
initeq <- 1000 #default initial equity in our portfolio

strategy.st <- portfolio.st <- account.st <- "firststrat" #naming strategy, portfolio and account

#initialize portfolio, account, orders and strategy objects
initPortf(portfolio.st, symbols = focal_stock, initDate = initdate, currency = "USD") # FIXME: update data when have mulitple stocks
initAcct(account.st, portfolios = portfolio.st, initDate = initdate, currency = "USD", initEq = initeq)
initOrders(portfolio.st, initDate = initdate)
strategy(strategy.st, store=TRUE)


################################################ Add Indicators: simple moving averages ########################################## 

# 200 day moving average
add.indicator(strategy = strategy.st,
              name = 'SMA',
              arguments = list(x = quote(Cl(mktdata)), n=200),
              label = 'SMA200')

# 50 day moving average
add.indicator(strategy = strategy.st,
              name = 'SMA',
              arguments = list(x = quote(Cl(mktdata)), n=50),
              label = 'SMA50')

# RSI
add.indicator(strategy = strategy.st,
              name = 'RSI',
              arguments = list(price = quote(Cl(mktdata)), n=3),
              label = 'RSI_3')

################################################ Add signals ########################################## 

#First Signal: sigComparison specifying when 50-day SMA above 200-day SMA
add.signal(strategy.st, name = 'sigComparison',
           arguments = list(columns=c("SMA50", "SMA200")),
           relationship = "gt",
           label = "longfilter")


#Second Signal: sigCrossover specifying the first instance when 50-day SMA below 200-day SMA 
add.signal(strategy.st, name = "sigCrossover",
           arguments = list(columns=c("SMA50", "SMA200")),
           relationship = "lt",
           lablel = "sigCrossover.sig")

#Third Signal: sigThreshold which specifies all instance when RSI is below 20 (indication of asset being oversold)
add.signal(strategy.st, name = "sigThreshold",
           arguments = list(column = "RSI_3", threshold = 20,
                            relationship = "lt", cross = FALSE),
           label = "longthreshold")


#Fourth Signal: sigThreshold which specifies the first instance when rsi is above 80 (indication of asset being overbought)
add.signal(strategy.st, name = "sigThreshold",
           arguments = list(column = "RSI_3", threshold = 80,
                            relationship = "gt", cross = TRUE),
           label = "thresholdexit")


#Fifth Signal: sigFormula which indicates that both longfilter and longthreshold must be true.
add.signal(strategy.st, name = "sigFormula",
           arguments = list(formula = "longfilter & longthreshold",
                            cross = TRUE),
           label = "longentry")


################################################ Add Rules ########################################## 

# purpose: use signals to generate actual buy/sell orders

# The first rule will be an exit rule. 
# This exit rule will execute when the market environment is no longer conducive to a trade (i.e. when the SMA-50 falls below SMA-200)

add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "sigCrossover.sig", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "exit")

#The second rule, similar to the first, executes when the RSI has crossed above 80. 
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "thresholdexit", sigval = TRUE,
                          orderqty = "all", ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open"),
         type = "exit")

#Additionally, we also need an entry rule. This rule executes when longentry is true (or when long filter and longthreshold are true). That is when SMA-50 is above SMA-200 and the RSI is below 20.
add.rule(strategy.st, name = "ruleSignal",
         arguments = list(sigcol = "longentry", sigval = TRUE,
                          orderqty = 1, ordertype = "market",
                          orderside = "long", replace = FALSE,
                          prefer = "Open", osFUN = IKTrading::osMaxDollar,
                          tradeSize = tradesize, maxSize = tradesize),
         type = "enter")

################################################ Results ########################################## 

results <- applyStrategy(strategy = strategy.st, portfolios = portfolio.st)
updatePortf(portfolio.st)
daterange <- time(getPortfolio(portfolio.st)$summary)[-1]

updateAcct(account.st, daterange)
updateEndEq(account.st)


tstats <- tradeStats(Portfolios = portfolio.st)

tstats[, 4:ncol(tstats)] <- round(tstats[, 4:ncol(tstats)],2)
stock_stats <- data.frame(t(tstats[,-c(1,2)]))


################################################ visualizations ########################################## 
single_stock <- SMG

#Plots the 50, 200 day SMA
candleChart(single_stock, up.col = "black", dn.col = "red", theme = "white")
addSMA(n = c(200,50), on = 1, col = c("red", "blue"))

#Plots the RSI with lookback equal to 10 days 
plot(RSI(Cl(single_stock), n=10))


## Plot Multple stocks. replace "focal_stock" with data that will contain multiple stocks - rename to "symbol"


# FIXME to plot multiple stocks


for(symbol in symbols){
  
  chart.Posn(Portfolio = portfolio.st, Symbol = focal_stock, 
             TA= c("add_SMA(n=50, col='blue')", "add_SMA(n=200, col='red')"))
}






