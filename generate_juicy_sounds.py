import numpy as np
from scipy.io.wavfile import write
import os

SAMPLE_RATE = 44100
AUDIO_DIR = r"c:\Users\rashi\StudioProjects\choco_blast_adventure\assets\audio"
if not os.path.exists(AUDIO_DIR):
    os.makedirs(AUDIO_DIR)

def apply_envelope(audio, attack, decay, sustain, release):
    length = len(audio)
    a_len = int(attack * SAMPLE_RATE)
    d_len = int(decay * SAMPLE_RATE)
    r_len = int(release * SAMPLE_RATE)
    s_len = length - a_len - d_len - r_len
    
    env = np.ones(length)
    if a_len > 0:
        env[:a_len] = np.linspace(0, 1, a_len)
    if d_len > 0:
        env[a_len:a_len+d_len] = np.linspace(1, sustain, d_len)
    if s_len > 0:
        env[a_len+d_len:a_len+d_len+s_len] = sustain
    if r_len > 0:
        env[-r_len:] = np.linspace(sustain, 0, r_len)
    
    return audio * env

def generate_tone(freq, duration, wave_type='sine'):
    t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
    if wave_type == 'sine':
        return np.sin(2 * np.pi * freq * t)
    elif wave_type == 'square':
        return np.sign(np.sin(2 * np.pi * freq * t))
    elif wave_type == 'sawtooth':
        return 2 * (t * freq - np.floor(0.5 + t * freq))
    elif wave_type == 'triangle':
        return 2 * np.abs(2 * (t * freq - np.floor(0.5 + t * freq))) - 1
    return np.zeros_like(t)

def generate_arpeggio(notes, note_duration, wave_type='sine'):
    audio = []
    for f in notes:
        audio.extend(generate_tone(f, note_duration, wave_type))
    return np.array(audio)

def save_wav(filename, audio):
    # Normalize to 16-bit
    audio = audio / np.max(np.abs(audio)) if np.max(np.abs(audio)) > 0 else audio
    audio_16bit = np.int16(audio * 32767)
    write(os.path.join(AUDIO_DIR, filename), SAMPLE_RATE, audio_16bit)

# 1. Juicy Match Sound (Cute Fast Chime)
match_audio = generate_arpeggio([783.99, 1046.50, 1318.51, 1567.98], 0.04, 'sine')
match_audio = apply_envelope(match_audio, 0.01, 0.05, 0.5, 0.05)
save_wav("match.wav", match_audio)

# 2. Swap Sound (Quick Whoosh/Slide)
duration = 0.15
t = np.linspace(0, duration, int(SAMPLE_RATE * duration), False)
# Frequency sweep from 300 to 600
freqs = np.linspace(300, 600, len(t))
swap_audio = np.sin(2 * np.pi * freqs * t)
swap_audio = apply_envelope(swap_audio, 0.02, 0.0, 1.0, 0.1)
save_wav("swap.wav", swap_audio)

# 3. Invalid Sound (Buzzer/Dissonant)
dur = 0.3
t = np.linspace(0, dur, int(SAMPLE_RATE * dur), False)
invalid_audio = generate_tone(150, dur, 'square') + generate_tone(160, dur, 'square')
invalid_audio = apply_envelope(invalid_audio, 0.01, 0.1, 0.5, 0.1)
save_wav("invalid.wav", invalid_audio)

# 4. Special Sound (Magical Sparkle)
special_notes = [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51, 1567.98, 2093.00]
special_audio = generate_arpeggio(special_notes, 0.08, 'triangle')
special_audio = apply_envelope(special_audio, 0.1, 0.2, 0.6, 0.3)
save_wav("special.wav", special_audio)

# 5. Button Click (Short Pop)
button_dur = 0.05
button_audio = generate_tone(800, button_dur, 'sine')
button_audio = apply_envelope(button_audio, 0.005, 0.0, 1.0, 0.04)
save_wav("button.wav", button_audio)

# 6. Better Background Music (Simple loopable chord progression)
# C major -> G major -> A minor -> F major
def chord(notes, duration):
    return sum(generate_tone(n, duration, 'triangle') for n in notes) / len(notes)

c_maj = [261.63, 329.63, 392.00]
g_maj = [196.00, 246.94, 293.66]
a_min = [220.00, 261.63, 329.63]
f_maj = [174.61, 220.00, 261.63]

chords = [c_maj, g_maj, a_min, f_maj]
bg_audio = []
for _ in range(2): # Loop twice
    for c in chords:
        # Play chord for 1 second, then arpeggiate
        bg_audio.extend(apply_envelope(chord(c, 1.0), 0.1, 0.2, 0.8, 0.1))
        
bg_audio = np.array(bg_audio)
save_wav("bg_music.wav", bg_audio)

# 7. Victory Sound (Happy Fanfare)
victory_notes = [523.25, 659.25, 783.99]
victory_audio = []
for f in victory_notes:
    victory_audio.extend(apply_envelope(generate_tone(f, 0.15, 'square'), 0.02, 0.05, 0.6, 0.08))
victory_audio.extend(apply_envelope(generate_tone(1046.50, 0.6, 'square'), 0.1, 0.2, 0.8, 0.3))
save_wav("victory.wav", np.array(victory_audio))

# 8. Lose Sound (Sad Descending)
lose_notes = [392.00, 370.00, 349.23, 329.63]
lose_audio = []
for f in lose_notes[:-1]:
    lose_audio.extend(apply_envelope(generate_tone(f, 0.3, 'sawtooth'), 0.05, 0.1, 0.7, 0.1))
lose_audio.extend(apply_envelope(generate_tone(lose_notes[-1], 0.8, 'sawtooth'), 0.1, 0.2, 0.6, 0.4))
save_wav("lose.wav", np.array(lose_audio))

print("Professional juicy sound effects generated successfully!")
