# Get all the files in the directory, then estimate them and see if their standard deviations are equal
filename <- "../Data/AK-47/Jaguar.csv"

gunData <- read.csv( filename )

reg <- lm( data=gunData, formula = ZScore ~ . )
summary( reg )

sigma <- 1 / reg$coefficients[2]
mu <- -reg$coefficients[1]*sigma
