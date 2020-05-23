import 'package:isocial_messenger/config/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class SharedObjects {
  static CachedSharedPreferences prefs;

  static extractFileName(String url) {
    int length = url.split('/').length;
    String lastIndex = url.split('/')[length - 1];
    String fileName = lastIndex.split('?')[0];
    return fileName;
  }

  static downloadFile(String fileUrl) async {
    Dio dio = new Dio();
    String fileName = extractFileName(fileUrl);
    await dio.download(fileUrl, '${Constants.downloadsDirPath}/$fileName');
  }
}

class CachedSharedPreferences {
  static SharedPreferences sharedPreferences;
  static CachedSharedPreferences instance;
  static final cachedKeyList = [
    Constants.sessionUid,
    Constants.sessionUsername,
    Constants.sessionName,
    Constants.sessionPhoto,
    Constants.sessionPassword,
    Constants.signInMethod,
    Constants.configDarkMode
  ];
  static final sessionKeyList = [
    Constants.sessionName,
    Constants.sessionUid,
    Constants.sessionUsername,
    Constants.sessionPhoto,
    Constants.sessionPassword,
    Constants.signInMethod
  ];

  static Map<String, dynamic> map = Map();

  static Future<CachedSharedPreferences> getInstance() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool(Constants.configDarkMode) == null) {
      await sharedPreferences.setBool(Constants.configDarkMode, false);
    }
    for (String key in cachedKeyList) {
      map[key] = sharedPreferences.get(key);
    }
    if (instance == null) instance = CachedSharedPreferences();
    return instance;
  }

  String getString(String key) {
    if (cachedKeyList.contains(key)) {
      return map[key];
    }
    return sharedPreferences.getString(key);
  }

  bool getBool(String key) {
    if (cachedKeyList.contains(key)) {
      return map[key];
    }
    return sharedPreferences.getBool(key);
  }

  Future<bool> setString(String key, String value) async {
    bool result = await sharedPreferences.setString(key, value);
    if (result) map[key] = value;
    return result;
  }

  Future<bool> setBool(String key, bool value) async {
    bool result = await sharedPreferences.setBool(key, value);
    if (result) map[key] = value;
    return result;
  }
}
