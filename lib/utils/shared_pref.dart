import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static late SharedPreferences _sharedPrefs;
  static final SharedPref _instance = SharedPref._internal();
  factory SharedPref() => _instance;

  SharedPref._internal();

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get clockIn => _sharedPrefs.getString('clockIn') ?? '';
  String get clockOut => _sharedPrefs.getString('clockOut') ?? '';
  String get totalHours => _sharedPrefs.getString('totalHours') ?? '';

  set clockIn(String clockIn) {
    _sharedPrefs.setString('clockIn', clockIn);
  }

  set clockOut(String clockOut) {
    _sharedPrefs.setString('clockOut', clockOut);
  }

  set totalHours(String totalHours) {
    _sharedPrefs.setString('totalHours', totalHours);
  }

  clearCache() {
    clockIn = '';
    clockOut = '';
    clockOut = '';
  }
}
