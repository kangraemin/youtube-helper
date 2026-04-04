import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final isDarkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier()
      : super(Hive.box('settings').get('darkMode', defaultValue: false));

  void toggle() {
    state = !state;
    Hive.box('settings').put('darkMode', state);
  }
}
