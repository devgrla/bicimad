library(lubridate)

ucstartdates <- dmy(c("07-01-2015", "06-04-2015", "24-09-2015", "07-01-2016", "03-04-2016", "13-09-2016", "08-01-2017", "17-04-2017", "10-09-2017", "07-01-2018", "02-04-2018", "16-09-2018"))
ucstopdates <- dmy(c("26-03-2015", "14-07-2015", "18-12-2015", "17-03-2016", "14-07-2016", "16-12-2016", "06-04-2017", "07-07-2017", "21-12-2017", "22-03-2018", "06-07-2018", "20-12-2018"))
ucdur <- ucstopdates - ucstartdates
ucinst <- unlist(mapply(function(s,d) as.character(s + ddays(1:d)),
                        ucstartdates, ucdur))

data_set <- read.table('data_set', sep = ',', header = TRUE, fileEncoding = 'UTF8')
data_set$date <- as.Date(data_set$date)
str(data_set)
data_set$unicom <- data_set$date %in% ymd(ucinst)

data_set2 <- read.table('data_final', sep = ',', header = TRUE, fileEncoding = 'UTF8')

test <-data.frame(data_set)
test$X <- test$season <- test$temp_media <- NULL
test$year <- factor(test$year)
test$month <- factor(test$month)
test$day <- factor(test$day)
test$weekend <- factor(test$weekend)
test$season <- 1
test$season[data_set$season == 'Primavera'] <- 2
test$season[data_set$season == 'Verano'] <- 3
test$season[data_set$season == 'Otoño'] <- 4
test$season <- factor(test$season)
test$unicom <- 1
test$unicom[data_set$unicom == FALSE] <- 0
test$unicom <- factor(test$unicom)
test$holiday <- factor(test$holiday)
test$temp_max2 <- test$temp_max * test$temp_max
test2 <- data.frame(test)
test2 <- na.omit(test2)


poi.mod <- glm(anual_total_use_day ~ date + precipitation + temp_max + temp_max2 + temp_min 
               + wind_speed + dioxido_nitrogeno + day + month + year + season 
               + weekend + min_sun + holiday + unicom, family = poisson, data = test2)
exp(poi.mod$coef)
summary(poi.mod)

n_groups <- 10

mascara <- sample(rep(1:n_groups, nrow(test2) / n_groups), nrow(test2), replace = TRUE)

tmp <- lapply(1:n_groups, function(i){
  modelo <- glm(anual_total_use_day ~ date + precipitation + temp_max + temp_max2 + temp_min 
                + dioxido_nitrogeno + day + month + year + min_sun + holiday 
                + unicom, family = poisson, data = test2c[mascara != i,])
  tmp <- test2c[mascara == i,]
  tmp$preds <- predict(modelo, tmp, type = "response")
  tmp
})

res <- do.call(rbind, tmp)
rmse_poi <- sqrt(mean((res$anual_total_use_day - res$preds)^2))
plot(res$preds, res$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500))
abline(a = 0, b = 1, col = "red")

poi.mod2 <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
               + dioxido_nitrogeno + day + month + year + min_sun + holiday 
               + unicom, family = poisson, data = test2)

exp(poi.mod2$coef)
summary(poi.mod2)

tmp <- lapply(1:n_groups, function(i){
  modelo2 <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                 + dioxido_nitrogeno + day * month * year + min_sun + holiday 
                 + unicom, family = poisson, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo2, tmp, type = "response")
  tmp
})

resv2 <- do.call(rbind, tmp)
rmse_poiv2 <- sqrt(mean((resv2$anual_total_use_day - resv2$preds)^2))
plot(resv2$preds, resv2$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Poisson', xlab = 'Usos Predichos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")


library(MASS)

nb.mod <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                 + dioxido_nitrogeno + day + month + year + min_sun + holiday 
                 + unicom, link = log, data = test2)

exp(nb.mod$coef)
summary(nb.mod)

tmp <- lapply(1:n_groups, function(i){
  modelo3 <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                    + dioxido_nitrogeno + day * month * year + min_sun + holiday 
                    + unicom, link = log, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo3, tmp, type = "response")
  tmp
})

res3 <- do.call(rbind, tmp)
rmse_bn <- sqrt(mean((res3$anual_total_use_day - res3$preds)^2))
plot(res3$preds, res3$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Binomial Negativo', xlab = 'Predicción Usos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")



tmp <- lapply(1:n_groups, function(i){
  modelo3 <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + day * month * year 
                    + min_sun + holiday + unicom, link = log, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo3, tmp, type = "response")
  tmp
})

res3 <- do.call(rbind, tmp)
rmse_bn2 <- sqrt(mean((res3$anual_total_use_day - res3$preds)^2))
plot(res3$preds, res3$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Binomial Negativo', xlab = 'Predicción Usos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")

nb.mod2 <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + day + month + year 
       + min_sun + holiday + unicom, link = log, data = test2)

anova(nb.mod, nb.mod2)

rf <- randomForest(anual_total_use_day ~ ., mtry = 16, ntree = 2500, importance = TRUE, data = test2)
varImpPlot(rf)


tmp <- lapply(1:n_groups, function(i){
  modelo <- randomForest(anual_total_use_day ~ ., mtry = 12, ntree = 5000, 
                          importance = TRUE, data = test3[mascara != i,])
  tmp <- test3[mascara == i,]
  tmp$preds <- predict(modelo, tmp)
  tmp
})

rfvc <- do.call(rbind, tmp)
rmse_rf3 <- sqrt(mean((rfvc$anual_total_use_day - rfvc$preds)^2))
plot(rfvc$preds, rfvc$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones', xlab = 'Predicción Usos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")

rf2 <- randomForest(anual_total_use_day ~ ., mtry = 12, ntree = 5000, importance = TRUE, data = test3)
varImpPlot(rf2)

testrf <- data.frame(test3)
testrf$date <- NULL

tmp <- lapply(1:n_groups, function(i){
  modelo <- randomForest(anual_total_use_day ~ ., mtry = 12, ntree = 5000, 
                         importance = TRUE, data = testrf[mascara != i,])
  tmp <- testrf[mascara == i,]
  tmp$preds <- predict(modelo, tmp)
  tmp
})

rfvc2 <- do.call(rbind, tmp)
rmse_rf4 <- sqrt(mean((rfvc2$anual_total_use_day - rfvc2$preds)^2))
plot(rfvc2$preds, rfvc2$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones', xlab = 'Predicción Usos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")

rf3 <- randomForest(anual_total_use_day ~ ., mtry = 12, ntree = 5000, importance = TRUE, data = testrf)
varImpPlot(rf3)


library(mvinfluence)
influencePlot(poi.mod2, ylim=c(-60,90), main = 'Variación Residual Poisson')
influencePlot(nb.mod, ylim=c(-60,90), main = 'Variación Residual Binomial Negativa')

library(caret)
library(randomForest)
library(mlbench)
library(e1071)
library(dplyr)

customRF <- list(type = "Regression",
                 library = "randomForest",
                 loop = NULL)

customRF$parameters <- data.frame(parameter = c("mtry", "ntree"),
                                  class = rep("numeric", 2),
                                  label = c("mtry", "ntree"))

customRF$grid <- function(x, y, len = NULL, search = "grid") {}

customRF$fit <- function(x, y, wts, param, lev, last, weights, classProbs) {
  randomForest(x, y,
               mtry = param$mtry,
               ntree=param$ntree)
}

customRF$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)

customRF$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")

customRF$sort <- function(x) x[order(x[,1]),]
customRF$levels <- function(x) x$classes


tc_RF <- trainControl(method = "cv", number = 5)
tg_RF = expand.grid(.mtry=c(6:17),.ntree=c(1000, 1500, 2000, 2500))

custom <- train(anual_total_use_day ~ .,
                data = test2,
                method = customRF,
                metric = "RMSE", 
                tuneGrid=tg_RF,  
                trControl=tc_RF)

summary(custom)
plot(custom, main = 'Optimización Modelo Random Forest')
custom$bestTune

tg_RF2 = expand.grid(.mtry=c(14:20),.ntree=c(1000, 1500, 2000, 2500))

custom2 <- train(anual_total_use_day ~ .,
                data = test2,
                method = customRF,
                metric = "RMSE", 
                tuneGrid=tg_RF2,  
                trControl=tc_RF)

summary(custom2)
plot(custom2, main = 'Optimización Modelo Random Forest')
custom2$bestTune


tg_RF3 = expand.grid(.mtry=c(19:30),.ntree=c(1000, 1500, 2000, 2500))

custom3 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF3,  
                 trControl=tc_RF)

summary(custom3)
plot(custom3, main = 'Optimización Modelo Random Forest')
custom3$bestTune


tg_RF4 = expand.grid(.mtry=c(27:35),.ntree=c(1000, 1500, 2000, 2500))

custom4 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF4,  
                 trControl=tc_RF)

summary(custom4)
plot(custom4)
custom4$bestTune


tg_RF5 = expand.grid(mtry = seq(30, 80, by = 10),  ntree = c(1000, 1500, 2000, 2500))

custom5 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF5,  
                 trControl=tc_RF)

plot(custom5)


tg_RF6 = expand.grid(mtry = seq(80, 110, by = 5),  ntree = c(1000, 1500, 2000, 2500))

custom6 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF6,  
                 trControl=tc_RF)
plot(custom6)
custom6$bestTune


tg_RF7 = expand.grid(mtry = seq(110, 140, by = 5),  ntree = c(1000, 1500, 2000, 2500))

custom7 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF7,  
                 trControl=tc_RF)
plot(custom7)

tg_RF8 = expand.grid(mtry = seq(100, 110, by = 2),  ntree = c(1000, 1500, 2000, 2500))

custom8 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF8,  
                 trControl=tc_RF)
plot(custom8)


tg_RF9 = expand.grid(mtry = seq(100, 200, by = 10),  ntree = c(1000, 1500, 2000, 2500))

custom9 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF9,  
                 trControl=tc_RF)
plot(custom9)


tg_RF10 = expand.grid(mtry = seq(1, 5, by = 1),  ntree = c(1000, 1500, 2000, 2500))

custom10 <- train(anual_total_use_day ~ .,
                 data = test2,
                 method = customRF,
                 metric = "RMSE", 
                 tuneGrid=tg_RF10,  
                 trControl=tc_RF)
plot(custom10)


tg_RF11 = expand.grid(mtry = seq(96, 108, by = 2),  ntree = c(1000, 1500, 2000, 2500))

custom11 <- train(anual_total_use_day ~ .,
                  data = test2,
                  method = customRF,
                  metric = "RMSE", 
                  tuneGrid=tg_RF11,  
                  trControl=tc_RF)
plot(custom11)

tg_RF12 = expand.grid(mtry = seq(99, 104, by = 1),  ntree = c(1000, 1500, 2000, 2500))

custom12 <- train(anual_total_use_day ~ .,
                  data = test2,
                  method = customRF,
                  metric = "RMSE", 
                  tuneGrid=tg_RF12,  
                  trControl=tc_RF)
plot(custom12)


test3 <- test2[, c("anual_total_use_day", "date", "precipitation", "temp_max", "temp_max2", "temp_min", "wind_speed",
                    "dioxido_nitrogeno", "month", "year", "day", "min_sun", "holiday", "unicom")]


tg_RF13 = expand.grid(.mtry=c(6:17),.ntree=c(100, 500, 1000, 2500))

custom13 <- train(anual_total_use_day ~ .,
                data = test3,
                method = customRF,
                metric = "RMSE", 
                tuneGrid=tg_RF13,  
                trControl=tc_RF)

summary(custom13)
plot(custom13)
custom13$bestTune

n_groups <- 10

mascara <- sample(rep(1:n_groups, nrow(test2) / n_groups), nrow(test2), replace = TRUE)

tmp <- lapply(1:n_groups, function(i){
  modelorf <- randomForest(anual_total_use_day ~ ., mtry = 16, ntree = 5000, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelorf, tmp)
  tmp
})

resrf2 <- do.call(rbind, tmp)
rmse_crf4 <- sqrt(mean((resrf2$anual_total_use_day - resrf2$preds)^2))
plot(resrf2$preds, resrf2$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Best RF', xlab = 'Predicción Usos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")



test4 <- test3[, c("anual_total_use_day", "precipitation", "temp_max", "temp_min", "wind_speed",
                   "dioxido_nitrogeno", "min_sun")]

colnames(test4) <- c("anual_total_use_day", "precipitation", "temp_max", "temp_min", "wind_speed", "dioxido_nitrogeno", "min_sun")

library(corrplot)
res <- cor(test4, method = c("pearson", "kendall", "spearman"))
corrplot(res, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)


test5 <- test2[, c("precipitation", "temp_max", "temp_max2", "temp_min", "wind_speed",
          "dioxido_nitrogeno", "min_sun")]

testx <- scale(test5)
testx <- data.frame(testx)
testx2 <- data.frame(test2)
testx2$precipitation <- testx$precipitation
testx2$temp_max <- testx$temp_max 
testx2$temp_max2 <- testx$temp_max2 
testx2$temp_min <- testx$temp_min 
testx2$wind_speed <- testx$wind_speed 
testx2$dioxido_nitrogeno <- testx$dioxido_nitrogeno 
testx2$min_sun <- testx$min_sun 

tmp <- lapply(1:n_groups, function(i){
  modelorf <- randomForest(anual_total_use_day ~ ., mtry = 16, ntree = 5000, data = testx2[mascara != i,])
  tmp <- testx2[mascara == i,]
  tmp$preds <- predict(modelorf, tmp)
  tmp
})

resnrf <- do.call(rbind, tmp)
rmse_nrf <- sqrt(mean((resnrf$anual_total_use_day - resnrf$preds)^2))
plot(resnrf$preds, resnrf$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500))
abline(a = 0, b = 1, col = "red")

test$dif_temp <- test$temp_max - test$temp_min
testt <- na.omit(test)
  plot(test$dif_temp)



plot(a$month, a$anual_total_use_day, data = a)
plot(b$month, b$anual_total_use_day, data = b)
plot(c$month, c$anual_total_use_day, data = c)
plot(d$month, d$anual_total_use_day, data = d)

plot(a$day, a$anual_total_use_day, data = a)
plot(b$day, b$anual_total_use_day, data = b)
plot(c$day, c$anual_total_use_day, data = c)
plot(d$day, d$anual_total_use_day, data = d)

a <- test2[test2$year == 2015,]
b <- test2[test2$year == 2016,]
c <- test2[test2$year == 2017,]
d <- test2[test2$year == 2018,]
