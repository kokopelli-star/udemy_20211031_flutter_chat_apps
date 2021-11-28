import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_20211031/model/message.dart';
import 'package:udemy_20211031/model/talk_room.dart';
import 'package:udemy_20211031/model/user.dart';
import 'package:udemy_20211031/utils/shared_prefs.dart';

class Firestore {
  static FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  static final userRef = _firebaseFirestore.collection("user");
  static final roomRef = _firebaseFirestore.collection("room");
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addUser() async {
    try {
      final newDoc = await userRef.add({
        "name": "名無し",
        "image_path":
            "https://pbs.twimg.com/profile_images/906759420964564994/kIi3ifqs_400x400.jpg",
      });
      print("アカウント作成完了");

      await SharedPrefs.setUid(newDoc.id);

      List<String> userIds = await getUser();
      userIds.forEach((user) async {
        if (user != newDoc.id) {
          await roomRef.add({
            "joined_user_ids": [user, newDoc.id],
            "updated_time": Timestamp.now()
          });
          print("ルーム作成完了");
        }
      });
      print("アカウント作成、ルーム作成完了");
    } catch (e) {
      print("アカウント作成、ルーム作成失敗: $e");
    }
  }

  static Future<List<String>> getUser() async {
    try {
      final snapshot = await userRef.get();
      List<String> userIds = [];
      snapshot.docs.forEach((user) {
        userIds.add(user.id);
        print("ID: ${user.id} -- 名前: ${user.data()["name"]}");
      });

      return userIds;
    } catch (e) {
      print("アカウント取得失敗: $e");
      return [];
    }
  }

  static Future<User> getProfile(String uid) async {
    final profile = await userRef.doc(uid).get();
    User myProfile = User(
        name: profile.data()!["name"],
        uid: uid,
        imagePath: profile.data()!["image_path"] ?? "");
    return myProfile;
  }

  static Future<void> updateProfile(User newProfile) async {
    String myUid = SharedPrefs.getUid();
    userRef.doc(myUid).update({
      "name": newProfile.name,
      "image_path": newProfile.imagePath,
    });
  }

  static Future<List<TalkRoom>> getRooms(String myUid) async {
    final snapshot = await roomRef.get();

    List<TalkRoom> roomList = [];
    await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(
        snapshot.docs, (doc) async {
      // NOTE: Futureだと非同期で先に処理が進んでしまうのでawaitで処理を待つ
      if (doc.data()["joined_user_ids"].contains(myUid)) {
        String yourUid = "";
        doc.data()["joined_user_ids"].forEach((id) {
          if (id != myUid) {
            yourUid = id;
            return;
          }
        });

        User yourProfile = await getProfile(yourUid);
        TalkRoom room = TalkRoom(
            roomId: doc.id,
            talkUser: yourProfile,
            lastMessage: doc.data()["last_message"] ?? "");
        roomList.add(room);
      }
    });

    return roomList;
  }

  static Future<List<Message>> getMessages(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection("message");

    List<Message> messageList = [];
    final snapshot = await messageRef.get();
    await Future.forEach<QueryDocumentSnapshot<Map<String, dynamic>>>(
        snapshot.docs, (doc) async {
      // NOTE: Futureだと非同期で先に処理が進んでしまうのでawaitで処理を待つ
      bool isMe;
      String myUid = SharedPrefs.getUid();
      if (doc.data()["sender_id"] == myUid) {
        isMe = true;
      } else {
        isMe = false;
      }

      Message message = Message(
        message: doc.data()["message"],
        isMe: isMe,
        sendTime: doc.data()["send_time"]
      );
      messageList.add(message);
    });
    messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));

    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection("message");
    String myUid = SharedPrefs.getUid();
    await messageRef.add({
      "message": message,
      "sender_id": myUid,
      "send_time": Timestamp.now()
    });

    roomRef.doc(roomId).update({
      "last_message": message
    });
  }

  static Stream<QuerySnapshot> messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection("message").snapshots();
  }
}
