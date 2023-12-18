import numpy as np

n = 50
ma = 1
fa = 0.3

centers = np.random.rand(n, 2) * ma
orientations = np.random.rand(n) * np.pi

start = np.empty((n, 2))
end = np.empty((n, 2))
for i in range(n):
    t = orientations[i]
    R = np.array([[np.cos(t), np.sin(t)], [-np.sin(t), np.cos(t)]])
    v0 = np.array([1, 0])
    v = R @ v0
    start[i] = centers[i] - v * fa / 2
    end[i] = centers[i] + v * fa / 2

start = np.clip(start, ma / 100, ma - ma / 100)
end = np.clip(end, ma / 100, ma - ma / 100)

count_pt = 5
count_ln = 5
for i in range(n):
    print("Point({}) = {{{}, {}, 0, e}};".format(count_pt, start[i, 0], start[i, 1]))
    print("Point({}) = {{{}, {}, 0, e}};".format(count_pt + 1, end[i, 0], end[i, 1]))
    print("Line({}) = {{{}, {}}};".format(count_ln, count_pt, count_pt + 1))
    print("Line {{{}}} In Surface {{1}};".format(count_ln))
    count_pt += 2
    count_ln += 1
