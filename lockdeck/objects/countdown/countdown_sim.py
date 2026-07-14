from collections import defaultdict
from random import randrange, shuffle

SAFE_COUNT = 3

ITERATIONS = 1000000

results = defaultdict(int)

print(f"running {ITERATIONS} iterations...")
for __ in range(ITERATIONS):
    turn = 0
    bag = [False] * SAFE_COUNT
    while True:
        turn += 1
        shuffle(bag)
        if bag[0]:
            break
        bag += [True]
    results[turn] += 1 

print("RESULTS:")
for k in sorted(results.keys()):
    print(f"{k}: {results[k] / ITERATIONS * 100:.2f}%")

"""
running 1000000 iterations...
RESULTS:
2: 25.00%
3: 29.96%
4: 22.57%
5: 12.81%
6: 6.02%
7: 2.43%
8: 0.83%
9: 0.28%
10: 0.07%
11: 0.02%
12: 0.00%
13: 0.00%
14: 0.00%
"""