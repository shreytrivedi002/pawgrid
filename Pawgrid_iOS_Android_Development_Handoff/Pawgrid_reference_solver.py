#!/usr/bin/env python3
"""Project Pawgrid reference level validator.

Standard-library-only, intended for build-time validation and test parity with
production C# code. Not a Unity gameplay implementation. Run:
  python Pawgrid_reference_solver.py Pawgrid_sample_level.json
"""
import hashlib
import json
import sys
from collections import deque

CANONICAL_KEYS = (
    'contentVersion', 'givens', 'levelId', 'n', 'regions',
    'rulesetVersion', 'solutionColumnsByRow',
)


def content_hash(level):
    minimal = {k: level[k] for k in CANONICAL_KEYS}
    payload = json.dumps(minimal, sort_keys=True, ensure_ascii=False,
                         separators=(',', ':')).encode('utf-8')
    return hashlib.sha256(payload).hexdigest()


def region_is_connected(regions, label):
    n = len(regions)
    cells = {(r, c) for r in range(n) for c in range(n)
             if regions[r][c] == label}
    if not cells:
        return False
    start = next(iter(cells))
    visited = {start}
    pending = deque([start])
    while pending:
        r, c = pending.popleft()
        for point in ((r + 1, c), (r - 1, c),
                      (r, c + 1), (r, c - 1)):
            if point in cells and point not in visited:
                visited.add(point)
                pending.append(point)
    return visited == cells


def _given_maps(level):
    fixed = {}
    for g in level['givens']:
        position = (g['row'], g['col'])
        if position in fixed:
            raise ValueError('duplicate given cell')
        fixed[position] = g['mark']
    return fixed


def count_solutions(level, limit=2):
    n, regions = level['n'], level['regions']
    givens = _given_maps(level)
    solutions = []
    forced_cols = {}
    excluded = set()
    for (r, c), mark in givens.items():
        if mark == 'Token':
            if r in forced_cols and forced_cols[r] != c:
                return []
            forced_cols[r] = c
        elif mark == 'Excluded':
            excluded.add((r, c))

    def backtrack(row, used_columns, used_regions, previous_column, placements):
        if len(solutions) >= limit:
            return
        if row == n:
            solutions.append(placements[:])
            return
        possible = [forced_cols[row]] if row in forced_cols else range(n)
        for col in possible:
            region = regions[row][col]
            if (row, col) in excluded:
                continue
            if (used_columns >> col) & 1:
                continue
            if (used_regions >> region) & 1:
                continue
            if previous_column is not None and abs(previous_column - col) <= 1:
                continue
            placements.append(col)
            backtrack(row + 1, used_columns | (1 << col),
                      used_regions | (1 << region), col, placements)
            placements.pop()
            if len(solutions) >= limit:
                break

    backtrack(0, 0, 0, None, [])
    return solutions


def validate_level(level):
    errors = []
    try:
        n = level['n']
        if not isinstance(n, int) or not 4 <= n <= 9:
            errors.append('n must be integer 4..9')
            return errors
        if level.get('rulesetVersion') != 'territory-v1':
            errors.append('unsupported rulesetVersion')
        if not isinstance(level.get('contentVersion'), int) or level['contentVersion'] < 1:
            errors.append('contentVersion must be positive integer')
        regions = level['regions']
        if len(regions) != n or any(len(row) != n for row in regions):
            errors.append('regions must be n x n')
            return errors
        if any(not isinstance(v, int) or v < 0 or v >= n
               for row in regions for v in row):
            errors.append('regions contain out-of-range ID')
            return errors
        labels = {v for row in regions for v in row}
        if labels != set(range(n)):
            errors.append('every label from 0..n-1 must be present')
        for label in range(n):
            if not region_is_connected(regions, label):
                errors.append('region %d is disconnected' % label)
        solution = level['solutionColumnsByRow']
        if len(solution) != n or set(solution) != set(range(n)):
            errors.append('solution must be permutation of 0..n-1')
            return errors
        if any(abs(solution[r] - solution[r + 1]) <= 1 for r in range(n - 1)):
            errors.append('solution has touching tokens in adjacent rows')
        if {regions[r][solution[r]] for r in range(n)} != set(range(n)):
            errors.append('solution does not use each region exactly once')
        fixed = _given_maps(level)
        for (r, c), mark in fixed.items():
            if not 0 <= r < n or not 0 <= c < n:
                errors.append('given out of bounds')
            if mark not in ('Token', 'Excluded'):
                errors.append('unknown given mark')
            if mark == 'Token' and solution[r] != c:
                errors.append('token given conflicts with canonical solution')
            if mark == 'Excluded' and solution[r] == c:
                errors.append('excluded given conflicts with canonical solution')
        if 'contentHash' in level and level['contentHash'] != content_hash(level):
            errors.append('contentHash mismatch')
        if not errors:
            found = count_solutions(level, limit=2)
            if len(found) != 1:
                errors.append('solution count is %s (0 or >=2)' % len(found))
            elif found[0] != solution:
                errors.append('canonical solution differs from enumerated solution')
        if level.get('solutionCount') not in (None, 1):
            errors.append('approved fixture must claim solutionCount=1')
    except (KeyError, ValueError, TypeError, IndexError) as exc:
        errors.append('malformed fixture: %s' % exc)
    return errors


def main():
    if len(sys.argv) != 2:
        print('Usage: python Pawgrid_reference_solver.py <level.json>')
        return 2
    with open(sys.argv[1], 'r', encoding='utf-8') as file:
        level = json.load(file)
    errors = validate_level(level)
    if errors:
        for error in errors:
            print('FAIL:', error)
        return 1
    print('PASS:', level['levelId'], '- 1 unique solution, connected regions,',
          'content hash valid')
    print('Solution columns by row:', level['solutionColumnsByRow'])
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
