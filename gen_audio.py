import wave
import math
import struct
import os
import random

os.makedirs('assets/audio', exist_ok=True)
sample_rate = 44100

def generate_wav(filename, freq_func, duration, vol_func=lambda t: 1.0):
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        n_samples = int(duration * sample_rate)
        for i in range(n_samples):
            t = float(i) / sample_rate
            freq = freq_func(t)
            vol = vol_func(t)
            val = math.sin(2.0 * math.pi * freq * t) * vol
            ival = int(val * 32767.0)
            if ival > 32767: ival = 32767
            if ival < -32768: ival = -32768
            w.writeframesraw(struct.pack('<h', ival))

generate_wav('assets/audio/button.wav', lambda t: 880, 0.1, lambda t: 1.0 - (t/0.1))
generate_wav('assets/audio/match.wav', lambda t: 440 + 880 * (t/0.3), 0.3, lambda t: 1.0 - (t/0.3))
generate_wav('assets/audio/swap.wav', lambda t: 300 - 100 * (t/0.15), 0.15, lambda t: 1.0 - (t/0.15))

def saw(t, freq):
    return 2.0 * (t * freq - math.floor(0.5 + t * freq))

def gen_invalid():
    with wave.open('assets/audio/invalid.wav', 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        duration = 0.3
        n_samples = int(duration * sample_rate)
        for i in range(n_samples):
            t = float(i) / sample_rate
            freq = 150
            vol = 1.0 - (t/duration)
            val = saw(t, freq) * vol
            ival = int(val * 10000.0)
            w.writeframesraw(struct.pack('<h', ival))
gen_invalid()

def gen_special():
    with wave.open('assets/audio/special.wav', 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        duration = 0.6
        n_samples = int(duration * sample_rate)
        for i in range(n_samples):
            t = float(i) / sample_rate
            vol = (1.0 - (t/duration)) ** 2
            val = (random.random() * 2 - 1) * vol
            ival = int(val * 32767.0)
            w.writeframesraw(struct.pack('<h', ival))
gen_special()

def gen_bg():
    with wave.open('assets/audio/bg_music.wav', 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        notes = [261.63, 329.63, 392.00, 523.25]
        duration = 4.0
        n_samples = int(duration * sample_rate)
        for i in range(n_samples):
            t = float(i) / sample_rate
            note_idx = int(t * 4) % 4
            freq = notes[note_idx]
            vol = 0.3
            val = math.sin(2.0 * math.pi * freq * (t % 0.25)) * vol
            ival = int(val * 32767.0)
            w.writeframesraw(struct.pack('<h', ival))
gen_bg()

