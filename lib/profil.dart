import 'package:flutter/material.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/productList.dart';
import 'package:projectkiaforest/accueil.dart';
import 'package:projectkiaforest/notification.dart';
import 'package:projectkiaforest/navbar.dart';
import 'package:projectkiaforest/modifierProfil.dart';
//import 'package:projectkiaforest/accueilAcheteur.dart';
import 'package:projectkiaforest/panier_acheteur.dart';
import 'package:projectkiaforest/statistique.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectkiaforest/main.dart';
import 'package:projectkiaforest/panierRamasseur.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Profil extends StatefulWidget {
  const Profil({Key? key}) : super(key: key);

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  int _currentIndex = 3;
  //bool statut = false;
  //bool stat = false;
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
  String? solde;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;
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
      solde = myprefs.getString('solde') ?? '';
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (_currentIndex) {
      case 0:
        var root = MaterialPageRoute(builder: (BuildContext context) => Accueil() );
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
  void initState() {
    super.initState();
    chargement();
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
      'Kiaforest',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }
  @override
  Widget build(BuildContext context) {
    bool stat = statut == 'ramasseur';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins'),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xCC458535),
        actions: [
          Row(
            children: [
              stat?
              Text('Solde: $solde FCFA'): SizedBox(width: 2,), // Remplacez '50€' par la valeur réelle du solde
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  // Votre logique pour l'action onPressed
                  if (stat) {
                    var root = MaterialPageRoute(
                        builder: (BuildContext context) => CartRamasseurPage());
                    Navigator.of(context).push(root);
                  } else {
                    var root = MaterialPageRoute(
                        builder: (BuildContext context) => CartAcheteurPage());
                    Navigator.of(context).push(root);
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Empêcher le retour arrière d'agir sur l'AppBar
          return false;
        },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey,
                        offset: Offset(2, 6),
                      ),
                    ],
                    color: Color(0xCC458535),
                  ),
                  height: displayHeight(context) * 0.3,
                  width: displayWidth(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: displayHeight(context) * 0.07),
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: displayHeight(context)* 0.08,
                        child: Text(
                          nom![0],
                          style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$nom',
                            style: TextStyle(color: Colors.white, fontSize: displayWidth(context) * 0.062),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                child: Text(
                                  'Numéro de téléphone',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: displayWidth(context) * 0.050,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  numero!,
                                  style: TextStyle(fontSize: displayWidth(context) * 0.045, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                                child: Text(
                                  'Lieu de résidence',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: displayWidth(context) * 0.050,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  lieu!,
                                  style: TextStyle(fontSize: displayWidth(context) * 0.045, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        color: Colors.grey[200],
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  'Statut',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: displayWidth(context) * 0.050,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Text(
                                  '$statut',
                                  style: TextStyle(fontSize: displayWidth(context) * 0.045, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          //SizedBox(height: ),

                          if(stat)
                          ElevatedButton(
                            onPressed: () {
                              var root = MaterialPageRoute(builder: (BuildContext context) => StatisticsPage() );
                              Navigator.of(context).push(root);
                            },
                            child: Text('Voir mes statistiques'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xCC458535),
                              //padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async{
                              SharedPreferences myprefs = await SharedPreferences.getInstance();
                              myprefs.setString('nom', ' ');
                              myprefs.setString('username', ' ');
                              myprefs.setString('numero', ' ');
                              myprefs.setString('lieu', ' ');
                              myprefs.setString('statut', ' ');
                              myprefs.setBool('isconnected', false);

                              var root = MaterialPageRoute(builder: (BuildContext context) => myApp());
                                  Navigator.of(context).push(root);
                            },
                            child: Text('Déconnexion'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          left: displayWidth(context) * 0.73,
        ),
      ),
    );
  }
}
