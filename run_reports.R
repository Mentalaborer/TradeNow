

#################
# Run Reports   #
#################

rmarkdown::render("stock_explore_report.Rmd")
rmarkdown::render("stock_forecast_report.Rmd")
rmarkdown::render("stock_tech_indicators_report.Rmd")

# next - make report of buy-sell