import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letsshop/utils/app_constants.dart';

class NotificationScreen extends StatefulWidget {
  final RemoteMessage? message;
  const NotificationScreen({super.key, this.message});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.AppMainColor,
      ),
      body:
      // widget.message != null
      //     ? Padding(
      //       padding: const EdgeInsets.all(16.0),
      //       child: Column(
      //         // ✅ Safe layout
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Card(
      //             elevation: 5,
      //             child: ListTile(
      //               leading: const Icon(
      //                 Icons.notifications_active_outlined,
      //               ),
      //               title: Text(
      //                 widget.message!.notification?.title ?? "No Title",
      //                 style: const TextStyle(fontWeight: FontWeight.bold),
      //               ),
      //               subtitle: Text(
      //                 widget.message!.notification?.body ?? "No Body",
      //               ),
      //             ),
      //           ),
      //           const SizedBox(height: 20),
      //           const Text(
      //             "Extra Data:",
      //             style: TextStyle(
      //               fontSize: 16,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           Text(widget.message!.data['screen'].toString()),
      //         ],
      //       ),
      //     ):
      StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('Order Notifications')
                .doc(user!.uid)
                .collection('Notifications')
                // .where('isSale', isEqualTo: false)
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found! :)'));
          }
          if (snapshot.data != null) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final isSeen = doc['isSeen'] ?? false;

                String docId = snapshot.data!.docs[index].id;
                return GestureDetector(
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('Order Notifications')
                        .doc(user.uid)
                        .collection('Notifications')
                        .doc(docId)
                        .update({'isSeen': true});
                  },
                  child: Card(
                    color: isSeen ? Colors.green[100] : Colors.yellow[100],
                    elevation: isSeen ? 0 : 5,
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CircleAvatar(
                            child: Icon(
                              isSeen ? Icons.done : Icons.notification_add,
                            ),
                          ),
                          if (!isSeen)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(doc['title']),
                      subtitle: Text(doc['body']),
                    ),
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
