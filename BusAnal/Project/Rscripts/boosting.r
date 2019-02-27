library( ROCR )
library( caret )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

trainSet$Fixed <- factor( trainSet$Fixed )
#testSet$Fixed <- factor( testSet$Fixed )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3 )

grid <- expand.grid( eta=.1, max_depth=10, nrounds=165, gamma=0, subsample=1, min_child_weight=1, colsample_bytree=1 )

Model <- train( Fixed ~.,data=trainSet, method ="xgbTree",metric="auc", trControl = Controler, tuneGrid=grid )

ppred <- predict( Model, newdata=testSet, type="prob" )
summary( ppred )
names( ppred )

length( ppred[1] )
length( testSet$Fixed )

pred <- prediction(ppred[2], testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//Boosting.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Boosting ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()













