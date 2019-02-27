library( ggplot2 )
library( tikzDevice )



tikz( "Rplots.tex", width = 5, height = 5 )
plot( x=c(1,1,4),y=c(8,2,2), type="l", col="red",
     main="Isoquants for the Leontief", xlab="h", ylab="$\\ell$",
     xlim=c(0,5), ylim=c(0,9) , lwd=3 )
lines( x = c(2,2,4), y=c(8,4,4), col="blue", lwd=3 )
lines( x=c(3,3,4),y=c(8,6,6),col="green", lwd=3 )
lines( x=c(0,3),y=c(0,6),col="black", lty=3 )
lines( x=c(0,1),y=c(2,2),col="black",lty=3 )
lines( x=c(1,1),y=c(0,2),col="black",lty=3 )
text( x=4.5, y=2, labels = "$q_0 = 1$" )
text( x=4.5, y=4, labels = "$q_0 = 2$" )
text( x=4.5, y=6, labels = "$q_0 = 3$" )
dev.off()


tikz( "1bp1.tex", width = 2.5, height = 2.5 )
plot( x=c(0,4), y=c(0,8), type = "l", col="red", main="Total Cost", xlab="q",
     ylab="C(q)", lwd=3, xlim=c(0,5), ylim=c(0,9) )
#dev.off()

#tikz( "1bp2.tex", width= 2.5, height = 2.5 )
plot( x=c(0,4), y=c(2,2), type="l", col="blue", main="Marginal Cost", xlab="q",
     ylab="m(q)", lwd= 3, xlim = c(0,4), ylim=c(0,4) )
dev.off()

#ggplot( mapping = aes( x=l,y=h )
