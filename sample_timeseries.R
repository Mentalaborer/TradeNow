
## Next steps:  1) from script, come up with analysis outline based on topics here 
#               2) do analysis based on code here
#                3) write a function to get prices at different levels (minute, day, week, month)
#                   source this function on a separate script
                
                
library(forecast)
library(ggplot2)
library(ggfortify)
library(fma)
library(datasets)
library(tidyverse)
library(xts)

##############################
# Forcast:  Average Method
##############################

# The average of past periods / T
# Forecast of future value is the mean of past data
# it's like looking at the average past temps in the past 7 days to know what to wear tomorrow (h). 

# T = time periods


head(beer)
summary(beer)
plot(beer)

meanf(beer, 1) #mean forecase of beer for 1 period forward (eg., tomorrow)
meanf(beer, 5)


##############################
# Forecast:  Naive Method
##############################

# Uses the most recent observation as the forecast
# Idea:  What's my forecast for tomorrow given I have today's value? 
# My best guest for tomorrow's value is today's value
# Ex. if have a stock that's pretty stable yesterday, 
# then best guess of stock price today would be yesterday's

# h = number of periods (or days) looking ahead

head(beer)
beer
naive(beer, h = 1)
naive(beer, h = 5) # up to 5 periods ahead
rwf(beer, h=5) # equivalent to random walk

head(books)


##### Moving Average ######
# Helps to smooth out the data
# NOT good to use if there's a trend in the data

# The head() command allows you to take a look at the first few rows of the dataset
head(gold)
gold

# The dim() command allows you to check the size of the dataset
# The first value indicates the number of rows
# The second value indicates the number of columns
str(gold)
dim(gold)
class(gold)



# Next we create gold time series

goldxts <-ts(gold[,2])

goldxts <- as.xts(gold)


#autoplot(goldxts)
autoplot(goldxts)
##############################################################################
# OPTIONAL - The following adds options to label the chart
##############################################################################

autoplot(goldxts) +
  ggtitle("Daily Gold Prices") +
  xlab("period: Jan 1, 1968 to June 11, 2019") +
  ylab("USD")

# The moving average command is ma(x, order)
# x is the data vector and order is the number of lags
# Make sure you install the forecast library

###  example: moving average 10 lags (# of days like days of stock prices)
# k = number of lags, when k=1, the ma is the original data point.  


goldxts10lags <- ma(goldxts, 10) 

autoplot(goldxts10lags) +
  ggtitle("Gold Prices: Moving Average 10 lags") +
  xlab("period: Jan 1, 1968 to June 11, 2019") +
  ylab("USD")


goldxts100lags <- ma(goldxts, 100)

autoplot(goldxts100lags) +
  ggtitle("Gold Prices: Moving Average 100 lags") +
  xlab("period: Jan 1, 1968 to June 11, 2019") +
  ylab("USD")

goldxts500lags <- ma(goldxts, 500)

autoplot(goldxts500lags) +
  ggtitle("Gold Prices: Moving Average 500 lags") +
  xlab("period: Jan 1, 1968 to June 11, 2019") +
  ylab("USD")


#############################
#Simple exponential Smoothing (ses())
#############################
# Uses past data to predict future data
# more weight on recent events than past using alpha weight.
# RMSE is a good way to select alpha constant.
# SES is not good if data has trend or seasonality then ses not perform well

head(airpass)
class(airpass)


airpass_xts <- as.xts(airpass)


autoplot(airpass_xts)
ses5 <- ses(airpass_xts, h=5)
ses5

accuracy(ses5)

# autoplot(ses5) +      FIXME:
#   autolayer(fitted(ses5),series = "Fitted")


### Beer ###
# alpha = 1, 9
# RMSE 

autoplot(beer) # peaks are signs of seasonal effects
beer1 <- ses(beer, h = 25, level = c(80,95), alpha = .1 ) # alpha = smoothing parameter
summary(beer1)
autoplot(beer1)


beer5 <- ses(beer, h = 25, level = c(80,95), alpha = .5 )
summary(beer5)
autoplot(beer5)

accuracy(beer5) # goodness of fit measures

autoplot(beer5) + 
  autolayer(fitted(beer5),series = "Fitted")


#############################
# Holt's Linear Trend Method
#############################

# Allows for data with a trend
# h = number of periods in the future 

holt5 <- holt(airpass_xts,h=5)

autoplot(holt5) + 
  autolayer(fitted(holt5),series = "Fitted")

holt5damped <- holt(airpass_xts, damped=TRUE, phi = 0.9, h=15) # account for any over correction 

#Evidence suggested that the Holt's Linear Trend method 
#overestimated the predicted values. Gardner and McKenzie (1985) 
#found that dampening the trend helped accuracy

autoplot(airpass_xts) +
  autolayer(holt5, series="Holt's method", PI=FALSE) +
  autolayer(holt5damped, series="Damped Holt's method", PI=FALSE) +
  ggtitle("Forecasts from Holt's method") + 
  guides(colour=guide_legend(title="Forecast"))

##############################
# Holt-Winters Seasonal Trend Method 
##############################
# Allows for data with a trend AND seasonality so the final
#     forecast is not impacted by seasonlity and therefore need to subtract it from timeseries
# Additive Model:  Good when there's a constant through seasonal cycles
# Multiplicative:  Seasonality is adjusted through a percentage

hw1 <-hw(airpass_xts, seasonal = "additive")
hw2 <-hw(airpass_xts, seasonal = "multiplicative")

autoplot(airpass_xts) +
  autolayer(hw1, series="HW additive forecasts", PI=FALSE) +
  autolayer(hw2, series="HW multiplicative forecasts",
            PI=FALSE) +
  #ggtitle("International visitors nights in Australia") +
  guides(colour=guide_legend(title="Forecast"))


#### Auto Regression 
# A process to find a relationship with iteself (e.g., stock price yesterday and stock price today)
# Ex. How yesterday's stock price (input) will impact today's stock price (output)
# want to predict the next day's prices


library(zoo)
library(tseries)
library(urca)
library(PerformanceAnalytics)
library(quantmod)



SMG <- getSymbols("SMG", src = "yahoo", from = "2019-01-01",
                   auto.assign = FALSE, return.class = "xts") 

head(SMG)
plot(SMG)

# create time series
SMG <- xts(x = SMG$SMG.Adjusted, order.by = index(SMG))

# AR1 model on SMG stock
#arima(SMG, order = c(1,0,0)) # 1 = how many lags want (here, prices 1 day ago)

## Stationarity

# Before building forecasts models, need to test for Stationarity




# install.packages("xts")

library(xts)
library(tseries)
library(quantmod)
library(PerformanceAnalytics)

# Column 6th is the Adjusted Closing price in Yahoo Finance Data
AAPL<-getSymbols("AAPL", source="yahoo", from = "2019-01-01",to = "2019-03-31",
                 auto.assign=FALSE, return.class="xts")[,6]

#Creating time-series for AAPL stock
AAPL <- xts(x=AAPL$AAPL.Adjusted, order.by = index(AAPL))

# Stationarity Testing 
adf = adf.test(AAPL)
print(adf)

# Stationarity testing on first differences (today - tomorrow or this month - last month)
# necessary to know that the original trend is stationary as it makes predictions more accurate


AAPL.diff= diff(AAPL)

AAPL.diff = na.omit(AAPL.diff) # take off NA from the 1st row

diff.adf =adf.test(AAPL.diff) # augmented test to test for significance

print(diff.adf)

# Plot the data

par(mfrow=c(2,1), mar=c(3,4,4,2)) #Code to put both graphs in one window
plot(AAPL, col="darkblue", ylab="Price")
plot(AAPL.diff,col="darkblue", ylab="Price")



## ARIMA models (Auto Regressive Integrated Moving Average)

# ARIMA models are very useful when you are dealing with one stock price, 
#s o when you're trying to predict the movement of one stock price, 
# and they are very helpful to prepare you to learn other more complex models like GARCH, 
# and autoregressive, and vector autoregressive.
# Helps to know if a stock is worth buying

# Prereq: Data should be stationary

# ARIMA(p,d,q), where lowercase for non-seasonal and capitalized is for seasonal
# p = number of lags (autoregressive)
# d = differencing, where 0 is no difference
# q = moving average, number of lags of the error terms

library(fma)

## Simulations of ARIMA parameterizations 

#ARIMA - White noise model (0,0,0)
arima_wn <- arima.sim(model = list(order = c(0,0,0)), n = 100, mean = 0)
arima_wn
ts.plot(arima_wn)

#ARIMA - Random Walk (0,1,0) - only first differences.  
arima_rw <- arima.sim(model = list(order = c(0,1,0)), n = 100, mean = 0)
arima_rw
ts.plot(arima_rw)

#ARIMA - Random Walk with Drift (0,1,0)+c
arima_rwd <- arima.sim(model = list(order = c(0,1,0)), n = 100, mean = 1)
arima_rwd
ts.plot(arima_rwd)

#ARIMA - First Order Auto-Regressive Model (1,0,0)
arima_fo <- arima.sim(model = list(order = c(1,0,0), ar = 0.75), n = 100, mean = 0)
arima_fo
ts.plot(arima_fo)

arima(arima_fo,order=c(1,0,0))

#ARIMA - Moving Average Model (0,0,1)
arima_ma <- arima.sim(model =(list(order = c(0,0,1), ma = 0.6)), n = 100, mean = 0)
arima_ma
ts.plot(arima_ma)

#######################################
#                                     #
#   ARIMA Modeling                    #
#######################################

## Modeling Steps ##

# plot the data and see if there are any abnormal observations (wierd spikes?)
# Add a trend line to the plotted data and see if stationary.
# test for Stationarity: If non-stationary, then take difference until it is
# Examine pattern of autocorrelations (ACF) and partial correlations (PCF)
#   do so to determine if lags of the stationarized or forecast errors should be included in model
# Fit Model






## example 2

library(xts)
library(tseries)
library(forecast)
library(tibble)
library(ggplot2)
library(sweep)
library(urca) # to test for stationarity



# get SPY data 
#SPY=read.csv("SPY.csv",header = TRUE, sep=",")

# Save the date in a separate identifier as character
#  dates = as.character(SMG$Date)
# # # Remove date values from table
#  SMG$dates = NULL
# # #Announce time series data
#  SMG=xts(SMG$Price, as.POSIXct(dates,format="%m/%d/%Y"))
# #Plot the data
 plot(SMG, col="darkred", main="SMG Price Series") 

# Stationarity testing
StationarityTest = ur.df(SMG,type="none",selectlags = "AIC")
summary(StationarityTest)
#Stationarity Tesing on first Differences
Stationarity_Diff= ur.df(diff(SMG)[2:dim(SMG)[1],], type = "none", selectlags = "AIC")
summary(Stationarity_Diff)

# Plot the graph on first differences
D.SMG= SMG-lag(SMG)
plot(D.SMG, col="red4", main = "SMG On First Differences")

## ACF and PACF  (Needed to determine number of lags needed for autoregressive or error part of model)
# ACF = correlation of timeseries with itself after lagging first timeseries
#     ex. lag.max = 10, 1 lag diff and correlate, 2 lag diff and correlate and 3 lag and correlate, etc
#     want to make sure corr values fall OUTSIDE of the CI lines to be significant
#     indicates the number of lags needed in the moving average part of the arima model ("q").
# PCF = correlation of lag 1 with another lag w/o including intermediary lags ("p")
#   the partial auto-correlation lets us know the value of the autoregressive component (number of lags)


ggAcf(D.SMG, lag.max = 10) + theme_bw()

# Fit the ARIMA Models
ARIMA1 <- Arima(D.SMG, order = c(1, 0, 1))
ARIMA2<-Arima(D.SMG, order = c(1, 0, 2))
ARIMA3<-Arima(D.SMG, order = c(2, 0, 1))
ARIMA4<-Arima(D.SMG, order = c(2, 0, 2))
ARIMA5 <- Arima(D.SMG, order = c(0, 0, 0))

##Display ARIMA results
summary(ARIMA1)
summary(ARIMA2)
summary(ARIMA3)
summary(ARIMA4)
summary(ARIMA5)

# Want to compare RMSE values across models and choose lowest

# Forecasting

##Building ARIMA Forecasting Graph
# Forecasting

#Auto ARIMA

# a function in R to do auto.arima, and it just goes through and test all these combinations and automatically 
# selects a good choice for your p, d and q, your three parameters 
# for your autoregressive component, your integrated component, and your moving average component.

# selects best model using AIC and BIC



h = 5 # number of periods to look ahead for forecast (ex. next 10 days of stoc)
fitted_arima = auto.arima(SMG)
arima_forecast =forecast(fitted_arima, h)
arima_sweep = sw_sweep(arima_forecast)
dates              <- c(index(SMG), index(SMG)[length(SMG)] + 1, index(SMG)[length(SMG)] + 2, index(SMG)[length(SMG)] + 3, index(SMG)[length(SMG)] + 4, index(SMG)[length(SMG)] + 5)
arima_sweep  = add_column(arima_sweep, dates)
# Plotting only the passed 50 days of prices. 
arima_sweep_display<- arima_sweep[(dim(arima_sweep)[1]-50):dim(arima_sweep)[1], ]
# Visualizing the forecast
arima_sweep_display %>%
  ggplot(aes(x = dates, y = value, color = key)) +
  ## Prediction intervals
  geom_ribbon(aes(ymin = lo.95, ymax = hi.95), 
              fill = "#D5DBFF", color = NA, size = 0) +
  geom_ribbon(aes(ymin = lo.80, ymax = hi.80, fill = key), 
              fill = "#596DD5", color = NA, size = 0, alpha = 0.8) +
  ## Actual & Forecast
  geom_line(size = 1) + 
  #geom_point(size = 2) +
  ## Aesthetics
  theme_bw() +
  scale_x_date(date_breaks = "1 week", date_labels = "%b %d") +
  labs(title = "SMG 10 Day Ahead ARIMA Price Forecast", x = "", y = "")


## Modern Portfolio Theory (MPT) ##
# Group of Assets (stocks, bonds, currency, etc. )
# Goal is to measure volatility and the movement of price (higher volatility higher risk)
# Variance and std is the most common way to measure volatility 
# The goal is to maximize expected returns based on a given level of risk 
# Liquidity in the market is how easily or how quickly 
#   we can buy or sell an asset of anything.
# Expected Return = the way you calculate the expected returns 
#     of a security is to look at the historical average.  
#     For 1 security, want to take the log-difference.
# Expected return for a portfolio investment is the weighted average 
# of the expected returns of each of the components (sum of weights = 1).
#   Ex. ER = (weight of A) * (expected return of A) + (weight of B) * (expected return of B)

## calculate the volatility of portfolio = 
#   weight squared of asset A times the variance of asset A plus the weight squared of asset b times the variance of asset b plus 2 times the correlation 
#   of the standard deviations of the returns of a and b times their respective weights

## Trade Off b/t risk and return (ideal = low risk and high return)
# Mean = Expected Return
# Variance = Risk

## Sharpe-Ratio = Expected Return adjusted for Risk (=expected return - risk free rate / std)  
#   Bigger a portfolio's Ratio then better it's risk adjusted
#   Can use this to compare assets

## How to Calculate optimal weights in a portfolio?  
#   Efficient Frontier = is the best combinations of expected returns & risk
# Good to use when know either want to mimimize risk or maximize return:
#   if know how much return want (e.g., 10%), then can figure out what kind 
#   of porfolio mix need given risk
#   maybe thinking about how much risk willing to take, if willing to take a lot 
#   of risk can figure out how much more expected return can anticipate?
# The correlation among stocks drives the shape of the EF. Lower the corr, the lower the risk
# Portfolio's below EF is not good
# Capital Allocation Line = The tanget line to the EF.  The point at which it touches
#     the EF will have the highest sharpe-ratio. This is the asset to pick. 
#     So we want more returns, less risk, and the bigger that number the better 




#######################################
#   Sample Calc of Stock Returns      #
#   and Portfolio Weights             #
#######################################

#installing and calling the packages
install.packages("quantmod")
install.packages("BatchGetSymbols")
install.packages("timeSeries")
library(quantmod)
library(BatchGetSymbols)
library(timeSeries)

##### Example 1 ####

#Obtaining Stock Tickers and Calculating Stock Returns Data
#First, we need to get the tickers of all the stocks in the SnP500 Index

sp500 <- GetSP500Stocks()
sp500tickers <- sp500[,c(1,2,4)]



#Consider 2 stocks 
n = 2
randomstocks <- c(sample.int(500, n))
stocks <- sp500tickers[randomstocks,1]

#Obtain the prices from 'yahoo'
price1 <- getSymbols(stocks[1], source="yahoo", auto.assign=FALSE,
                     return.class="xts")[,6]

price2 <- getSymbols(stocks[2], source="yahoo", auto.assign=FALSE,
                     return.class="xts")[,6]

prices <- cbind(price1, price2)

colnames(prices) <- sp500tickers[randomstocks,2]


#Converting prices to returns
Portfolio <- na.omit(diff(log(prices)))
cor(as.data.frame(Portfolio))

#First we will try to create a set of portfolios using the formulae we learnt in class
#Calculating data parameters for portfolio assets
#Expected Returns
expret1 <- mean(Portfolio[,1])

expret2 <- mean(Portfolio[,2])

#Standard Deviation
sdret1 <- sd(Portfolio[,1])

sdret2 <- sd(Portfolio[,2])

#Covariance
cov_12 <- cov(Portfolio[,1], Portfolio[,2])

#Setting the weights for the 2 asset portfolio
w1 <- (sample(0:100, 100, replace = FALSE))/100
w2 <- 1 - w1

#Calculating data parameters for the portfolio

expret <- w1*expret1 + w2*expret2

sdret <- sqrt(w1^2 * sdret1^2 + w2^2 * sdret2^2 + 2 * w1 * w2 * cov_12)

finalport <- as.data.frame(cbind(sdret, expret))

plot(finalport, ylab = "Expected Return", xlab = "Variance/Risk", main = "Two stock portfolio")


#Now, we will use the fPortfolio package and compare the results with that of the traditional method

library(fPortfolio)

#Let us set the specifications to give us a total of 100 portfolios as opposed to the default number which is 50
Spec = portfolioSpec()
setNFrontierPoints(Spec)<-100

#Convert the data to timeseries data
Portfolio <- as.timeSeries(Portfolio)

##Determine the efficient frontier and plot the same
effFrontier <- portfolioFrontier(Portfolio, Spec ,constraints = "LongOnly")
effFrontier

plot(effFrontier, c(1))


#From the two plots, we can see that the results are identical. 
#However, when working with portfolios with multiple assets, using the package will be more efficient and accurate


##### Example 2 ####

#Installing libraries essential for portfolio construction
library(fPortfolio)
library(quantmod)
library(ggplot2)
library(BatchGetSymbols)
library(timeSeries)

#Obtaining Stock Tickers and Calculating Stock Returns Data
# First, we need to get the tickers of all the stocks in the SnP500 Index
sp500 <- GetSP500Stocks()
sp500tickers <- sp500[,c(1,2,4)]


#We select 5 Leading Tech Hardware Stocks and download the price data for those

stocks1 <- c("AAP", "INTC", "CSCO", "NVDA", "TXN")
prices1 <- getSymbols(stocks1[1], source="yahoo", auto.assign=FALSE,
                      return.class="xts")[,6]
for (i in 2:length(stocks1)){
  prices.tmp <- getSymbols(stocks1[i], source="yahoo", auto.assign=FALSE,
                           return.class="xts")[,6]
  prices1 <- cbind(prices1, prices.tmp)
}
colnames(prices1) <- c("Apple", "Intel", "Cisco", "Nvidia", "Texas Instruments")

plot(prices1$Apple)
plot(prices1$Intel)
plot(prices1$Nvidia)
plot(prices1$Cisco)
plot(prices1$`Texas Instruments`)


#Since we will be working with returns, let us convert the price data to returns 

Portfolio1 <- na.omit(diff(log(prices1)))

#Trimming the Data to get recent data post 12-31-2014
Portfolio1 <- Portfolio1["2015/"]

mean(Portfolio1$Apple)
var(Portfolio1$Apple)
mean(Portfolio1$Intel)|
  var(Portfolio1$Intel)
mean(Portfolio1$Cisco)
var(Portfolio1$Cisco)
mean(Portfolio1$Nvidia)
var(Portfolio1$Nvidia)
mean(Portfolio1$`Texas Instruments`)
var(Portfolio1$`Texas Instruments`)

means <- c(mean(Portfolio1$Apple),mean(Portfolio1$Intel),mean(Portfolio1$Cisco),mean(Portfolio1$Nvidia),mean(Portfolio1$`Texas Instruments`))
vars <- c(var(Portfolio1$Apple),var(Portfolio1$Intel),var(Portfolio1$Cisco),var(Portfolio1$Nvidia),var(Portfolio1$`Texas Instruments`))

Stockplot <- as.data.frame(t(cbind(vars, means)))
colnames(Stockplot)<- c("Apple", "Intel", "Cisco", "Nvidia", "Texas Instruments")
Stockplot <- t(Stockplot)

plot(Stockplot, col = rainbow(5), pch= 15, xlab = "Variance", ylab = "Mean Returns", main = "Risk vs Return")
legend("bottomright", legend=c("Apple", "Intel", "Cisco", "Nvidia", "Texas Instruments"),
       col=rainbow(5), lty=1:2, cex=0.8, pch = 15)

#Convert the numeric vectors to timeseries vectors

Portfolio1 <- as.timeSeries(Portfolio1)

#Let us build portfolio using each of the stock combinations to obtain the minimum variance portfolio in each of the cases


#Set Specs

Spec = portfolioSpec()
setNFrontierPoints(Spec)<-100
#Portfolio 1 - Tech Stocks

##Determine the efficient frontier and plot the same
effFrontier1 <- portfolioFrontier(Portfolio1, Spec ,constraints = "LongOnly")
effFrontier1

plot(effFrontier1, c(1))


##Plot the weights for all the portfolio in the efficient frontier
frontierWeights1 <- getWeights(effFrontier1)
barplot(t(frontierWeights1), main="Frontier Weights", col=cm.colors(ncol(frontierWeights1)+2), legend=colnames(frontierWeights1))



##Obtain the weights for each stock for the portfolio with the least variance
mvp1 <- minvariancePortfolio(Portfolio1, spec=portfolioSpec(),constraints="LongOnly")
mvp1

##Obtain the weights for each stock for the tangency portfolio
tanPort1 <- tangencyPortfolio(Portfolio1, spec=portfolioSpec(), constraints="LongOnly")
tanPort1

#Let us tabulate the weights for the two portfolios for comparison
minvarweights1 <- getWeights(mvp1) 
tanportweights1 <- getWeights(tanPort1)
weights1 <- (cbind(minvarweights1, tanportweights1))
colnames(weights1) <- c("Minimum Variance Portfolio", "Tangency Portfolio")

#### Example 3 ####

#installing and calling the packages
install.packages("quantmod")
install.packages("BatchGetSymbols")
install.packages("timeSeries")
library(quantmod)
library(BatchGetSymbols)
library(timeSeries)


#Obtaining Stock Tickers and Calculating Stock Returns Data
#First, we need to get the tickers of all the stocks in the SnP500 Index

sp500 <- GetSP500Stocks()
sp500tickers <- sp500[,c(1,2,4)]



#Consider 2 stocks 
n = 2
randomstocks <- c(sample.int(500, n))
stocks <- sp500tickers[randomstocks,1]

#Obtain the prices from 'yahoo'
price1 <- getSymbols(stocks[1], source="yahoo", auto.assign=FALSE,
                     return.class="xts")[,6]

price2 <- getSymbols(stocks[2], source="yahoo", auto.assign=FALSE,
                     return.class="xts")[,6]

prices <- cbind(price1, price2)

colnames(prices) <- sp500tickers[randomstocks,2]


#Converting prices to returns
Portfolio <- na.omit(diff(log(prices)))
cor(as.data.frame(Portfolio))

#First we will try to create a set of portfolios using the formulae we learnt in class
#Calculating data parameters for portfolio assets
#Expected Returns
expret1 <- mean(Portfolio[,1])

expret2 <- mean(Portfolio[,2])

#Standard Deviation
sdret1 <- sd(Portfolio[,1])

sdret2 <- sd(Portfolio[,2])

#Covariance
cov_12 <- cov(Portfolio[,1], Portfolio[,2])

#Setting the weights for the 2 asset portfolio
w1 <- (sample(0:100, 100, replace = FALSE))/100
w2 <- 1 - w1

#Calculating data parameters for the portfolio

expret <- w1*expret1 + w2*expret2

sdret <- sqrt(w1^2 * sdret1^2 + w2^2 * sdret2^2 + 2 * w1 * w2 * cov_12)

finalport <- as.data.frame(cbind(sdret, expret))

plot(finalport, ylab = "Expected Return", xlab = "Variance/Risk", main = "Two stock portfolio")


#Now, we will use the fPortfolio package and compare the results with that of the traditional method

library(fPortfolio)

#Let us set the specifications to give us a total of 100 portfolios as opposed to the default number which is 50
Spec = portfolioSpec()
setNFrontierPoints(Spec)<-100

#Convert the data to timeseries data
Portfolio <- as.timeSeries(Portfolio)

##Determine the efficient frontier and plot the same
effFrontier <- portfolioFrontier(Portfolio, Spec ,constraints = "LongOnly")
effFrontier

plot(effFrontier, c(1))


#From the two plots, we can see that the results are identical. 
#However, when working with portfolios with multiple assets, using the package will be more efficient and accurate





#######################################
#                                     #
#   Sample Algo Trading               #
#######################################



#Setting up the required libraries
library(quantmod)
library(tidyverse)
library(TTR)

#Obtaining stock price data for Advanced Auto Parts Inc
AAP <- getSymbols("AAP", source="yahoo", auto.assign=FALSE,
                  return.class="xts")[,6]  # modify if want column 6

#Calculate returns
AAPret <- diff(log(AAP))
colnames(AAPret)  <- "AAP"

#Trim the dataset 
AAPret <- AAPret["2010/"]
AAP <- AAP["2010/"]

plot(AAP)

#Generate Simple Moving Averages
sma26 <- SMA(AAP, 26)
sma12 <- SMA(AAP, 12)

Data <- na.omit(as.data.frame(cbind(AAP, AAPret, sma12, sma26)))
colnames(Data) <- c("AAPPrices","AAPRet","SMA12","SMA26" )


#Condition for trend following strategy

Data$UD <- ifelse(Data$SMA12 >= Data$SMA26, 1, 0) #if short term is >= long term then 1 (buy) otherwise 0 (sell)
class(Data$UD)

#Devise a trading strategy and Backtest

Data$Trade <- ifelse(Data$UD == 1, "BUY", "SELL") #from above
Data$Position <- ifelse(Data$Trade == "BUY", 1, -1) # if trade = buy then 1 otherwise -1
Data$AlgoRet <- Data$AAPRet * Data$Position
AnnualizedReturn <- ((mean(Data$AlgoRet)+1)^252 - 1) # as a decimal and interpret as a %
plot(AAPret)
Standev <- sd(Data$AlgoRet)
rf <- 0.02 #risk free rate (this is an assumption & should look up. Can use a gov't bond)
SharpeRatio <- (AnnualizedReturn - rf)/Standev

#Print the results
print(paste("The trend-following algorithm was applied to the AAP Stock prices and was able to achieve an Annualized Return of", AnnualizedReturn,"%"))



#ppt
plot(Data$AAPPrices, type = "l", col = "red", xlab = "Prices")
par(new = TRUE)
plot(Data$SMA12, type = "l" , col = "green")
par(new = TRUE)
plot(Data$SMA26, type = "l" , col = "blue")

### Note, calculate stock returns log(difference) = log of the first order difference in stock prices.
















