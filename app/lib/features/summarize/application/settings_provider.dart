import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:youtube_helper/core/constants/api_constants.dart';

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

final serverUrlProvider =
    StateNotifierProvider<ServerUrlNotifier, String>((ref) {
  return ServerUrlNotifier();
});

class ServerUrlNotifier extends StateNotifier<String> {
  ServerUrlNotifier()
      : super(Hive.box('settings')
            .get('serverUrl', defaultValue: ApiConstants.defaultServerUrl));

  void update(String url) {
    state = url;
    Hive.box('settings').put('serverUrl', url);
  }
}
