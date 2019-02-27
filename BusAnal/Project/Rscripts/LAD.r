library( Blossom )
library( ROCR )

train <- readRDS("train.rds")
test <- readRDS( "test.rds" )

myvar <- names(test) %in% "V2" 
xtrain <- train[!myvar]
ytrain <- train$V2

xtest <- test[!myvar]
ytest <- test$V2


ladModel <- lad( formula=V2~., data=train )
summary( ladModel )

ladPredict <- predict( ladModel, newdata=test, type="response" )
pred <- prediction(ladPredict, ytest)

perf <- performance(pred,"auc")
perf@y.values

saveRDS(ladPredict, "LAD_Predict.rds")
saveRDS( ladModel, "LAD_Model.rds" )
