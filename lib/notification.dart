import 'package:flutter/material.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/productList.dart';
import 'package:projectkiaforest/accueil.dart';
import 'package:projectkiaforest/profil.dart';
import 'package:projectkiaforest/navbar.dart';
//import 'package:projectkiaforest/produitDB.dart';
//import 'package:projectkiaforest/accueilAcheteur.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectkiaforest/panierRamasseur.dart';
import 'package:projectkiaforest/panier_acheteur.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notificationss extends StatefulWidget {
  const Notificationss({Key? key}) : super(key: key);

  @override
  State<Notificationss> createState() => _NotificationssState();
}

class _NotificationssState extends State<Notificationss> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;
  int _currentIndex = 2;
  List<NotificationItem> notifications = [];
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
  void chargement() async{
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    setState(() {
      nom = myprefs.getString('nom') ?? '';
      numero = myprefs.getString('numero') ?? '';
      lieu = myprefs.getString('ville') ?? '';
      id = myprefs.getString('id') ?? '';
      latitude = myprefs.getString('latitude') ?? '';
      longitude = myprefs.getString('longitude') ?? '';
      statut = myprefs.getString('statut') ?? '';
    });
  }
  @override
  void initState() {
    super.initState();
    chargement();
    // Fetch notifications from API
    fetchNotifications();
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
    socket.connect();

    // Écouter les événements du serveur
    socket.on('chat messagee', (data) {
      String message = data['message']; // Récupérer le message de la notification

      // Afficher la notification à l'utilisateur
      afficherNotification(message);
    });
  }
  @override
  void dispose() {
    // Fermer la connexion socket lorsque vous n'en avez plus besoin
    socket.disconnect();
    super.dispose();
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
      'Nouvelle notification',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (_currentIndex) {
      case 0:
        var root = MaterialPageRoute(builder: (BuildContext context) => Accueil());
        Navigator.of(context).push(root);
        break;
      case 1:
        var root = MaterialPageRoute(builder: (BuildContext context) => ProductListPage() );
        Navigator.of(context).push(root);
        break;
      case 2:
        var root = MaterialPageRoute(builder: (BuildContext context) => Notificationss() );
        Navigator.of(context).push(root);
        break;
      case 3:
        var root = MaterialPageRoute(builder: (BuildContext context) => Profil() );
        Navigator.of(context).push(root);
        break;
      default:
        var root = MaterialPageRoute(builder: (BuildContext context) => Accueil() );
        Navigator.of(context).push(root);
    }
  }
  Future<void> fetchNotifications() async {
    final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/notifications?id=1'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<NotificationItem> fetchedNotifications = [];
      for (var notificationData in jsonData) {
        fetchedNotifications.add(NotificationItem.fromJson(notificationData));
      }
      setState(() {
        notifications = fetchedNotifications;
      });
    }
  }

  void deleteNotification(NotificationItem notification) {
    setState(() {
      notifications.remove(notification);
    });
    // Send API request to delete the notification
    // TODO: Implement API deletion logic
  }
  //ProductDatabase productDatabase = ProductDatabase();
  @override
  Widget build(BuildContext context) {

    bool stat = statut == 'ramasseur';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xCC458535),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              //print(dat[1]["nom"]);
              if(stat) {
                var root = MaterialPageRoute(
                    builder: (BuildContext context) => CartRamasseurPage());
                Navigator.of(context).push(root);
              }else{
                var root = MaterialPageRoute(
                    builder: (BuildContext context) => CartAcheteurPage());
                Navigator.of(context).push(root);
              }
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,

      body: WillPopScope(
        onWillPop: () async {
          // Empêcher le retour arrière d'agir sur l'AppBar
          return false;
        },
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconTheme(
                    data: IconThemeData(size: 24), // Ajuster la taille de l'icône ici
                    child: Icon(Icons.notifications),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notifications[index].title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          notifications[index].description,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Date and Time: ${notifications[index].dateTime}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer cette notification'),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      if (value == 'delete') {
                        deleteNotification(notifications[index]);
                      }
                    },
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color:  Color(0xCC458535),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width / 5,
        height: 10,
        //color: _currentIndex == _currentIndex ? Colors.green : Colors.transparent,
        margin: EdgeInsets.only(
          top: 2,
          left: displayWidth(context) * 0.51,
        ),
      ),
    );
  }
}
class NotificationItem {
  final String title;
  final String description;
  final String dateTime;

  NotificationItem({
    required this.title,
    required this.description,
    required this.dateTime,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['titre'],
      description: json['description'],
      dateTime: (json['temps'] ?? "" ).toString(),
    );
  }
}