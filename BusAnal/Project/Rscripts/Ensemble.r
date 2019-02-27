library( ROCR )
library( caret )
library("caretEnsemble")

rm( list = ls() )

trainSet <- readRDS("Models//train.rds")
testSet <- readRDS( "Models//test.rds" )


#trainSet <- trainSet[1:10000,]
trainSet$Fixed <- make.names(factor( trainSet$Fixed ))

Controler <- trainControl( method="cv",savePredictions="final", allowParallel=TRUE, number=1,classProbs=TRUE, summaryFunction=twoClassSummary, index=createResample( trainSet$Fixed,1))


model_list <- caretList(
  Fixed~., data=trainSet,
  trControl=Controler,
  metric="auc",
  #methodList=c("svmLinearWeights2", "glm", "lda", "ranger", "xgbTree"),
  methodList=c("glm","lda"),
  tuneList=list(
    #svm=caretModelSpec(method="svmLinearWeights2",tuneGrid=expand.grid( cost=1,Loss=1, weight=1 ) ),
    log=caretModelSpec(method="glm" ),
    lda=caretModelSpec(method="lda" )#,
    #rf=caretModelSpec(method="ranger", tuneGrid=expand.grid( mtry=floor(sqrt(ncol(trainSet)-1)), splitrule="gini" ), preProcess="pca"),
    #boost=caretModelSpec(method="xgbTree", tuneGrid=expand.grid( eta=.1, max_depth=10, nrounds=165, gamma=0, subsample=1, min_child_weight=1, colsample_bytree=1 ))
  )
)


greedy_ensemble <- caret	Stack(
  model_list,
  method="glm",
  metric="ROC",
  trControl=trainControl(
    method="cv",
    number=2,
    savePredictions="final",
    classProbs=TRUE,
    summaryFunction=twoClassSummary
  )
)


summary(greedy_ensemble)

ppred <- predict(greedy_ensemble, newdata=testSet, type="prob")

pred <- prediction(ppred$X1, testSet$Fixed)

perf <- performance(pred,"auc")
perf@y.values
zperf <- performance( pred,"tpr","fpr" )
pdf("PDF//Ensemble.pdf" )
plot( zperf, xaxis="tpr", yaxis="fpr", main="Ensemble ROCR Curve", sub=paste("AUC: ", toString(perf@y.values[1]) ) )
dev.off()