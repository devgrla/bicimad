data_set <- read.table('data_final', sep = ',', header = TRUE, fileEncoding = 'UTF8')

test <-data.frame(data_set)
test$X <- test$season <- test$temp_media <- test$weekend <- NULL
test$year <- factor(test$year)
test$month <- factor(test$month)
test$day <- factor(test$day)
test$unicom <- factor(test$unicom)
test$holiday <- factor(test$holiday)
test2 <- data.frame(test)
test2 <- na.omit(test2)

test4 <- test2[, c("anual_total_use_day", "precipitation", "temp_max", "temp_min", "wind_speed",
                   "dioxido_nitrogeno", "min_sun")]
library(corrplot)
res <- cor(test4, method = c("pearson", "kendall", "spearman"))
corrplot(res, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

poi.mod <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
               + dioxido_nitrogeno + day + month + year + min_sun + holiday 
               + unicom, family = poisson, data = test2)
exp(poi.mod$coef)
summary(poi.mod)

c(deviance = poi.mod$deviance, d.f = poi.mod$df.residual)


n_groups <- 10

mascara <- sample(rep(1:n_groups, nrow(test2) / n_groups), nrow(test2), replace = TRUE)

tmp <- lapply(1:n_groups, function(i){
  modelo <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                + dioxido_nitrogeno + day + month + year + min_sun + holiday 
                + unicom, family = poisson, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo, tmp, type = "response")
  tmp
})

res <- do.call(rbind, tmp)
rmse_poi <- sqrt(mean((res$anual_total_use_day - res$preds)^2))

tmp <- lapply(1:n_groups, function(i){
  modelo2 <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                 + dioxido_nitrogeno + day * month * year + min_sun + holiday 
                 + unicom, family = poisson, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo2, tmp, type = "response")
  tmp
})

res2 <- do.call(rbind, tmp)

rmse_poi2 <- sqrt(mean((res2$anual_total_use_day - res2$preds)^2))
plot(res2$preds, res2$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Poisson', xlab = 'Usos Predichos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")


poi.mod2 <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                + dioxido_nitrogeno + day * month * year + min_sun + holiday 
                + unicom, family = poisson, data = test2)

exp(poi.mod2$coef)
summary(poi.mod2)


c(deviance = poi.mod2$deviance, d.f = poi.mod2$df.residual)


library(MASS)

nb.mod <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                 + dioxido_nitrogeno + day + month + year + min_sun + holiday 
                 + unicom, link = log, data = test2)

exp(nb.mod$coef)
summary(nb.mod)

c(theta = summary(nb.mod)$theta, deviance = nb.mod$deviance, d.f = nb.mod$df.residual)


tmp <- lapply(1:n_groups, function(i){
  modelo3 <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + day * month * 
                   year + min_sun + holiday + unicom, link = log, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo3, tmp, type = "response")
  tmp
})

resbn <- do.call(rbind, tmp)

rmse_bn <- sqrt(mean((resbn$anual_total_use_day - resbn$preds)^2))

plot(resbn$preds, resbn$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Poisson', xlab = 'Usos Predichos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")


nb.mod2 <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + day + month 
                  + year + min_sun + holiday + unicom, link = log, data = test2)

library(mvinfluence)
influencePlot(poi.mod2, ylim=c(-60,90), main = 'Variación Residual Poisson')
influencePlot(nb.mod, ylim=c(-60,90), main = 'Variación Residual Binomial Negativa')

anova(nb.mod, nb.mod2)
anova(nb.mod2, poi.mod)

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
tg_RF = expand.grid(.mtry=c(6:16),.ntree=c(100, 500, 2000, 5000))

custom <- train(anual_total_use_day ~ .,
                data = test2,
                method = customRF,
                metric = "RMSE", 
                tuneGrid=tg_RF,  
                trControl=tc_RF)

summary(custom)
plot(custom)
custom$bestTune


tg_RF2 = expand.grid(.mtry=c(6:13),.ntree=c(100, 500, 2000, 5000))

custom2 <- train(anual_total_use_day ~ .,
                data = test3,
                method = customRF,
                metric = "RMSE", 
                tuneGrid=tg_RF2,  
                trControl=tc_RF)

summary(custom2)
plot(custom2)
custom2$bestTune

rf <- randomForest(anual_total_use_day ~ ., mtry = 16, ntree = 5000, importance = TRUE, data = test2)
varImpPlot(rf)

tmp <- lapply(1:n_groups, function(i){
  modelo3 <- randomForest(anual_total_use_day ~ ., mtry = 16, ntree = 5000, data = test2[mascara != i,])
  tmp <- test2[mascara == i,]
  tmp$preds <- predict(modelo3, tmp)
  tmp
  })

resrf <- do.call(rbind, tmp)
rmse_rf <- sqrt(mean((resrf$anual_total_use_day - resrf$preds)^2))

plot(resrf$preds, resrf$anual_total_use_day, ylim=c(1000,15500), xlim=c(1000,15500), 
     main = 'Real vs. Predicciones Random Forest', xlab = 'Usos Predichos', ylab = 'Usos Reales')
abline(a = 0, b = 1, col = "red")


library(DALEX)
library(ceterisParibus)


tst1 <- tst[, c("anual_total_use_day", "precipitation", "temp_max", "temp_max2", "temp_min", "dioxido_nitrogeno", "day",
                "month", "year", "holiday", "unicom", "min_sun")]

poi.mod <- glm(anual_total_use_day ~ precipitation + temp_max + temp_max2 + temp_min 
                + dioxido_nitrogeno + day + month + year + min_sun + holiday 
                + unicom, family = poisson, data = tst1)

tst2 <- tst[, c("anual_total_use_day", "precipitation", "temp_max", "temp_max2", "day",
                "month", "year", "holiday", "unicom", "min_sun")]

nb.mod <- glm.nb(anual_total_use_day ~ precipitation + temp_max + temp_max2 + day + month 
                  + year + min_sun + holiday + unicom, link = log, data = tst2)

tstrf <- tst[, c("anual_total_use_day", "date", "precipitation", "temp_max", "temp_min", "dioxido_nitrogeno", "day",
                "month", "year", "holiday", "unicom", "min_sun", "wind_speed", "weekend")]

rf <- randomForest(anual_total_use_day ~ ., mtry = 14, ntree = 5000, importance = TRUE, data = tst)

explainer_poi<- explain(poi.mod, data = tst1[,2:12], y = tst1$anual_total_use_day)
explainer_nb<- explain(nb.mod, data = tst2[,2:10], y = tst2$anual_total_use_day)
explainer_rf<- explain(rf, data = tst[,2:14], y = tst$anual_total_use_day)

explainer_rf2<- explain(rf, data = tstrf[,2:14], y = tstrf$anual_total_use_day)

new <- tst[400, ]
new1 <- tst1[400, ]
new2 <- tst2[400, ]

wi_poi <- what_if(explainer_poi, observation = new1)
wi_nb <- what_if(explainer_nb, observation = new2)
wi_rf <- what_if(explainer_rf, observation = new)
wi_rf2 <- what_if(explainer_rf2, observation = new)

plot(wi_nb, ylim=c(0,18000))
plot(wi_poi)
plot(wi_rf2)
plot(wi_nb, wi_poi)

