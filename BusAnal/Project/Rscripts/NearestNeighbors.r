library( RANN )
library( ROCR )

train <- readRDS("train.rds")
test <- readRDS( "test.rds" )

myvar <- names(test) %in% "V2" 
xtrain <- train[!myvar]
ytrain <- train$V2

xtest <- test[!myvar]
ytest <- test$V2

Nn <- nn2( data=xtrain, query=xtest, k = 10 )
print( "Finished Nearest Neighbor" )

preds <- numeric( nrow( ytest ) )
	size <- ncol( Nn.idx )
for( i in 1:nrow( ytest ) ) {
	for( j in 1:size ) {
		preds[i] <- preds[i] + ytrain[Nn.idx[i,j]]/size
	} 
}



pred <- prediction(preds, ytest)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf( "NearestNeighbor.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="NN ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ))
dev.off()
