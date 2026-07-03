import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HomeExperience { classic, cinematic }

/// Singleton that persists and exposes the user's chosen Home Experience.
class HomeExperienceProvider extends ChangeNotifier {
  HomeExperienceProvider();

  static const _key = 'home_experience';

  HomeExperience _experience = HomeExperience.classic;
  HomeExperience get experience => _experience;

  bool _initialised = false;
  bool get initialised => _initialised;

  /// Call once at app startup (idempotent).
  Future<void> init() async {
    if (_initialised) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == HomeExperience.cinematic.name) {
      _experience = HomeExperience.cinematic;
    }
    _initialised = true;
    notifyListeners();
  }

  Future<void> setExperience(HomeExperience value) async {
    if (_experience == value) return;
    _experience = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
