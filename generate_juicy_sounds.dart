import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const sampleRate = 44100;
final audioDir = Directory('assets/audio');

void main() async {
  if (!audioDir.existsSync()) {
    audioDir.createSync(recursive: true);
  }

  // 1. Juicy Match Sound (Pop)
  final popDur = 0.15;
  final numSamples = (sampleRate * popDur).toInt();
  final popRaw = Float64List(numSamples);
  for (int i = 0; i < numSamples; i++) {
    double t = i / sampleRate;
    double freq = 800 * exp(-25 * t);
    double vol = exp(-15 * t);
    popRaw[i] = sin(2 * pi * freq * t) * vol;
  }
  saveWav('match.wav', popRaw);

  // 2. Swap Sound (Quick Whoosh/Slide)
  final swapDur = 0.1;
  final numSwapSamples = (sampleRate * swapDur).toInt();
  final swapRaw = Float64List(numSwapSamples);
  for (int i = 0; i < numSwapSamples; i++) {
    double t = i / sampleRate;
    double freq = 300 + 400 * (i / numSwapSamples);
    double vol = sin(pi * (t / swapDur));
    swapRaw[i] = sin(2 * pi * freq * t) * vol;
  }
  saveWav('swap.wav', swapRaw);

  // 3. Invalid Sound (Dull thud)
  final invalidDur = 0.2;
  final invalidRaw = Float64List((sampleRate * invalidDur).toInt());
  final rand = Random();
  for (int i = 0; i < invalidRaw.length; i++) {
    double t = i / sampleRate;
    double freq = 100 * exp(-10 * t);
    double vol = exp(-20 * t);
    invalidRaw[i] = (sin(2 * pi * freq * t) + rand.nextDouble() * 0.2 - 0.1) * vol;
  }
  saveWav('invalid.wav', invalidRaw);

  // 4. Special Sound (Magical Sparkle)
  final specialDur = 0.5;
  final specialRaw = Float64List((sampleRate * specialDur).toInt());
  for (int i = 0; i < specialRaw.length; i++) {
    double t = i / sampleRate;
    double vol = exp(-5 * t);
    double freq = 1500 + 500 * sin(2 * pi * 20 * t);
    specialRaw[i] = sin(2 * pi * freq * t) * vol;
  }
  saveWav('special.wav', specialRaw);

  // 5. Button Click (Short Click)
  final buttonDur = 0.05;
  final buttonRaw = Float64List((sampleRate * buttonDur).toInt());
  for (int i = 0; i < buttonRaw.length; i++) {
    double t = i / sampleRate;
    double freq = 600 * exp(-30 * t);
    double vol = exp(-30 * t);
    buttonRaw[i] = sin(2 * pi * freq * t) * vol;
  }
  saveWav('button.wav', buttonRaw);

  // 6. Background Music (Soft drone)
  final bgDur = 5.0;
  final bgRaw = Float64List((sampleRate * bgDur).toInt());
  for (int i = 0; i < bgRaw.length; i++) {
    double t = i / sampleRate;
    double freq = 200 + 5 * sin(2 * pi * 0.2 * t);
    double vol = 0.1 * (1 - cos(2 * pi * t / bgDur)) / 2;
    bgRaw[i] = sin(2 * pi * freq * t) * vol;
  }
  saveWav('bg_music.wav', bgRaw);

  // 7. Victory Sound (Happy chord)
  final victoryDur = 1.0;
  final victoryRaw = Float64List((sampleRate * victoryDur).toInt());
  for (int i = 0; i < victoryRaw.length; i++) {
    double t = i / sampleRate;
    double vol = exp(-2 * t);
    victoryRaw[i] = (sin(2*pi*523.25*t) + sin(2*pi*659.25*t) + sin(2*pi*783.99*t)) * vol / 3;
  }
  saveWav('victory.wav', victoryRaw);

  // 8. Lose Sound (Sad down sweep)
  final loseDur = 1.0;
  final loseRaw = Float64List((sampleRate * loseDur).toInt());
  for (int i = 0; i < loseRaw.length; i++) {
    double t = i / sampleRate;
    double vol = exp(-3 * t);
    double freq = 300 - 150 * t;
    loseRaw[i] = sin(2*pi*freq*t) * vol;
  }
  saveWav('lose.wav', loseRaw);

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
