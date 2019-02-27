simProbpi0 = .75
simProbpi1 = .25
numSims = 10000
curState = numeric( 10001 )
curState[1] = 0
probs = runif( numSims )

for(i in 1:numSims){
    if( curState[i] == 0){
        if( probs[i] > simProbpi0 ){
            curState[i+1] = 1
        }else{
            curState[i+1] = 0
        }
    }else{
        if( probs[i] > simProbpi1 ){
            curState[i+1] = 0
        }else{
            curState[i+1] = 1
        }
    }
}

simData <- matrix( , nrow = 2*numSims, ncol=5)
X = 0
for( i in 1:numSims ){
    if( curState[i] == 0 && curState[i+1] == 0 ){
        simData[i,] <- c( 1, 0, 0, 0, X)
    }else if( curState[i] == 0 && curState[i+1] == 1 ){
        simData[i,] <- c( 0, 1, 0,0, X )
    }else if( curState[i] == 1 && curState[i+1] == 0 ){
        simData[i,] <- c( 0,0,1,0, X)
    }else{
        simData[i,] <- c(0,0,0,1, X)
    }
}

simProbpi0 = .6
simProbpi1 = .3
numSims = 10000
curState = numeric( 10001 )
curState[1] = 0
probs = runif( numSims )

for(i in 1:numSims){
    if( curState[i] == 0){
        if( probs[i] > simProbpi0 ){
            curState[i+1] = 1
        }else{
            curState[i+1] = 0
        }
    }else{
        if( probs[i] > simProbpi1 ){
            curState[i+1] = 0
        }else{
            curState[i+1] = 1
        }
    }
}

X = 1
for( i in 1:numSims ){
    if( curState[i] == 0 && curState[i+1] == 0 ){
        simData[numSims+i,] <- c( 1, 0, 0, 0, X)
    }else if( curState[i] == 0 && curState[i+1] == 1 ){
        simData[numSims+i,] <- c( 0, 1, 0,0, X )
    }else if( curState[i] == 1 && curState[i+1] == 0 ){
        simData[numSims+i,] <- c( 0,0,1,0, X)
    }else{
        simData[numSims+i,] <- c(0,0,0,1, X)
    }
}

tonsilData <- data.frame( simData )

tonsilModel <-glm( formula=I( X2 + X4) ~ I(X5*(X1 + X2) ) + I( X5*(X3
    + X4) ) + I( (1-X5)*(X1 + X2)) + I( (1-X5)*(X3+X4)) - 1, family =
                                                                 binomial, data=tonsilData )

tonsilData <- read.table( 'Tonsils.dat', header=FALSE )

##Firstly, V5 is whether or not they have tonsils
##$V1 - D_{00}$
##$V2 - D_{01}$
##$V3 - D_{10}$
##$V4 - D_{11}$

## for the model X will be transformed into a tuple of 4 values:
## X = (start state 0, tonsils; start 1, tonsils; start 0, no tonsils; start 1, no tonsils )
## Y = end at state 1

tonsilModel <- glm( formula=I( V2 + V4) ~ I(V5*(V1 + V2) ) + I( V5*(V3
    + V4) ) + I( (1-V5)*(V1 + V2)) + I( (1-V5)*(V3+V4)) - 1, family =
                                                                 binomial, data=tonsilData )

noTonsilModel <-
    glm( formula = I( V2 + V4) ~ I(V1 + V2) + I(V3 + V4) - 1, family=binomial, data=tonsilData )

## Under tonsil Model:
## $P( Y = 0 | X = ( 0, 0, 1, 0 ) ) = \pi_{00}^N$
## $P( Y = 1 | X = ( 0, 0, 0, 1 ) ) = \pi_{11}^N$
## $P( Y = 0 | X = ( 1, 0, 0, 0 ) ) = \pi_{00}^W$
## $P( Y = 1 | X = ( 0, 1, 0, 0 ) ) = \pi_{11}^W$

## $\mathbb{E}[Y_i | X_i ] = \frac{1}{1 + \exp{( - \beta X_i )} }$


pi00.N <- 1.0 /
    ( 1.0 + exp( sum( tonsilModel$coefficients* c(0,0,1,0)) ) )

pi11.N <- 1.0 /
    ( 1.0 + exp( -sum( tonsilModel$coefficients* c(0,0,0,1)) ) )

pi00.W <- 1.0 /
    ( 1.0 + exp( sum( tonsilModel$coefficients*c(1,0,0,0)) ) )

pi11.W <- 1.0 /
    ( 1.0 + exp( -sum( tonsilModel$coefficients*c(0,1,0,0)) ) )

print( "Under the alternate:" )
print( sprintf("pi00.N = %f, pi11.N = %f, pi00.W = %f, pi11.W = %f", pi00.N, pi11.N, pi00.W, pi11.W ) )

## $P( Y = 0 | X = ( 1, 0 ) ) = \pi_{00}$
## $P( Y = 1 | X = ( 0, 1 ) ) = \pi_{11}$

pi11 <- 1.0 / ( 1.0 + exp( -sum( noTonsilModel$coefficients*c(0,1)) ) )
pi00 <- 1.0 /
    ( 1.0 + exp( sum( noTonsilModel$coefficients*c(1,0)) ) )

print( "Under the Null:" )
print( sprintf( "pi11 = %f, pi00 = %f", pi00, pi11 ) )

chiStat <- 2*(logLik( tonsilModel )[1] - logLik( noTonsilModel )[1] )
pValue <- pchisq( chiStat, 2, lower.tail = FALSE )
print( sprintf( "Using a Likelihood ratio test: p-value of: %f", pValue ) )
