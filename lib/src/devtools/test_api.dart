// import 'dart:async';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class TestApi {
//   static FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
//   FirebaseDatabase database = FirebaseDatabase.instanceFor(app: secondaryApp);
//
//   static final firebaseApp = Firebase.app();
//   final rtdb = FirebaseDatabase.instanceFor(
//       app: firebaseApp,
//       databaseURL:
//           'https://shuru-up-c890a-default-rtdb.asia-southeast1.firebasedatabase.app/');
//
//   StreamSubscription? startListening() {
//     final db = FirebaseDatabase.instanceFor(
//         app: firebaseApp,
//         databaseURL:
//             'https://shuru-up-c890a-default-rtdb.asia-southeast1.firebasedatabase.app/');
//     // FirebaseDatabase db = FirebaseDatabase(
//     //     app: firebaseApp,
//     //     databaseURL:
//     //     '<Our RTDB URl>');
//     db.goOnline();
//     return db.ref().onValue.listen((event) async {
//       final data = event.snapshot.value;
//       if (data != null &&
//           data['title'] != null &&
//           data['subtitle'] != null &&
//           data['id'] != null &&
//           data['title'] != '' &&
//           data['subtitle'] != '') {
//         Message message = Message.fromMap(data);
//         if (widget.prefs.getInt('id') != message.id) {
//           if (message.device == (await deviceInfo.windowsInfo).computerName ||
//               message.device == null) {
//             var toast =
//                 LocalNotification(title: message.title, body: message.subtitle)
//                   ..show();
//             toast.onClick = () {
//               if (message.url != null) {
//                 launchUrl(Uri.parse(message.url!));
//               }
//             };
//             await widget.prefs.setInt('id', message.id);
//           }
//         }
//       }
//     });
//   }
// }
