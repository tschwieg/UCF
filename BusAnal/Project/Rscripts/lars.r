library( ROCR )
library( caret )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

#trainSet$Fixed <- factor( trainSet$Fixed )
#testSet$Fixed <- factor( testSet$Fixed )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3 )

grid <- expand.grid( fraction=TRUE, step=FALSE )

Model <- train( Fixed ~.,data=trainSet, method ="lars2",metric="auc", trControl = Controler, tuneGrid=grid )

ppred <- predict( Model, newdata=testSet, type="prob" )
summary( ppred )
names( ppred )

length( ppred[1] )
length( testSet$Fixed )

pred <- prediction(ppred[2], testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//Lars.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Lars ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()













