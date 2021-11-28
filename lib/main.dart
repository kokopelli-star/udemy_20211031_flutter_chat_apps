import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:udemy_20211031/pages/top_page.dart';
import 'package:udemy_20211031/utils/firebase.dart';
import 'package:udemy_20211031/utils/shared_prefs.dart';

Future<void> main() async {  // NOTE: awaitを利用する時はasyncを入れる
  WidgetsFlutterBinding.ensureInitialized();  // NOTE: Firebase用に追加
  await Firebase.initializeApp();  // NOTE: Firebase用に追加
  await SharedPrefs.setInstance();  // NOTE: Key-Valueデータを保存するためにSharedPreferencesインスタンスを生成する
  checkAccount();
  runApp(MyApp());
}

Future<void> checkAccount() async {
  String uid = SharedPrefs.getUid();

  if (uid == "") {
    Firestore.addUser();
  }
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,  // NOTE: 右上のDEBUG帯の表示・非表示を変える
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TopPage(),
    );
  }
}
