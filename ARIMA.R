  library('ggplot2')
  library('forecast')
  library('tseries')
  
  daily_data = read.csv("calendar_730.csv", header=TRUE, stringsAsFactors=FALSE)
  daily_data$date = as.Date(daily_data$date)
  daily_data = na.omit(daily_data)
  
onlyprice = ts(daily_data$price, frequency = 12)
decomp = stl(onlyprice, s.window="periodic")
deseasonal_cnt <- seasadj(decomp)
plot(decomp)
plot(deseasonal_cnt)
adf.test(deseasonal_cnt, alternative = "stationary")

#diffprice = diff(deseasonal_cnt, differences = 1)
#adf.test(diffprice, alternative = "stationary")


fit<-auto.arima(deseasonal_cnt, seasonal=FALSE)
#tsdisplay(residuals(fit), lag.max=45, main='(1,1,1) Model Residuals')
fcast<-forecast(fit,h=30)
plot(fcast)

#res_fit = residuals(fit)
#Box.test(res_fit, lag=20, type = "Ljung-Box")
#fcast<-forecast(res_fit, h=30)
#plot(fcast)
#hold <- window(ts(daily_data$price), start=650)
#fit_no_holdout = auto.arima(ts(daily_data$price[-c(650:730)]), seasonal=TRUE)
#fcast_no_holdout <- forecast(fit_no_holdout,h=80)
#plot(fcast_no_holdout, main=" ")
#accuracy(fcast_no_holdout)
#summary(fcast_no_holdout)
