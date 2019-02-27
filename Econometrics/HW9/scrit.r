library(ggplot2)
dataHorse <- read.table("PrussianArmy.dat", header=FALSE )

dataHorse <- dataHorse[order( dataHorse$V2 ),]

names(dataHorse) <- c("Year", "Corps", "V3" )

simpleGLM <- glm( formula= V3 ~ 1, family=poisson, data=dataHorse )

print( summary( simpleGLM ) )

print( exp(simpleGLM$coefficients[1] ) )

pdf("plot.pdf")

pot <-  ggplot( dataHorse, aes( x = 1:nrow(dataHorse), y = simpleGLM$residuals))
pot + geom_point( aes(color = Corps, shape = Corps )) + scale_shape_manual( values = 1:14 )

dev.off()

lvl <- levels( dataHorse$Corps )
year <- unique( dataHorse$Year)

dummyData <- matrix(0, nrow = nrow(dataHorse), ncol = (length(lvl)+length(year)-1))

dummyData[,1] <- dataHorse[,3]

for( i in 2:length(lvl )){
    dummyData[,i] <- as.integer(dataHorse[,2] == lvl[i] )
}

for (i in 2:length(year)){
    dummyData[,length(lvl)+i-1] <- as.integer( dataHorse[,1] == year[i] )
}

complexGLM <- glm( formula=X1~., family=poisson, data=data.frame(dummyData) )

print( summary( complexGLM ) )


pValue <- pchisq( 2*(logLik(complexGLM) - logLik(simpleGLM )), df = 32,lower.tail = FALSE )
print( pValue )
