#!/usr/bin/env python3
"""Deterministic AUTHORING tool. Never imported or run by the mobile app."""
import datetime as dt
import hashlib
import importlib.util
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('reference', ROOT / 'Pawgrid_iOS_Android_Development_Handoff/Pawgrid_reference_solver.py')
ref = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ref)


def incompatible(n, regions, a, b):
    return a != b and (a // n == b // n or a % n == b % n or regions[a // n][a % n] == regions[b // n][b % n] or
        (abs(a // n - b // n) <= 1 and abs(a % n - b % n) <= 1))


def logical_trace(level):
    n, regions = level['n'], level['regions']
    tokens = {g['row'] * n + g['col'] for g in level['givens'] if g['mark'] == 'Token'}
    candidates = set(range(n * n)) - {g['row'] * n + g['col'] for g in level['givens']}
    units = []
    for k in range(n):
        units.extend([('row', k, {k*n+c for c in range(n)}), ('column', k, {r*n+k for r in range(n)}),
            ('garden', k, {i for i in range(n*n) if regions[i//n][i%n] == k})])
    trace = []
    for _ in range(n*n):
        if len(tokens) == n:
            return trace
        step = None
        for i in sorted(candidates):
            blockers = [t for t in sorted(tokens) if incompatible(n, regions, i, t)]
            if blockers:
                step = ('H1', i, 'Excluded', 'creature', blockers[0]); break
        if step is None:
            for name, k, cells in units:
                options = cells & candidates
                if not cells & tokens and len(options) == 1:
                    step = ('H2', min(options), 'Token', name, k); break
        if step is None:
            for name, k, cells in units:
                options = cells & candidates
                if cells & tokens or not options: continue
                for name2, _, cells2 in units:
                    if name == name2 or ('garden' not in (name, name2)): continue
                    removals = (cells2 & candidates) - cells
                    if options <= cells2 and removals:
                        step = ('H3' if name == 'garden' else 'H4', min(removals), 'Excluded', name, k); break
                if step: break
        if step is None:
            for i in sorted(candidates):
                for name, index, cells in units:
                    options = cells & (candidates | tokens)
                    if options and all(incompatible(n, regions, i, j) for j in options):
                        step = ('H5', i, 'Excluded', name, index); break
                if step: break
        if step is None: return None
        tactic, cell, mark, unit, index = step
        candidates.remove(cell)
        if mark == 'Token': tokens.add(cell)
        trace.append(dict(tactic=tactic, cell=cell, mark=mark, unit=unit, unitIndex=index))
    return trace if len(tokens) == n else None


def signature(regions):
    n = len(regions)
    signatures = []
    current = regions
    for _ in range(4):
        for grid in (current, [row[::-1] for row in current]):
            labels = {}
            flat = []
            for row in grid:
                for x in row:
                    if x not in labels: labels[x] = len(labels)
                    flat.append(labels[x])
            signatures.append(tuple(flat))
        current = [list(row) for row in zip(*current[::-1])]
    return (n, min(signatures))


def generate(n, seed, used, givens_count=0):
    rng = random.Random(seed)
    for attempt in range(2000000):
        p = list(range(n))
        rng.shuffle(p)
        if any(abs(a-b) <= 1 for a,b in zip(p,p[1:])): continue
        regions = [[-1]*n for _ in range(n)]
        sizes = [1]*n
        frontier = []
        dominant = set(rng.sample(list(range(n)), min(3,n)))
        quotas = [n*n if k in dominant else rng.randint(2,4) for k in range(n)]
        deferred = []
        def add(r,c,region):
            for rr,cc in ((r-1,c),(r+1,c),(r,c-1),(r,c+1)):
                if 0 <= rr < n and 0 <= cc < n and regions[rr][cc] == -1:
                    frontier.append((rr,cc,region))
        for r,c in enumerate(p): regions[r][c] = r
        for r,c in enumerate(p): add(r,c,r)
        remaining = n*n-n
        while remaining and frontier:
            # Slightly favor balanced regions, retaining organic irregularity.
            index = rng.randrange(len(frontier))
            r,c,region = frontier.pop(index)
            if regions[r][c] != -1: continue
            if n >= 7 and sizes[region] >= quotas[region]:
                deferred.append((r,c,region))
                if not frontier and remaining:
                    frontier, deferred = deferred, []
                    quotas = [n*n]*n
                continue
            regions[r][c] = region
            sizes[region] += 1
            remaining -= 1
            add(r,c,region)
        if remaining or min(sizes) < 2 or max(sizes) > max(8, int(.45*n*n)): continue
        sig = signature(regions)
        if sig in used and n != 4: continue
        level = dict(levelId='pending', n=n, regions=regions, solutionColumnsByRow=p,
            contentVersion=1, rulesetVersion='territory-v1', solutionCount=1,
            givens=[dict(row=r,col=p[r],mark='Token') for r in range(givens_count)],
            sourceSeed=seed, generatorVersion='pawgrid-author-1.0', difficulty='easy', difficultyScore=0,
            approvalStatus='machine_validated_pending_human_playtest')
        if len(ref.count_solutions(level)) != 1: continue
        trace = logical_trace(level)
        if trace is None: continue
        strongest = max([int(s['tactic'][1:]) for s in trace], default=1)
        score = min(99, (n-4)*7 + strongest*8 + len(trace)//8)
        level.update(difficultyScore=score,
            difficulty=('tutorial' if givens_count else 'easy' if strongest <= 3 and n <= 6 else 'medium' if n <= 7 else 'hard'),
            deductionTrace=trace, targetSeconds=90 if givens_count else 120+(n-5)*60)
        used.add(sig)
        return level
    raise RuntimeError(f'Generation exhausted n={n} seed={seed}')


def build():
    used = set()
    levels = []
    journey = []
    for i in range(200):
        n = 4 if i < 2 else 5 if i < 15 else 6 if i < 60 else 7 if i < 120 else 8 if i < 170 else 9
        level = generate(n, 71000+i, used, (2 if i < 2 else 1) if i < 5 else 0)
        level['levelId'] = f'journey-{i+1:03}'
        level['contentHash'] = ref.content_hash(level)
        errors = ref.validate_level(level)
        assert not errors, errors
        journey.append(level['levelId'])
        levels.append(level)
        if (i+1)%20 == 0: print(f'Journey: {i+1}/200 validated', flush=True)
    daily = {}
    for i in range(68):
        date = (dt.date(2026,11,1)+dt.timedelta(days=i)).isoformat()
        level = generate(5+i%3, 81000+i, used)
        level['levelId'] = 'daily-'+date
        level['contentHash'] = ref.content_hash(level)
        assert not ref.validate_level(level)
        daily[date] = level['levelId']
        levels.append(level)
    practice = []
    # Real difficulty choices reflect strategy; never relabel a board to meet a menu.
    for n in range(5,10):
        for j in range(6):
            level = generate(n, 91000+n*100+j, used)
            level['levelId'] = f'practice-{n}-{j+1:02}'
            level['contentHash'] = ref.content_hash(level)
            assert not ref.validate_level(level)
            practice.append(level['levelId'])
            levels.append(level)
    pack = dict(schemaVersion=1, rulesetVersion='territory-v1', catalogVersion=1,
        builtAt='2026-11-08', reviewStatus='machine_validated_pending_human_playtest',
        journey=journey, daily=daily, practice=practice, levels=levels)
    payload = json.dumps(pack,sort_keys=True,separators=(',',':'))+'\n'
    (ROOT/'content/catalog.json').write_text(payload)
    (ROOT/'content/catalog.sha256').write_text(hashlib.sha256(payload.encode()).hexdigest()+'\n')
    print(f'PASS: {len(levels)} connected unique deductively solved levels, no symmetry duplicates outside tutorials',flush=True)


if __name__ == '__main__': build()
