import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final Map<String, String> sounds = {
    'match.ogg': 'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
    'swap.ogg': 'https://actions.google.com/sounds/v1/cartoon/wood_plank_flicks.ogg',
    'button.ogg': 'https://actions.google.com/sounds/v1/cartoon/cartoon_boing.ogg',
    'invalid.ogg': 'https://actions.google.com/sounds/v1/cartoon/slip.ogg',
    'special.ogg': 'https://actions.google.com/sounds/v1/magic/magic_chime.ogg',
    'bg_music.ogg': 'https://actions.google.com/sounds/v1/ambiences/coffee_shop.ogg',
    'victory.ogg': 'https://actions.google.com/sounds/v1/crowds/small_crowd_cheering.ogg',
    'lose.ogg': 'https://actions.google.com/sounds/v1/cartoon/falling_whistle_with_thud.ogg'
  };

  for (var entry in sounds.entries) {
    try {
      final res = await http.get(Uri.parse(entry.value));
      if (res.statusCode == 200) {
        File('assets/audio/' + entry.key).writeAsBytesSync(res.bodyBytes);
        print('Downloaded ' + entry.key);
      } else {
        print('Failed ' + entry.key + ': ' + res.statusCode.toString());
      }
    } catch (e) {
      print('Error ' + entry.key + ': ' + e.toString());
    }
  }
}
