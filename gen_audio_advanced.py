import wave
import math
import struct
import os
import random

os.makedirs('assets/audio', exist_ok=True)
sample_rate = 44100

def generate_wav(filename, samples):
    with wave.open(filename, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        # Normalize
        max_val = max(abs(x) for x in samples) if samples else 1
        if max_val == 0: max_val = 1
        for val in samples:
            ival = int((val / max_val) * 32767.0)
            if ival > 32767: ival = 32767
            if ival < -32768: ival = -32768
            w.writeframesraw(struct.pack('<h', ival))

def gen_pop():
    # A juicy "pop" sound for matches
    duration = 0.15
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        # Exponential frequency drop for a "pop"
        freq = 800 * math.exp(-25 * t)
        vol = math.exp(-15 * t)
        val = math.sin(2.0 * math.pi * freq * t) * vol
        samples.append(val)
    generate_wav('assets/audio/match.wav', samples)

def gen_swap():
    # A quick slide sound
    duration = 0.1
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        freq = 300 + 400 * (i / (sample_rate * duration))
        vol = math.sin(math.pi * (t / duration)) # smooth envelope
        val = math.sin(2.0 * math.pi * freq * t) * vol
        samples.append(val)
    generate_wav('assets/audio/swap.wav', samples)

def gen_special():
    # A magical sparkle (high frequency shimmer)
    duration = 0.5
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        vol = math.exp(-5 * t)
        freq = 1500 + 500 * math.sin(2 * math.pi * 20 * t)
        val = math.sin(2.0 * math.pi * freq * t) * vol
        samples.append(val)
    generate_wav('assets/audio/special.wav', samples)

def gen_invalid():
    # A soft dull thud
    duration = 0.2
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        freq = 100 * math.exp(-10 * t)
        vol = math.exp(-20 * t)
        # noise mixed with low sine
        val = (math.sin(2.0 * math.pi * freq * t) + random.random()*0.2 - 0.1) * vol
        samples.append(val)
    generate_wav('assets/audio/invalid.wav', samples)

def gen_button():
    # A short click
    duration = 0.05
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        freq = 600 * math.exp(-30 * t)
        vol = math.exp(-30 * t)
        val = math.sin(2.0 * math.pi * freq * t) * vol
        samples.append(val)
    generate_wav('assets/audio/button.wav', samples)

def gen_bg():
    # Just a very soft ambient drone so it's not annoying
    duration = 5.0
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        freq = 200 + 5 * math.sin(2 * math.pi * 0.2 * t)
        vol = 0.1 * (1 - math.cos(2 * math.pi * t / duration)) / 2 # fade in/out
        val = math.sin(2.0 * math.pi * freq * t) * vol
        samples.append(val)
    generate_wav('assets/audio/bg_music.wav', samples)

def gen_victory():
    # Happy chord
    duration = 1.0
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        vol = math.exp(-2 * t)
        f1 = 523.25
        f2 = 659.25
        f3 = 783.99
        val = (math.sin(2*math.pi*f1*t) + math.sin(2*math.pi*f2*t) + math.sin(2*math.pi*f3*t)) * vol / 3
        samples.append(val)
    generate_wav('assets/audio/victory.wav', samples)

def gen_lose():
    # Sad down sweep
    duration = 1.0
    samples = []
    for i in range(int(sample_rate * duration)):
        t = i / sample_rate
        vol = math.exp(-3 * t)
        freq = 300 - 150 * t
        val = math.sin(2*math.pi*freq*t) * vol
        samples.append(val)
    generate_wav('assets/audio/lose.wav', samples)

gen_pop()
gen_swap()
gen_special()
gen_invalid()
gen_button()
gen_bg()
gen_victory()
gen_lose()
print("Generated advanced sounds!")
