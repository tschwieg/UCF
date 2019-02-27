library( ROCR )
library( caret )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3 )

grid <- expand.grid( cost=1, Loss="L2" )


svmModel <- train( Fixed ~.,data=trainSet, method ="svmLinear3",metric="auc", trControl = Controler, tuneGrid=grid)

summary( svmModel )

svmPredict <- predict( svmModel, newdata=testSet, type="raw" )

summary(svmPredict)

pred <- prediction(svmPredict, testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values[1]
zperf <- performance( pred,"tpr","fpr" )
pdf( "PDF//SVM.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="SVM ROCR Curve" , sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()

saveRDS( svmModel, "Models//SVM_Model.rds" )


