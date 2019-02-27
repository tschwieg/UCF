library( caret )
library( ROCR )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

#names( trainSet )


Controler <- trainControl( method="none", allowParallel=TRUE, number=3 )

LinearRegression <- train( Fixed ~.,data=trainSet, method ="lm", trControl = Controler )
summary( LinearRegression )

names( testSet[,-1] )
predLM <- predict( LinearRegression , newdata=testSet[,-1], type="raw" )
pred <- prediction(predLM, testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//LinearRegression.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Linear Regression ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()


saveRDS( LinearRegression, "Models//LinR_Model.rds" )
