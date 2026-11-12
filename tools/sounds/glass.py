#!/usr/bin/env python3
"""Generates LoseLife.wav: a glass breaking, played when a player loses a life.

    python3 tools/sounds/glass.py tools/sounds/out/LoseLife.wav

Nothing is recorded or sampled, the sound is synthesised here: the crack of the impact is a short burst
of noise, and each piece of glass rings as a few high, quickly dying tones. Many pieces start in the first
instant and fewer and fewer after, with a last few tinkling as they land. Standard library only.
An optional second argument writes a spectrogram (PGM image) for checking the result by eye."""
import math, random, sys
from yahoo import FS, normalise, write_spectrogram, write_wav

LENGTH = 0.62
SHARDS = 46

def highpass(samples, cutoff):
    """Takes out the low rumble, glass has none"""
    k = math.exp(-2.0 * math.pi * cutoff / FS)
    out, low = [], 0.0
    for s in samples:
        low = k * low + (1.0 - k) * s
        out.append(s - low)
    return out

def glass():
    rng = random.Random(1876)
    n = int(LENGTH * FS)
    out = [0.0] * n
    # the impact: a crack of noise, gone in a few hundredths of a second, and a longer hiss as the glass gives way
    for i in range(int(0.18 * FS)):
        t = i / FS
        crack = math.exp(-t / 0.012)
        crash = 0.35 * math.exp(-t / 0.06)
        out[i] += rng.uniform(-1.0, 1.0) * (crack + crash) * min(1.0, t / 0.001)
    out = highpass(highpass(out, 1800.0), 1800.0)
    # the pieces: most ring out at once, the rest scatter after, later ones quieter
    for shard in range(SHARDS):
        start = 0.004 + (rng.random() ** 2.2) * 0.42
        loudness = (0.25 + 0.75 * rng.random()) * math.exp(-start / 0.22)
        base = rng.uniform(2200.0, 7500.0)
        decay = rng.uniform(0.012, 0.075)
        # a piece of glass does not ring at tidy multiples of one note
        for partial in range(3):
            frequency = base * (1.0, rng.uniform(1.4, 1.9), rng.uniform(2.3, 3.1))[partial]
            if frequency > 16000.0:
                continue
            amplitude = loudness * (1.0, 0.6, 0.35)[partial]
            phase = rng.uniform(0.0, 2.0 * math.pi)
            first = int(start * FS)
            for i in range(first, min(n, first + int(decay * 7 * FS))):
                t = (i - first) / FS
                out[i] += amplitude * 0.12 * math.exp(-t / decay) * math.sin(2.0 * math.pi * frequency * t + phase) * min(1.0, t / 0.0005)
    out = normalise(out, 0.89)
    fade = int(0.02 * FS)
    for i in range(fade):
        out[-1 - i] *= i / fade
    return out

if __name__ == '__main__':
    result = glass()
    write_wav(result, sys.argv[1])
    if len(sys.argv) > 2:
        write_spectrogram(result, sys.argv[2], top_hz=16000)
