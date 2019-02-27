library( ROCR )
library( LiblineaR )
library( caret )

rm( list = ls() )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )

print( ncol( trainSet ) )

#LogitModel <- glm( formula = Fixed ~., data=trainSet, family=binomial )

Controler <- trainControl( method="none", allowParallel=TRUE, number=3 )
LogitModel <- train( Fixed ~.,data=trainSet, method ="glm", family=binomial, trControl = Controler )
summary( LogitModel )




predLogit <- predict( LogitModel , newdata=testSet[,-1], type="raw", se.fit = FALSE )


pred <- prediction(predLogit, testSet$Fixed)


perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//LogisticRegression.pdf")
plot( zperf, xaxis="tpr", yaxis="fpr", main="Logistic Regression", sub=paste("AUC: ", toString(perf@y.values[1]) ) )



#saveRDS(predLogit, "Models//LogR_Predict.rds")
saveRDS( LogitModel, "Models//LogR_Model.rds" )
                          
