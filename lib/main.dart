import 'package:flutter/material.dart';
import 'package:projectkiaforest/Pages/Composants/body.dart';
import 'package:projectkiaforest/constants.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:projectkiaforest/notif.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectkiaforest/Pages/Informations/information.dart';
import 'package:projectkiaforest/accueil.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  /// Defines the main theme color.
  final MaterialColor themeMaterialColor =
  BaseflowPluginExample.createMaterialColor(
      const Color.fromRGBO(48, 49, 60, 1));

  void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    //FirebaseMessaging
    runApp(const myApp());
  }


  class myApp extends StatefulWidget {

  const myApp({Key? key}) : super(key: key);

  @override
  _myAppState createState() => _myAppState();
  }


  class _myAppState extends State<myApp> {
    late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    String mtoken = " ";
    IO.Socket? socket;
    bool isNewUser = false;
    //String ? mtokenuser = " ";
    late SharedPreferences _prefs;
    bool? isconnect;

    void chargement () async{
      SharedPreferences myprefs = await SharedPreferences.getInstance();
      setState(() {
        isconnect = myprefs.getBool('isconnected') ?? false;
      });
    }
    @override
    void initState() {
      super.initState();
      checkUserStatus();
      chargement();
      //getToken();
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if(!isAllowed){
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      final initializationSettingsIOS = DarwinInitializationSettings();
      final initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Créer une instance de socket
      socket = IO.io('https://liberaservice.com/', <String, dynamic>{
        'transports': ['websocket'], // Spécifie le transport (websocket dans cet exemple)
      });
      // Établir la connexion socket
      socket!.connect();

      // Écouter les événements du serveur
      socket!.on('chat messagee', (data) {
        String message = data; // Récupérer le message de la notification

        // Afficher la notification à l'utilisateur
        afficherNotification(message);
      });
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          isLoading = false; // Les données sont chargées, donc l'indicateur de chargement ne sera plus affiché
        });
      });
      initInfo();
    }
    Future<void> afficherNotification(String message) async {
      const channelId = 'channel_id';
      const channelName = 'Channel Name';
      const channelDescription = 'Channel Description';

      // Configurer les paramètres de la notification
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        //channelId,
        channelName,
        channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
      final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      // Afficher la notification
      await flutterLocalNotificationsPlugin.show(
        0,
        'Kiaforest',
        message,
        platformChannelSpecifics,
        payload: 'notification_payload',
      );
    }
    Future<void> storeFirebaseToken(User user) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('mtoken', user.uid);
    }
    Future<void> checkUserStatus() async {
      SharedPreferences prefes = await SharedPreferences.getInstance();
      String? motoken = prefes.getString('mtoken');

      setState(() {
        isNewUser = motoken == null;
      });
      print(isNewUser);
      if (isNewUser) {
        requestPermission();
        getToken();
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await storeFirebaseToken(currentUser);
        }
      }
    }

    void requestPermission() async{
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized){
        print('permission accordée');
      } else if(settings.authorizationStatus == AuthorizationStatus.provisional){
        print('Permission provisionnelle accordée');
      } else {
        print('Permission refusée');
      }
    }

    void getToken() async{
      var recu = await FirebaseMessaging.instance.getToken().then(
          (token) async{
            setState(() {
              mtoken = token ?? '';
              print("My token est $mtoken");
            });
            print('nouvel utilisateur');
              if (mtoken.isNotEmpty) {
                final response =
                await http.get(Uri.parse(
                    'https://liberaservice.com/firebase/update.php?token=$token'));
                if (response.statusCode == 200) {
                  print('OK $mtoken');
                } else {
                  print('Request failed with status: ${response.statusCode}.');
                }
              }
            //saveToken(token!);
            SharedPreferences prefes = await SharedPreferences.getInstance();
            await prefes.setString('mtoken', mtoken);
          });
    }
    void initInfo() async{

    }
    bool isLoading = true;
    @override
    void dispose() {
      // Fermer la connexion socket lorsque vous n'en avez plus besoin
      socket!.disconnect();
      super.dispose();
    }
    @override
   Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: () async => false, // Désactive le comportement du bouton retour
       child: MaterialApp(
         debugShowCheckedModeBanner: false,
         title: 'KIAFOREST',
         theme: ThemeData(
           primaryColor: KprimaryColor,
           scaffoldBackgroundColor: Colors.white,
         ),
         home: isLoading ? Informations() : isconnect! ? Accueil() : Body(),
       ),
     );
   }
  }