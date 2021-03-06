
## Purpose is to generate a data frame of technical indicators 
# based on the closing price of a focal stock.  Eventually, want to use this for ML 

source("global_filters.R")

## NEXT:  remove hard-coded values and add them to global options page


ti <- function(focal_stock){

sma_slow <-SMA(Cl(focal_stock),n=long_past_days)
sma_fast <- SMA(Cl(focal_stock),n=short_past_days)
ema <-EMA(Cl(focal_stock),n=short_past_days)
bb <-BBands(Cl(focal_stock), maType = 'SMA', n = long_past_days, sd=2)

# two day momentum based on closing price
m <- momentum(Cl(focal_stock), n=momentum_days)

# two day ROC
roc <- ROC(Cl(focal_stock),n=2)
macd <- MACD(Cl(focal_stock), nFast=short_past_days, nSlow=long_past_days,
             nSig=9, maType=EMA)

# 14 day rsi
rsi <- RSI(Cl(focal_stock), n=relative_strength_days, maType = "SMA")

tech_ind <- merge.xts(sma_slow, sma_fast, ema, bb, m, roc, macd, rsi)

}

df_indicators <- ti(focal_stock)


head(df_indicators)

















