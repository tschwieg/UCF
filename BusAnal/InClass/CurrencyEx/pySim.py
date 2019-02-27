import numpy as np


N = 225
Cash = np.zeros(225)
for i in range(225):
    Cash[i] = 100 + i


sigma = .01
delta = .02
k = 3
F = 1.
Z = np.random.normal(0, 1, N)
S = np.zeros(N)
for i in range(N):
    S[i] = np.exp(-sigma**2 / 2 + sigma * Z[i])


w = np.zeros(N)
for i in range(N):
    w[i] = F * S[i] * (k + Cash[i]) / (1 + delta)
