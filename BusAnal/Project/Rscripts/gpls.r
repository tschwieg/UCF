library( ROCR )
library( caret )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

trainSet$Fixed <- make.names(factor( trainSet$Fixed ))
#testSet$Fixed <- factor( testSet$Fixed )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3,classProbs=TRUE )

grid <- expand.grid( K.prov=1 )

Model <- train( Fixed ~.,data=trainSet, method ="gpls",metric="auc", trControl = Controler, tuneGrid=grid )

ppred <- predict( Model, newdata=testSet, type="prob" )


pred <- prediction(ppred$X1, testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//Boosting.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Boosting ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()













