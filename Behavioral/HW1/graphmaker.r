pdf( "Question1b.pdf" )
plot( x=.01*1:1000, y = log( .01*1:1000 ), type= "l", xlab = "x", ylab = "log(x)" )
dev.off()

pdf( "Question1a.pdf" )
plot( x=.01*1:1000, y =  .01*1:1000, type= "l", xlab = "x", ylab = "x" )
dev.off()


pi <-function( x){
    return (log(x) - x)
}

pdf( "Question1c.pdf" )
plot( x=.01*1:1000, y = pi( .01*1:1000 ), type= "l", xlab = "x", ylab = "\\pi(x)" )
dev.off()
