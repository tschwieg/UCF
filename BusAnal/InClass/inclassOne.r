library( quantreg )

n <-25
set.seed(123457)
xOne <- runif( 25 )
xTwo <- exp( rnorm( 25 ) )
d <- runif( 25) > .95
uOne <- rnorm(25)
uTwo <- cos( (22/7)*runif(25))/sin((22/7)*runif(25)) 
u <-(1-d)*uOne + d*uTwo 
y <-xOne + xTwo + u
y


predictor <- rq( formula= y ~ xOne + xTwo )
#summary( predictor )

shittyPredictor <- lm( formula=y ~ xOne + xTwo )
#summary( shittyPredictor )

xOne
xTwo
