

source("global_filters.R")



dygraph(focal_stock_adjusted, main = "Logi Stock Price") %>%
  dyRangeSelector(dateWindow = c("2020-01-01", "2020-07-03"))


## Function not work - need to fix


mov_avgs<-function(focal_df){
  stock_close<-focal_df$focal_Adjusted
  ifelse((nrow(focal_df)<(1*260)),
         x<-data.frame(focal_df, 'NA', 'NA'),
         x<-data.frame(focal_df, SMA(stock_close, 200), SMA(stock_close, 50)))
  colnames(x)<-c(names(focal_df), 'sma_200','sma_50')
  x<-x[complete.cases(x$sma_200),]
  return(x)
}


focal_moving_avg<-pblapply(focal_stock, mov_avgs)


dygraph(focal_moving_avg$focal_Adjusted[,c('sma_200','sma_50')],main = 'Moving Averages') %>%
  dySeries('sma_50', label = 'sma 50') %>%
  dySeries('sma_200', label = 'sma 200') %>%
  dyRangeSelector(height = 30) %>%
  dyShading(from = '2020-4-28', to = '2020-5-31', color = '#CCEBD6') %>%
  dyShading(from = '2020-6-1', to = '2020-7-1', color = '#FFE6E6')




