using QuantEcon
using Plots
using Plots.PlotMeasures
pyplot()

r = 0.05
beta = 1/(1+r)
T = 45
c_bar = 10.0
sigma = .5
P = 1.0
K = 30
PayBoost = P*( 1- beta^(K+1))
mu = 5.0


q = 1e6
m1 = 3*mu/(T)
m2 = -9*mu/(4*(T)^2)

Q = 1.0
R = zeros(4, 4)
Rf = zeros(4, 4);
Rf[1, 1] = q
A = [1 + r -c_bar m1 m2;
     0     1      0  0;
     0     1      1  0;
     0     1      2  1]
B = [-1.0; 0.0; 0.0; 0.0]
C = [0.0; 0.0; 0.0; 0.0]
lq_renter = LQ(Q, R, A, B, C; bet = beta, capT = T, rf = Rf)
x0 = [0.0; 1.0; 0.0; 0.0]
xp, up, wp = compute_sequence(lq_renter, x0)

# == Convert results back to assets, consumption and income == #
ap = vec(xp[1, 1:end])                                  # Assets
c = vec(up + c_bar)                                     # Consumption
time = 1:T
income = sigma * vec(wp[1, 2:end]) + m1 * time + m2 * time.^2   # Income

# == Plot results == #
p1 = plot(Vector[income, ap, c, zeros(T + 1)], lab = ["non-financial income" "assets" "consumption" ""],
     color = [:orange :blue :green :black], width = 3, xaxis = ("Time"), layout = (2,1),
     bottom_margin = 20mm, size = (600, 600), show = true)
