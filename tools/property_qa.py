#!/usr/bin/env python3
"""Authoring property checks, independent of the mobile UI and catalog."""
import random
from collections import deque
import build_catalog as b
rng=random.Random(44001)
for n in range(4,10):
    for case in range(10000):
        while True:
            p=list(range(n));rng.shuffle(p)
            if all(abs(a-c)>1 for a,c in zip(p,p[1:])): break
        grid=[[-1]*n for _ in range(n)]
        frontier=[]
        def expand(r,c,k):
            for rr,cc in ((r-1,c),(r+1,c),(r,c-1),(r,c+1)):
                if 0<=rr<n and 0<=cc<n and grid[rr][cc]==-1:frontier.append((rr,cc,k))
        for r,c in enumerate(p):grid[r][c]=r
        for r,c in enumerate(p):expand(r,c,r)
        while frontier:
            index=rng.randrange(len(frontier));r,c,k=frontier.pop(index)
            if grid[r][c]!=-1:continue
            grid[r][c]=k;expand(r,c,k)
        assert {v for row in grid for v in row}==set(range(n))
        assert all(b.ref.region_is_connected(grid,k) for k in range(n))
        assert {grid[r][p[r]] for r in range(n)}==set(range(n))
        raw=dict(n=n,regions=grid,givens=[])
        assert b.ref.count_solutions(raw,limit=1), (n,case)
    print(f'PASS: 10,000 seed layouts at {n}×{n}; connected regions, exact labels, non-touching intended placements, independently satisfiable.',flush=True)
