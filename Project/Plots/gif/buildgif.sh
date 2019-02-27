sssh UCFServer 'cd Plots/gif; zip plots.zip *; mv plots.zip ~/; exit'
scp "ti591823@mseconomics.business.ucf.edu:/home/ad/ti591823/plots.zip" .
unzip "plots.zip"
convert -loop 0 -delay 100 *.png out.gif
xdg-open out.gif
