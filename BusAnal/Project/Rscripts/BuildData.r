library( caret )

set.seed( 123457 )

rm( list = ls() )

datatab <- read.csv( "csvs//IndicatorTest.csv", header=TRUE )

Desc <- read.csv( "csvs//Desc_Info.csv", header=TRUE )

print( nrow( datatab))
print( nrow(Desc))

missing <- setdiff( datatab$BugID,Desc$BugID )
print( missing )
zero <- rep( 0, length(missing ))

for(i in 1:length(missing) ){
	zero[1] = i
	Desc <- rbind( Desc, zero )
}
print( nrow(Desc))
print( names( Desc ) )

Desc <- Desc[order(Desc$BugID),]

for( j in 2:ncol(Desc)) {
	#datatab[,names(Desc)[j]] <- Desc[,j]
}

print( names( datatab ) )

nCols <-ncol( datatab )

datatab[is.na(datatab)] <- 0






nullVector <- numeric( nrow(datatab))

CC_CrossCounter <- 0
Assignees <- grep( "CC_", names(datatab) )
for( i in 2:length(Assignees) ){
	for( j in 1:(i-1) ){
			datatab[,paste("CC_Cross", as.character(CC_CrossCounter), sep="")] <- datatab[,Assignees[i]]*datatab[,Assignees[j]]
			CC_CrossCounter <- CC_CrossCounter + 1
	}
}

#CC_CrossCounter <- 0
#Assignees <- grep( "Severity_", names(datatab[1:nCols]) )
#AssignedTo <- grep( "Product_", names(datatab[1:nCols] ) )


#for( i in 1:length(Assignees) ){
#	for( j in 1:length( AssignedTo) ){
#		if( all(datatab[,Assignees[i]]*datatab[,AssignedTo[j]] == nullVector) )
#			next
#		datatab[,paste(names(datatab)[Assignees[i]],"_CROSS_", names(datatab)[AssignedTo[j]], sep="")] <- datatab[,Assignees[i]]*datatab[,AssignedTo[j]]
#	}
#}





BugStatus <- grep( "BugStatus_MULTIPLE_*", names(datatab[1:nCols] ))
print( BugStatus )
StatusList <- numeric( 6 )
StatusCounter <- 1
for( i in 1:length( BugStatus ) ){
	name <- gsub('[0-9]+', '', names(datatab[1:nCols])[BugStatus[i]])
	if( name %in% StatusList ){
		
	}
	else{
		StatusList[StatusCounter] <- name
		StatusCounter <- StatusCounter + 1
	}
}
print( StatusList )

for( i in 2:length(StatusList) ){
	for( j in 1:(i-1) ){
	
			#print( StatusList[i] )
			#print( StatusList[j] )
			
			ColI <- grep( paste( StatusList[i], "*", sep="" ), names(datatab)[1:nCols])
			ColJ <- grep( paste( StatusList[j], "*", sep="" ), names(datatab)[1:nCols])
	
			firstVolume <- apply(datatab[,ColI], 1, sum)
			secondVolume <- apply(datatab[,ColJ], 1, sum)
			
			#datatab[,paste("BugStatus_Cross_", StatusList[i],"_", StatusList[j], sep="")] <- firstVolume*secondVolume
	}
}


trainSet <- createDataPartition( y=datatab$Fixed,p =.6, list=FALSE )

#train <- datatab[trainSet,2:ncol(datatab)]
#test <- datatab[-trainSet,2:ncol(datatab)]
train <- datatab[trainSet,2:nCols]
test <- datatab[-trainSet,2:nCols]

#TrainSet <- floor( nrow( datatab )*.6)

#train_ind <- sample(seq_len(nrow(datatab)), size = TrainSet)

#train <- datatab[train_ind,2:nCols ]
#test <- datatab[-train_ind,2:nCols ]

saveRDS(train, "Models//train.rds")
saveRDS( test, "Models//test.rds" )

