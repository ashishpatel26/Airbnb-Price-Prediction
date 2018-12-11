install.packages("bsts")
install.packages("dplyr")
install.packages("date")
install.packages("prophet")
install.packages("plotly")
install.packages("corrplot")
library(date)
library(dplyr)
library(bsts)     # load the bsts package
library(corrplot)
library(plotly)
library(prophet)

calendar <- read.csv(file="calendar_730.csv",header=TRUE, sep=",")
print(nrow(calendar))
sapply(calendar, mode)

calendar <- calendar %>%
  mutate(available = ifelse(available == "f",0,1))

price <- transform(calendar, price = as.numeric(price))
sapply(price, mode)



pr <- price$price

#mode(pr)
#class(pr)


#Create a new variable for BSTS Model
bsts_response <- price$price
(model_components <- list())
AddLocalLinearTrend #prefered trend selector assuming there is a linear regressions between time series
plot(pr, ylab = "")

price = subset(price, select = -c(available))


#Trend component
summary(model_components <- AddLocalLinearTrend(model_components, 
                                                y = pr))
#seasonal component
summary(model_components <- AddSeasonal(model_components, y = pr, 
                                        nseasons  = 52, season.duration = 7))

#Construct bsts model that only takes into account seasonality and trend
st_bsts_fit <- bsts(pr, model_components, niter = 1000)


#predict with 95% interval of confidence only using seasonality and trend
pred <- predict(st_bsts_fit, horizon = 120, quantiles = c(.05, .95))
plot(pred)

#Extract bsts prediction of seasonality, tend and cycle into Dataframe.
mu_bsts <- pred$mean



#Construct BSTS model using seasonality & trend and Xi regressors
bsts_fit <- bsts(pr ~ ., state.specification = model_components, 
                 data = price, niter = 1000)

plot(bsts_fit)
plot(bsts_fit, "predictors")
plot(bsts_fit, "coef")

colMeans(bsts_fit$coefficients)

#view coeffs
summary(bsts_fit)

#cumulative absolute one step ahead prediction errors
CompareBstsModels(list("ST" = st_bsts_fit,
                       "ST + reg" = bsts_fit),
                  colors = c("black", "red"))

#Construct BSTS model using seasonality & trend and Xi regressors forcing inclusion
bsts_fit1 <- bsts(pr ~ ., state.specification = model_components, 
                  data = price, niter = 1000, expected.model.size = 10) #passed to spike and slab

plot(bsts_fit1)
plot(bsts_fit1, "predictors")
plot(bsts_fit1, "coef")

colMeans(bsts_fit1$coefficients)



#compare the BSTS models
CompareBstsModels(list("ST" = st_bsts_fit,
                       "ST + reg" = bsts_fit,
                       "ST + forced reg" = bsts_fit1),
                  colors = c("black", "red", "blue"))



pred_bsts <- predict(st_bsts_fit, newdata = price , horizon = 120, quantiles = c(.05, .95))
plot(pred_bsts)


Date <- as.Date(calendar$date)
price_real <- price$price
price_Bsts <- pred_bsts$mean

bs_data <- data.frame(Date,  price_real , price_Bsts)
bs_new <- subset(bs_data, Date >'2019-5-24')
mean(abs((bs_new$price_real - bs_new$price_Bsts)/bs_new$price_real))




#Plot Real vs Baseline Of Bsts model
Date <- as.Date(calendar$date)
Bsts_price_Real <- price$price
Bsts_price_forecast <- price_Bsts

data <- data.frame(Date,  Bsts_price_Real, Bsts_price_forecast)
data$Date <- as.factor(data$Date)

p <- plot_ly(data, x = ~Date, y = ~Bsts_price_Real, name = 'Real', type = 'scatter', mode = 'lines',
             line = list(color = 'rgb(207,181,59)', width = 3)) %>%
  add_trace(y = ~Bsts_price_forecast, name = 'Forecast', line = list(color = 'rgb(22, 96, 167)', width = 3)) %>%
  layout(title = "Bsts Model Real Price vs Predicted Price",
         xaxis = list(title = "Date"),
         yaxis = list (title = "Price"))

print(p)