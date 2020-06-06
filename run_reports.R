

#################
# Run Reports   #
#################

rmarkdown::render("stock_explore_report.Rmd")
rmarkdown::render("stock_forecast_report.Rmd")
rmarkdown::render("stock_tech_indicators_report.Rmd")
rmarkdown::render("apply_strategy_report.Rmd")


# next - functionalize test strategy - 
# https://bookdown.org/kochiuyu/Technical-Analysis-with-R/trading-size.html