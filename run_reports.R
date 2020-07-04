

#################
# Run Reports   #
#################

rmarkdown::render("stock_explore_report.Rmd")
rmarkdown::render("stock_forecast_report.Rmd")
rmarkdown::render("explore_tech_indicators.Rmd")
rmarkdown::render("stock_tech_indicators_report.Rmd")
rmarkdown::render("apply_strategy_report.Rmd")


# code daily returns
# start - https://rstudio-pubs-static.s3.amazonaws.com/364194_96fa6ffa96d84b4ea95e831592214b97.html


# add in dynamic graphing and shading on graphs - 
# https://www.datacamp.com/community/tutorials/r-trading-tutorial#a