import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_20211031/model/talk_room.dart';
import 'package:udemy_20211031/pages/setting_profile.dart';
import 'package:udemy_20211031/pages/talk_room_page.dart';
import 'package:udemy_20211031/utils/firebase.dart';
import 'package:udemy_20211031/utils/shared_prefs.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  List<TalkRoom> talkUserList = [];

  Future<void> createRooms() async {
    String myUid = SharedPrefs.getUid();
    talkUserList = await Firestore.getRooms(myUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("チャットアプリ"),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsProfilePage()));
          }, icon: Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(  // NOTE: StreamBuilderはroomが追加された時などにリアルタイムで反映する
        stream: Firestore.roomSnapshot,
        builder: (context, snapshot) {
          return FutureBuilder(  // NOTE: FutureBuilderはasync処理が終わってから返す
            future: createRooms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.builder(
                  itemCount: talkUserList.length,
                  itemBuilder: (context, index) {
                    return InkWell(  // NOTE: InkWellはタッチした座標を起点に円形のsplashが描画される
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TalkRoomPage(talkUserList[index])));  // NOTE Navigator.pushで別ウィジェットに遷移し、MaterialPageRoute()内に遷移したいクラス（この場合はTalkRoom()）を記述する
                      },
                      child: Container(
                        height: 70,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(talkUserList[index].talkUser.imagePath),
                                radius: 30,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(talkUserList[index].talkUser.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                Text(talkUserList[index].lastMessage, style: TextStyle(color: Colors.grey),), // TODO 元々lastMessageを表示していたところ
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return CircularProgressIndicator();  // NOTE: CircularProgressIndicatorは非同期処理待ち中にグルグル画像を出す
              }

            },
          );
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "ホーム"),
            BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: "写真"),
            BottomNavigationBarItem(icon: Icon(Icons.share), label: "シェア"),
          ]
      ),
    );
  }
}
