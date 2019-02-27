#rm(list=ls())
nTrials <- 100

deltas <- numeric(nTrials)


N <- 1000
e <- 1.2
F <- 3

#delta <- .0196

trueDelta <- numeric(nTrials)



for ( i in 1:nTrials ){
    trueDelta[i] <- runif( N, .01, .1)
    C <- runif( N, 50, 250 )
    W <- e * ( C + F ) / ( 1+ trueDelta[i])
    sigma <- .01
    Y <- rlnorm( N, - .5*sigma^2, sigma  )
    mean(Y)

    newY <- log(Y*e) - log(W) + log(C)
    ci <- -1 / C

    reg <- lm( newY ~ ci )
    summary(reg)
    deltas[i] <- reg$coefficients[1]
}




finalY <- log(trueDelta) - log(deltas)
finalX <- log( deltas / (log( 1 + deltas ) ) )

kReg <- lm( finalY ~ finalX  )

summary( kReg)


newdeltas <- (deltas/log(1+deltas))^kReg$coefficients[2]*deltas*exp(kReg$coefficients[1])

newestimate <- 0.0004129785 + deltas* (1-.0055237703) + .5613725349 * deltas^2


PrintToEmacs( {plot( newdeltas, trueDelta )
    abline( 0,1 ) } )

PrintToEmacs({
plot( newestimate, trueDelta )
abline( 0, 1)
})

saveRDS( kReg, "Hoffman-SchwiegBankTheftEstimator.rds" )
