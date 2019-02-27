data <- read.table( "Galton.dat" )

sons <- data[data$V4==1,]
daughters <- data[data$V4==0,]
fathers <- unique( data[,1:2])


summary(sons$V5)
sd( sons$V5)
max( sons$V5 ) - min( sons$V5 )
IQR( sons$V5 )

summary( daughters$V5 )
sd( daughters$V5)
max( daughters$V5 ) - min( daughters$V5 )
IQR( daughters$V5 )

pdf( "Fathers.pdf" )
plot( x=sons$V2,y=sons$V5, xlab="Fathers", ylab="Sons")
dev.off()

GenerateEDF <- function( depth, frame, start, end ){
    EDF <- numeric( (end-start)*depth )
    i <- 0
    for( i in 1:length( EDF )){
        EDF[i] <- length( frame[frame<=(start+(i/depth))] ) / length( frame )
    }
    EDF
}


NormalKernal <- function( u ){
    (1/sqrt( 2*pi))*exp( (-1*u^2)/2.0 )
}

GenerateKernalSmoothHistogram <- function( depth, frame, start, end, kernal ){
    kSmooth <- numeric( (end-start)*depth )
    i <- 0
    h <- 1.06*sd(frame)*as.numeric(length(frame))^(-1.0/5.0)
    for( i in 1:length(kSmooth) ){
        kSmooth[i] <- 0
        y <- (start+(i/depth))
        for( j in 1:length(frame)){
            kSmooth[i] <- kSmooth[i] + kernal( (y - frame[j])/h )
        }
        kSmooth[i] <- kSmooth[i] / (length(frame)*h)
    }
    kSmooth
}

depth <-  100

start <- min( sons$V5, daughters$V5 )
end <- max( sons$V5, daughters$V5 )


sonEDF <- GenerateEDF( depth, sons$V5, start, end )
daughterEDF <- GenerateEDF( depth, daughters$V5, start, end )

pdf( "DaugherSonEDFs.pdf" )
inches <-  numeric( (end-start)*depth )
for( i in 1:length(inches)){
    inches[i] <- start + i/depth + 60
}

plot( x=inches, y=sonEDF, type="l", col="blue" )
lines( x=inches,y=daughterEDF, col="pink")
legend( 70,.2, legend=c("Sons","Daughters"), lty = c(1,1) , col=c("blue","pink"))
dev.off()

fatherEDF <- GenerateEDF( depth, fathers$V2, start, end )

pdf( "FatherSonEDF.pdf" )
plot( x = inches, y=fatherEDF, type="l", col="blue" )
lines(x=inches,y=sonEDF,col="red")
legend( 60,1, legend=c("Fathers","Sons"), lty = c(1,1) , col=c("blue","red"))
dev.off()

start <- min( sons$V5, daughters$V5 ) - 10
end <- max( sons$V5, daughters$V5 ) + 10

sonHist <- GenerateKernalSmoothHistogram( depth, sons$V5, start, end, NormalKernal )
daughterHist <- GenerateKernalSmoothHistogram( depth, daughters$V5, start, end, NormalKernal )
fatherHist <- GenerateKernalSmoothHistogram( depth, fathers$V2, start, end, NormalKernal )
inches <-  numeric( (end-start)*depth )
for( i in 1:length(inches)){
    inches[i] <- start + i/depth + 60
}

pdf( "Hists.pdf" )
plot( x=inches,y=fatherHist, type="l", col="blue" )
lines(x=inches,y=sonHist, col="red" )
legend( 80,.15, legend=c("Fathers","Sons"), lty = c(1,1) , col=c("blue","red"))
dev.off()
