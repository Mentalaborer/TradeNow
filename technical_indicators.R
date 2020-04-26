
## Purpose is to generate a data frame of technical indicators 
# based on the closing price of a focal stock.  Eventually, want to use this for ML 

source("global_filters.R")

## NEXT:  remove hard-coded values and add them to global options page


ti <- function(focal_stock){

sma <-SMA(Cl(focal_stock),n=20)
ema <-EMA(Cl(focal_stock),n=20)
bb <-BBands(Cl(focal_stock),s.d=2)

# two day momentum based on closing price
m <- momentum(Cl(focal_stock), n=2)

# two day ROC
roc <- ROC(Cl(focal_stock),n=2)
macd <- MACD(Cl(focal_stock), nFast=12, nSlow=26,
             nSig=9, maType=SMA)

# 14 day rsi
rsi <- RSI(Cl(focal_stock), n=14)

tech_ind <- merge.xts(sma, ema, bb, m, roc, macd, rsi)

}

df_indicators <- ti(focal_stock)


head(df_indicators)



