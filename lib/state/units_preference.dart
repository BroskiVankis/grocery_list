import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UnitsPreference { metric, imperial }

extension UnitsPreferenceLabel on UnitsPreference {
  String get label => this == UnitsPreference.metric ? 'Metric' : 'Imperial';

  static UnitsPreference fromStoredValue(String? value) {
    if (value == UnitsPreference.imperial.name) {
      return UnitsPreference.imperial;
    }
    return UnitsPreference.metric;
  }

  static UnitsPreference fromLabel(String label) {
    return label.toLowerCase() == 'imperial'
        ? UnitsPreference.imperial
        : UnitsPreference.metric;
  }
}

class UnitsPreferenceController extends ChangeNotifier {
  static const String _storageKey = 'units_preference';

  UnitsPreferenceController() {
    _load();
  }

  UnitsPreference _preference = UnitsPreference.metric;
  UnitsPreference get preference => _preference;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(_storageKey);
    final loadedPreference = UnitsPreferenceLabel.fromStoredValue(storedValue);
    if (loadedPreference != _preference) {
      _preference = loadedPreference;
      notifyListeners();
    }
  }

  Future<void> setPreference(UnitsPreference value) async {
    if (value == _preference) return;

    _preference = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value.name);
  }

  Future<void> setPreferenceFromLabel(String label) {
    return setPreference(UnitsPreferenceLabel.fromLabel(label));
  }
}

class UnitsPreferenceScope
    extends InheritedNotifier<UnitsPreferenceController> {
  const UnitsPreferenceScope({
    super.key,
    required UnitsPreferenceController controller,
    required super.child,
  }) : super(notifier: controller);

  static UnitsPreferenceController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<UnitsPreferenceScope>();
    assert(scope != null, 'UnitsPreferenceScope is missing in widget tree.');
    return scope!.notifier!;
  }
}
