import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// @chirag9710 and @juniorbomb update documentation
class NotificationService {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        // onSelectNotification: (String? payload) async {}
        );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          "onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
      NotificationService.showNotification(
          message, flutterLocalNotificationsPlugin, false);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          "onOpenApp: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
    });
  }

  static Future<void> showNotification(RemoteMessage message,
      FlutterLocalNotificationsPlugin fln, bool data) async {
    if (!Platform.isIOS) {
      String _title;
      String _body;
      String _image = "";
      if (data) {
        _title = message.data['title'];
        _body = message.data['body'];
        _image =
            (message.data['image'] != null && message.data['image'].isNotEmpty)
                ? message.data['image'].startsWith('http')
                    ? message.data['image']
                    : ''
                : null;
      } else {
        _title = message.notification?.title ?? "";
        _body = message.notification?.body ?? "";
        if (Platform.isAndroid) {
          _image = ((message.notification?.android?.imageUrl != null &&
                      (message.notification?.android?.imageUrl?.isNotEmpty ??
                          false))
                  ? (message.notification?.android?.imageUrl
                              ?.startsWith('http') ??
                          false)
                      ? message.notification?.android?.imageUrl
                      : ''
                  : null) ??
              "";
        } else if (Platform.isIOS) {
          _image = ((message.notification?.apple?.imageUrl != null &&
                      (message.notification?.apple?.imageUrl?.isNotEmpty ??
                          false))
                  ? (message.notification?.apple?.imageUrl
                              ?.startsWith('http') ??
                          false)
                      ? message.notification?.apple?.imageUrl
                      : ''
                  : null) ??
              "";
        }
      }
      if (_image.isNotEmpty) {
        try {
          await showBigPictureNotificationHiddenLargeIcon(
              _title, _body, _image, fln);
        } catch (e) {
          await showBigTextNotification(_title, _body, fln);
        }
      } else {
        await showBigTextNotification(_title, _body, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body,
      String orderID, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Praisefy',
      'Praisefy',
      playSound: true,
      importance: Importance.max,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
        Random().nextInt(10000), title, body, platformChannelSpecifics,
        payload: orderID);
  }

  static Future<void> showBigTextNotification(
      String title, String body, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Praisefy',
      'Praisefy',
      importance: Importance.max,
      styleInformation: bigTextStyleInformation,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
        Random().nextInt(10000), title, body, platformChannelSpecifics);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String title,
      String body, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Praisefy',
      'Praisefy',
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      priority: Priority.max,
      playSound: true,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
        Random().nextInt(10000), title, body, platformChannelSpecifics);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
