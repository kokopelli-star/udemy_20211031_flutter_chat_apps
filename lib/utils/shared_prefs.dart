import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? prefsInstance;

  static Future<void> setInstance() async {
    if (prefsInstance == null) {
      prefsInstance = await SharedPreferences.getInstance();
      print("インスタンス生成完了");
    }
  }

  static Future<void> setUid(String newUid) async {
    await prefsInstance!.setString("uid", newUid);
    print("保存完了");
  }

  static String getUid() {
    String uid = prefsInstance!.getString("uid") ?? "";
    return uid;
  }
}