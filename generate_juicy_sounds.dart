import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 44100;
final audioDir = Directory('assets/audio');

void main() async {
  if (!audioDir.existsSync()) {
    audioDir.createSync(recursive: true);
  }

  // 1. Juicy Match Sound (Sweet Arpeggio)
  final matchAudio = applyEnvelope(
    generateArpeggio([523.25, 659.25, 783.99, 1046.50], 0.1, 'sine'),
    0.05, 0.1, 0.8, 0.1,
  );
  saveWav('match.wav', matchAudio);

  // 2. Swap Sound (Quick Whoosh/Slide)
  final swapDur = 0.15;
  final numSamples = (sampleRate * swapDur).toInt();
  final swapRaw = Float64List(numSamples);
  for (int i = 0; i < numSamples; i++) {
    double t = i / sampleRate;
    double freq = 300 + (300 * (i / numSamples)); // sweep 300 to 600
    swapRaw[i] = sin(2 * pi * freq * t);
  }
  final swapAudio = applyEnvelope(swapRaw, 0.02, 0.0, 1.0, 0.1);
  saveWav('swap.wav', swapAudio);

  // 3. Invalid Sound (Buzzer/Dissonant)
  final invalidDur = 0.3;
  final invalidRaw = Float64List((sampleRate * invalidDur).toInt());
  for (int i = 0; i < invalidRaw.length; i++) {
    double t = i / sampleRate;
    double val1 = sin(2 * pi * 150 * t) >= 0 ? 1.0 : -1.0;
    double val2 = sin(2 * pi * 160 * t) >= 0 ? 1.0 : -1.0;
    invalidRaw[i] = (val1 + val2) / 2;
  }
  final invalidAudio = applyEnvelope(invalidRaw, 0.01, 0.1, 0.5, 0.1);
  saveWav('invalid.wav', invalidAudio);

  // 4. Special Sound (Magical Sparkle)
  final specialNotes = [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51, 1567.98, 2093.00];
  final specialAudio = applyEnvelope(
    generateArpeggio(specialNotes, 0.08, 'triangle'),
    0.1, 0.2, 0.6, 0.3,
  );
  saveWav('special.wav', specialAudio);

  // 5. Button Click (Short Pop)
  final buttonDur = 0.05;
  final buttonRaw = Float64List((sampleRate * buttonDur).toInt());
  for (int i = 0; i < buttonRaw.length; i++) {
    double t = i / sampleRate;
    buttonRaw[i] = sin(2 * pi * 800 * t);
  }
  final buttonAudio = applyEnvelope(buttonRaw, 0.005, 0.0, 1.0, 0.04);
  saveWav('button.wav', buttonAudio);

  // 6. Background Music (Arpeggiated Chords)
  List<double> cMaj = [261.63, 329.63, 392.00];
  List<double> gMaj = [196.00, 246.94, 293.66];
  List<double> aMin = [220.00, 261.63, 329.63];
  List<double> fMaj = [174.61, 220.00, 261.63];
  
  List<List<double>> chords = [cMaj, gMaj, aMin, fMaj];
  List<double> bgRawList = [];
  
  for (int loop = 0; loop < 2; loop++) {
    for (var c in chords) {
      final chordDur = 1.0;
      final chordRaw = Float64List((sampleRate * chordDur).toInt());
      for (int i = 0; i < chordRaw.length; i++) {
        double t = i / sampleRate;
        double val = 0;
        for (var f in c) {
          // triangle wave
          double phase = f * t;
          val += 2 * (2 * (phase - phase.floor()) - 1).abs() - 1;
        }
        chordRaw[i] = val / c.length;
      }
      final chordEnv = applyEnvelope(chordRaw, 0.1, 0.2, 0.8, 0.1);
      bgRawList.addAll(chordEnv);
    }
  }
  saveWav('bg_music.wav', Float64List.fromList(bgRawList));

  print("Professional juicy sound effects generated successfully with Dart!");
}

Float64List generateTone(double freq, double duration, String waveType) {
  int numSamples = (sampleRate * duration).toInt();
  final audio = Float64List(numSamples);
  for (int i = 0; i < numSamples; i++) {
    double t = i / sampleRate;
    double phase = freq * t;
    if (waveType == 'sine') {
      audio[i] = sin(2 * pi * phase);
    } else if (waveType == 'square') {
      audio[i] = sin(2 * pi * phase) >= 0 ? 1.0 : -1.0;
    } else if (waveType == 'sawtooth') {
      audio[i] = 2 * (phase - phase.floor()) - 1;
    } else if (waveType == 'triangle') {
      audio[i] = 2 * (2 * (phase - phase.floor()) - 1).abs() - 1;
    }
  }
  return audio;
}

Float64List generateArpeggio(List<double> notes, double noteDuration, String waveType) {
  List<double> allAudio = [];
  for (var f in notes) {
    allAudio.addAll(generateTone(f, noteDuration, waveType));
  }
  return Float64List.fromList(allAudio);
}

Float64List applyEnvelope(Float64List audio, double attack, double decay, double sustain, double release) {
  int length = audio.length;
  int aLen = (attack * sampleRate).toInt();
  int dLen = (decay * sampleRate).toInt();
  int rLen = (release * sampleRate).toInt();
  int sLen = length - aLen - dLen - rLen;
  
  if (sLen < 0) sLen = 0; // Prevent errors if duration is too short

  final env = Float64List(length);
  int idx = 0;
  
  // Attack
  for (int i = 0; i < aLen && idx < length; i++, idx++) {
    env[idx] = i / aLen;
  }
  // Decay
  for (int i = 0; i < dLen && idx < length; i++, idx++) {
    env[idx] = 1.0 - ((1.0 - sustain) * (i / dLen));
  }
  // Sustain
  for (int i = 0; i < sLen && idx < length; i++, idx++) {
    env[idx] = sustain;
  }
  // Release
  for (int i = 0; i < rLen && idx < length; i++, idx++) {
    env[idx] = sustain * (1.0 - (i / rLen));
  }
  
  final result = Float64List(length);
  for (int i = 0; i < length; i++) {
    result[i] = audio[i] * env[i];
  }
  return result;
}

void saveWav(String filename, Float64List audio) {
  // Normalize
  double maxVal = 0.0;
  for (int i = 0; i < audio.length; i++) {
    if (audio[i].abs() > maxVal) maxVal = audio[i].abs();
  }
  if (maxVal > 0) {
    for (int i = 0; i < audio.length; i++) {
      audio[i] = audio[i] / maxVal;
    }
  }

  // Convert to 16-bit PCM
  final int16Data = Int16List(audio.length);
  for (int i = 0; i < audio.length; i++) {
    int16Data[i] = (audio[i] * 32767).toInt();
  }

  final byteData = int16Data.buffer.asUint8List();
  
  // WAV Header
  int byteRate = sampleRate * 2;
  int totalDataLen = byteData.length + 36;
  
  final header = BytesBuilder();
  header.add("RIFF".codeUnits);
  header.add(_int32ToBytes(totalDataLen));
  header.add("WAVE".codeUnits);
  
  header.add("fmt ".codeUnits);
  header.add(_int32ToBytes(16)); // Subchunk1Size
  header.add(_int16ToBytes(1));  // AudioFormat (PCM)
  header.add(_int16ToBytes(1));  // NumChannels (Mono)
  header.add(_int32ToBytes(sampleRate));
  header.add(_int32ToBytes(byteRate));
  header.add(_int16ToBytes(2));  // BlockAlign
  header.add(_int16ToBytes(16)); // BitsPerSample
  
  header.add("data".codeUnits);
  header.add(_int32ToBytes(byteData.length));
  
  final file = File('${audioDir.path}/$filename');
  file.writeAsBytesSync(header.toBytes(), mode: FileMode.write);
  file.writeAsBytesSync(byteData, mode: FileMode.append);
}

List<int> _int16ToBytes(int value) {
  final bd = ByteData(2);
  bd.setInt16(0, value, Endian.little);
  return bd.buffer.asUint8List();
}

List<int> _int32ToBytes(int value) {
  final bd = ByteData(4);
  bd.setInt32(0, value, Endian.little);
  return bd.buffer.asUint8List();
}
