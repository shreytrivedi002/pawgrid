"""Reproducible original Pawgrid sound effects; standard-library authoring only."""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / 'app/assets/audio'
RATE = 22050
# (duration, notes: start, frequency, length, gain). Soft attacks avoid clicks.
SCORES = {
    'mark': (.10, [(0, 1320, .09, .23)]),
    'erase': (.17, [(0, 660, .09, .20), (.055, 440, .11, .15)]),
    'place': (.34, [(0, 880, .23, .25), (.065, 1320, .25, .20)]),
    'swipe': (.28, [(0, 660, .14, .15), (.045, 880, .14, .15), (.09, 1100, .16, .15)]),
    'undo': (.27, [(0, 990, .16, .20), (.065, 660, .19, .18)]),
    'warning': (.27, [(0, 440, .21, .18), (.06, 349.23, .19, .13)]),
    'hint': (.54, [(0, 880, .36, .23), (.12, 1320, .38, .20)]),
    'win': (1.48, [(i*.16, f, .48, .18) for i, f in enumerate([523.25, 659.25, 783.99, 1046.5, 1318.5, 1567.98])]),
}
ROOT.mkdir(exist_ok=True)
for name, (duration, notes) in SCORES.items():
    rng = random.Random(71000)
    samples = []
    for n in range(round(duration * RATE)):
        t = n / RATE
        value = 0.0
        for start, hz, length, gain in notes:
            age = t - start
            if not 0 <= age < length:
                continue
            attack = min(1, age / .008)
            release = max(0, 1 - age / length) ** 2
            phase = 2 * math.pi * hz * age
            tone = math.sin(phase) + .16 * math.sin(2.003 * phase) + .04 * math.sin(3.98 * phase)
            value += gain * attack * release * tone
        if name == 'mark':
            value += rng.uniform(-1, 1) * .025 * max(0, 1 - t / .025) ** 2
        # Fixed gentle headroom; never normalize quiet cues into loud ones.
        value = max(-.45, min(.45, value))
        samples.append(round(value * 32767))
    with wave.open(str(ROOT / f'{name}.wav'), 'wb') as out:
        out.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        out.writeframes(struct.pack(f'<{len(samples)}h', *samples))
print(f'Generated {len(SCORES)} original effects: {sum(p.stat().st_size for p in ROOT.glob("*.wav")):,} bytes')
