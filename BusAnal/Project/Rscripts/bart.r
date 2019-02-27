rm( list = ls() )

library( ROCR )
library( caret )
options( java.parameters="-Xmx5000m")
library( bartMachine )
library( rJava )

set_bart_machine_num_cores(4)

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

trainSet$Fixed <- make.names(factor( trainSet$Fixed ))
#testSet$Fixed <- factor( testSet$Fixed )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3,classProbs=TRUE )

grid <- expand.grid( num_trees=5, alpha=.95, beta=2,k=2,nu=3 )

Model <- train( Fixed ~.,data=trainSet, method ="bartMachine",metric="auc", trControl = Controler, tuneGrid=grid,mem_cache_for_speed=FALSE )
summary( Model )
ppred <- predict( Model, newdata=testSet, type="prob" )


pred <- prediction(ppred$X1, testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//bart.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="BART ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()



