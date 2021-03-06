



#### DEPRECATED ##### 



## Purpose is to explore past performance, see autocorrelation and 
# forecast the adjusted stock price for X days in the future


library(zoo)
library(tseries)
library(urca)
library(PerformanceAnalytics)
library(quantmod)
library(xts)
library(tseries)
library(quantmod)
library(PerformanceAnalytics)

# global options:
lag.max = 10 # days to look back
h = 5 # days to predict ahead (if change, then need to change dates) 
historical_prices = 30 # x number of days of historical data to plot


# load symbols

# symbols is from the fetch_data script but should source directly, OR
data_env <- new.env()

# call a specific symbol directly
focal_stock <- getSymbols('FB', src = "yahoo", from = "2020-01-01",
           auto.assign = F, return.class = "xts", env = data_env)


colnames(focal_stock) <- paste("focal", 
                             c("Open", "High", "Low", "Close", "Volume", "Adjusted"), 
                             sep = "_")

# selct adjusted column only
focal_stock_adjusted <- focal_stock$focal_Adjusted

plot(focal_stock_adjusted, col="darkred", main="focal_stock Price Series") 

# Stationarity testing
StationarityTest = ur.df(focal_stock_adjusted,type="none",selectlags = "AIC")
summary(StationarityTest)

#Stationarity Tesing on first Differences
Stationarity_Diff= ur.df(diff(focal_stock_adjusted)[2:dim(focal_stock_adjusted)[1],], type = "none", selectlags = "AIC")
summary(Stationarity_Diff)

# Plot the graph on first differences
D.focal_stock_adjusted= focal_stock_adjusted-lag(focal_stock_adjusted)
plot(D.focal_stock_adjusted, col="red4", main = "focal_stock_adjusted On First Differences")

ggAcf(D.focal_stock_adjusted, lag.max = lag.max) + theme_bw()

# Plot Autocorrelation

# How is the price today related to the past? 
# Are the correlations large and positive for several lags? When decay?
acf(focal_stock_adjusted, lag.max = lag.max, plot = T)

## AUTOREGRESSIVE MODEL using AUTO ARIMA
# Most widely used time series model
# It’s like simple linear regression, each observation is regressed on the previous observation.

# a function in R to do auto.arima, and it just goes through 
# and test all these combinations and automatically 
# selects a good choice for your p, d and q, your three parameters 
# for your autoregressive component, your integrated component, and your moving average component.

fitted_arima <- auto.arima(focal_stock_adjusted)
arima_forecast <- forecast(fitted_arima, h)
arima_sweep <- sw_sweep(arima_forecast)

# residual analysis:  How well does model fit the data?
ts.plot(focal_stock_adjusted)
ar_focal_fitted <- focal_stock_adjusted - residuals(arima_forecast)
points(ar_focal_fitted, type = "l", col = "red", lty = 2)

# prep for visualization of predictions

# Note = h must match the dates here #
dates <- c(index(focal_stock_adjusted), 
           index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 1, 
           index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 2, 
           index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 3, 
           index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 4, 
           index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 5)
        #  index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 6,
        #  index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 7,
         # index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 8,
        #  index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 9,
         # index(focal_stock_adjusted)[length(focal_stock_adjusted)] + 10)

arima_sweep <- add_column(arima_sweep, dates)

# Plotting historical prices (actual) and predictions
arima_sweep_display<- arima_sweep[(dim(arima_sweep)[1]-historical_prices):dim(arima_sweep)[1], ]
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
  ## Aesthetics
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_x_date(date_breaks = "2 days", date_labels = "%b %d") +
  labs(title = "focal_stock_adjusted 5 Days Ahead ARIMA Price Forecast", x = "", y = "")

# print predictions only
arima_sweep_display %>% 
  select(key, value, lo.95, hi.95, dates) %>%
  filter(key == 'forecast')
























