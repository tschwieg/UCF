library( ROCR )

library( xgboost )

train <- readRDS("Models//train.rds")
test <- readRDS( "Models//test.rds" )

xtrain <- train[,2:ncol(train)]
ytrain <- train$Fixed

xtest <- test[,2:ncol(test)]
ytest <- test$Fixed

xtrain <- sapply( xtrain, as.numeric )
xtest <- sapply( xtest, as.numeric )

crossValidator <- xgb.cv( data=data.matrix( xtrain ), label=data.matrix(ytrain ), eta =.1, max_depth=10, metrics="auc", nfold=3, maximize = TRUE, early_stopping_rounds = 5, nrounds= 1000, objective="binary:logistic" )

#Model <- xgboost( data=data.matrix( xtrain ), label=data.matrix(ytrain ), eta =.1, max_depth=10, metrics="auc", nrounds = 113 )

#ppred <- predict( Model, newdata=xtest, type="response" )

#pred <- prediction(ppred, ytest)

#perf <- performance(pred,"auc")
#perf@y.values
#zperf <- performance( pred,"tpr","fpr" )
#pdf("PDF//Boosting.pdf" )
#plot( zperf, xaxis="tpr", yaxis="fpr", main="Linear Regression ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
#dev.off()

#summary( crossValidator )







