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

# == Formulate as an LQ problem == #
Q = 1.0
R = zeros(4, 4)
Rf = zeros(4, 4);
Rf[1, 1] = q
A = [1 + r PayBoost-c_bar m1 m2;
     0     1      0  0;
     0     1      1  0;
     0     1      2  1]
B = [-1.0; 0.0; 0.0; 0.0]
C = [0.0; 0.0; 0.0; 0.0]


lq_richman = LQ(Q, R, A, B, C; bet=beta, capT=T-K, rf=Rf)
lq_richman_proxy = LQ(Q, R, A, B, C; bet=beta, capT=T-K, rf=Rf)  
x0 = [0.0, 1.0]
for i in 1:(T-K)
    update_values!(lq_richman_proxy)
end

Rf2 = lq_richman_proxy.P


Q = 1.0
IncomeLoss = P*beta^(K+1)
R = zeros(4, 4)
A = [1 + r -IncomeLoss-c_bar m1 m2;
     0     1      0  0;
     0     1      1  0;
     0     1      2  1]
B = [-1.0; 0.0; 0.0; 0.0]
C = [sigma; 0.0; 0.0; 0.0]

# == Set up working life LQ instance with terminal Rf from lq_retired == #
lq_working = LQ(Q, R, A, B, C; bet = beta, capT = K, rf = Rf2)

# == Simulate working state / control paths == #
x0 = [0.0; 1.0; 0.0; 0.0]
xp_w, up_w, wp_w = compute_sequence(lq_working, x0)
# == Simulate retirement paths (note the initial condition) == #
xp_r, up_r, wp_r = compute_sequence(lq_richman, xp_w[:, end] )

# == Convert results back to assets, consumption and income == #
xp = [xp_w xp_r[:, 2:end]]
assets = vec(xp[1, :])               # Assets

up = [up_w up_r]
c = vec(up + c_bar)                  # Consumption

time = 1:K
rtime = (K+1):T
#rtime = 1:(T-K)
income_w = sigma * vec(wp_w[1, 2:K+1]) + m1 .* time + m2 .* time.^2 - ones(K)*IncomeLoss   # Income
income_r = sigma * vec(wp_r[1, 2:(T+1-K)]) + m1 .* rtime + m2 .* rtime.^2 - ones(T-K)*PayBoost
income = [income_w; income_r]



# == Plot results == #
p3 = plot(Vector[income, assets, c, zeros(T + 1)], lab = ["non-financial income" "assets" "consumption" ""],
     color = [:orange :blue :green :black], width = 3, xaxis = ("Time"), layout = (2,1),
          bottom_margin = 20mm, size = (600, 600), show = true)
