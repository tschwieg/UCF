library( ROCR )
library( lars )

rm( list=ls() )

train <- readRDS("Models//train.rds")
test <- readRDS( "Models//test.rds" )




xtrain <- train[,2:ncol(train)]
ytrain <- train$Fixed

xtest <- test[,2:ncol(test)]
ytest <- test$Fixed

Reg <- lars( x=data.matrix(xtrain), y=data.matrix(ytrain), type="lasso",  trace=FALSE )


cvReg <- cv.lars( x=data.matrix(xtrain), y=data.matrix(ytrain), type="lasso",  trace=FALSE, K=5 )

summary( cvReg )

limit <- min( cvReg$cv) + cvReg$cv.error[which.min(cvReg$cv)]
sCv <- cvReg$index[min(which(cvReg$cv <limit))] 

ppred <- predict( Reg, newx=data.matrix(xtest), type="fit", s = sCv, mode="fraction" )
 

pred <- prediction(ppred$fit, ytest)

perf <- performance(pred,"auc")
perf@y.values


zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//ForwardStagewise.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Forward Stagewise ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()
