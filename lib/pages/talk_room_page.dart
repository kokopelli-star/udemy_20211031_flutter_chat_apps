import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_20211031/model/message.dart';
import 'package:udemy_20211031/model/talk_room.dart';
import 'package:udemy_20211031/utils/firebase.dart';

class TalkRoomPage extends StatefulWidget {
//  const TalkRoom({Key? key}) : super(key: key);

  final TalkRoom room;

  TalkRoomPage(this.room);

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  List<Message> messageList = [];
  TextEditingController controller = TextEditingController();

  Future<void> getMessages() async {
    messageList = await Firestore.getMessages(widget.room.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(widget.room.talkUser.name),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.messageSnapshot(widget.room.roomId),
              builder: (context, snapshot) {
                return FutureBuilder(
                  future: getMessages(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                        physics: RangeMaintainingScrollPhysics(), // NOTE: RangeMaintainingScrollPhysicsは画面幅を超えた時だけスクロール可能にする
                        reverse: true,
                        shrinkWrap: true,  // NOTE shrinkWrapはListの行数分をmaxとして扱う（画面表示件数に影響）
                        itemCount: messageList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              textDirection: messageList[index].isMe
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                Container(
                                    constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                        color: messageList[index].isMe
                                            ? Colors.green
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Text(messageList[index].message)),
                                Text(
                                  intl.DateFormat("HH:mm").format(messageList[index].sendTime.toDate()),
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          );
                        });
                    }
                  );
              }
            ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60, color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()
                    ),
                  )),
                  IconButton(icon: Icon(Icons.send), onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      await Firestore.sendMessage(widget.room.roomId, controller.text);
                      controller.clear();
                    }
                  },)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
