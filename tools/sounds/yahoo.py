#!/usr/bin/env python3
"""Generates Yahoo.wav: a cowboy's ecstatic "Ya-hooo!", played when a player wins an extra life.

    python3 tools/sounds/yahoo.py tools/sounds/out/Yahoo.wav

Nothing is recorded or sampled, the voice is synthesised here: a train of glottal pulses (the vocal
cords) is passed through four resonators (the formants of the mouth and throat) whose frequencies
move from "y" to "aa", through a breathy "h", to a whooped "oo". It is then played through an
imitation of an early 1980s arcade speech chip, for its gritty sound. Standard library only.
An optional second argument writes a spectrogram (PGM image) for checking the result by eye."""
import math, random, struct, sys, wave

FS = 44100
random.seed(1881)

def track(points, t):
    """Piecewise linear value at time t from [(time, value), ...]"""
    if t <= points[0][0]:
        return points[0][1]
    for (t0, v0), (t1, v1) in zip(points, points[1:]):
        if t <= t1:
            return v0 + (v1 - v0) * (t - t0) / (t1 - t0)
    return points[-1][1]

# Pitch in Hz: a rising "yaa", then the "hoo" jumps up to a whoop and sags a little as it ends
PITCH = [(0.00, 270), (0.08, 300), (0.26, 400), (0.31, 470), (0.38, 540), (0.55, 520), (0.70, 440)]
# How loud the voice (vocal cords) and the breath (the "h") are
VOICE = [(0.00, 0.0), (0.02, 0.8), (0.05, 1.0), (0.24, 1.0), (0.27, 0.15), (0.31, 0.3), (0.34, 1.0), (0.58, 1.0),
         (0.66, 0.5), (0.70, 0.0)]
BREATH = [(0.00, 0.05), (0.23, 0.05), (0.26, 0.9), (0.31, 0.9), (0.34, 0.06), (0.66, 0.06), (0.70, 0.0)]
# Formant frequencies in Hz: "y" (like "ee") -> "aa" -> "oo"
F1 = [(0.00, 300), (0.02, 320), (0.07, 820), (0.25, 800), (0.33, 520), (0.70, 470)]
F2 = [(0.00, 2150), (0.02, 2050), (0.07, 1300), (0.25, 1250), (0.33, 1050), (0.70, 950)]
F3 = [(0.00, 2950), (0.07, 2650), (0.25, 2600), (0.33, 2400), (0.70, 2350)]
F4 = [(0.00, 3600), (0.70, 3500)]
BANDWIDTHS = (90.0, 110.0, 170.0, 250.0)
LENGTH = 0.70
# SPEED plays the tracks above faster and PITCH_SCALE raises the voice
SPEED = 1.0
PITCH_SCALE = 1.0
# The sound of an early 1980s arcade speech chip: 8000 samples a second, 8 bits
CHIP_RATE = 8000
CHIP_LEVELS = 256

def glottal_flow(p):
    """Rosenberg pulse: the air flow through the vocal cords over one cycle, p from 0 to 1.
    A short closing phase gives the bright, pressed sound of a shout."""
    opening, closing = 0.42, 0.08
    if p < opening:
        return 0.5 * (1.0 - math.cos(math.pi * p / opening))
    if p < opening + closing:
        return math.cos(0.5 * math.pi * (p - opening) / closing)
    return 0.0

def voice():
    n = int(LENGTH / SPEED * FS)
    out = [0.0] * n
    state = [[0.0, 0.0] for _ in BANDWIDTHS]
    phase, jitter, shimmer, last_flow = 0.0, 1.0, 1.0, 0.0
    for i in range(n):
        t = i * SPEED / FS
        f0 = track(PITCH, t) * PITCH_SCALE
        phase += f0 * jitter / FS
        if phase >= 1.0:
            phase -= 1.0
            # every cycle is a little different, a perfectly regular voice sounds like a machine
            jitter = 1.0 + random.uniform(-0.004, 0.004)
            shimmer = 1.0 + random.uniform(-0.03, 0.03)
        flow = glottal_flow(phase)
        # the sound that leaves the mouth follows the change in flow
        source = (flow - last_flow) * 30.0 * shimmer * track(VOICE, t)
        last_flow = flow
        source += random.uniform(-1.0, 1.0) * 0.25 * track(BREATH, t)
        # the formants, one after the other. The first is kept above the pitch, as a singer opens their mouth for a high note
        formants = (max(track(F1, t), f0 * 1.05), track(F2, t), track(F3, t), track(F4, t))
        x = source
        for k, (f, bw) in enumerate(zip(formants, BANDWIDTHS)):
            c = -math.exp(-2.0 * math.pi * bw / FS)
            b = 2.0 * math.exp(-math.pi * bw / FS) * math.cos(2.0 * math.pi * f / FS)
            y = (1.0 - b - c) * x + b * state[k][0] + c * state[k][1]
            state[k][1], state[k][0] = state[k][0], y
            x = y
        out[i] = x
    return out

def normalise(samples, peak):
    top = max(abs(s) for s in samples)
    return [s * peak / top for s in samples]

def master(samples):
    """Plays the voice through an imitation of an old speech chip: few samples a second and few levels,
    each sample held until the next (the steps give the gritty, buzzy edge), then the cabinet's dull speaker"""
    samples = [math.tanh(1.6 * s) for s in normalise(samples, 1.0)]
    step = FS / CHIP_RATE
    out = []
    for j in range(int(len(samples) / step)):
        block = samples[int(j * step):max(int((j + 1) * step), int(j * step) + 1)]
        level = round(sum(block) / len(block) * (CHIP_LEVELS / 2)) / (CHIP_LEVELS / 2)
        out += [level] * (int((j + 1) * step) - int(j * step))
    smooth = 0.0
    for i, s in enumerate(out):
        smooth += 0.5 * (s - smooth)
        out[i] = smooth
    return normalise(out + [0.0] * int(0.05 * FS), 0.89)

def write_wav(samples, path):
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FS)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))

def fft(a):
    n = len(a)
    if n == 1:
        return a
    even, odd = fft(a[0::2]), fft(a[1::2])
    out = [0j] * n
    for k in range(n // 2):
        w = complex(math.cos(-2 * math.pi * k / n), math.sin(-2 * math.pi * k / n)) * odd[k]
        out[k], out[k + n // 2] = even[k] + w, even[k] - w
    return out

def write_spectrogram(samples, path, size=1024, hop=256, top_hz=5000):
    window = [0.5 - 0.5 * math.cos(2 * math.pi * i / size) for i in range(size)]
    bins = int(top_hz * size / FS)
    columns = []
    for start in range(0, len(samples) - size, hop):
        spectrum = fft([complex(samples[start + i] * window[i]) for i in range(size)])
        columns.append([20 * math.log10(abs(spectrum[k]) + 1e-6) for k in range(bins)])
    top = max(max(c) for c in columns)
    with open(path, 'wb') as f:
        f.write(f'P5 {len(columns)} {bins} 255\n'.encode())
        for k in reversed(range(bins)):
            f.write(bytes(int(255 * max(0.0, min(1.0, (c[k] - top + 70) / 70))) for c in columns))

if __name__ == '__main__':
    result = master(voice())
    write_wav(result, sys.argv[1])
    if len(sys.argv) > 2:
        write_spectrogram(result, sys.argv[2])
