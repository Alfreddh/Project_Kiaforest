import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectkiaforest/un_produit.dart';
import 'package:projectkiaforest/panier_acheteur.dart';
import 'package:projectkiaforest/navbar.dart';
import 'package:projectkiaforest/accueil.dart';
import 'package:projectkiaforest/notification.dart';
import 'package:projectkiaforest/profil.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectkiaforest/panierRamasseur.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = []; // Liste des produits
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
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
    });
  }
  int _currentIndex = 1;
  //bool statut = true;
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
  bool _isloading = true;
  @override
  void initState() {
    super.initState();
    fetchProducts();
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
      'Nouvelle notification',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }
  Future<void> fetchProducts() async {
    try {
      // Effectuer la requête HTTP pour récupérer les données des produits
      var response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/liste-tout'));

      // Vérifier si la requête a réussi
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        // Parcourir les données JSON et ajouter les produits à la liste
        List<Product> productList = [];
        for (var item in jsonData) {
          var product = Product(
            name: item['nomProduit'].toString(),
            imageUrl: item['image'].toString(),
            quantite: item['quantite'].toString(),
            id: item['id'].toString(),
          );
          productList.add(product);
        }
        // Mettre à jour l'état avec la liste des produits récupérés
        setState(() {
          products = productList;
          _isloading = false;
        });
      } else {
        // La requête a échoué, gérer l'erreur
        print('Erreur lors de la récupération des produits: ${response.statusCode}');
      }
    } catch (error) {
      // Gérer les erreurs lors de la requête HTTP
      print('Erreur lors de la récupération des produits: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool stat = statut == 'ramasseur';
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Produits disponibles',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
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
        body: WillPopScope(
          onWillPop: () async {
            return false;
          }, child: _isloading
            ? Center(
          child: CircularProgressIndicator(),
        ) : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {

            final product = products[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => singleProduit(id: product.id, nomProduct: product.name, quantite: product.quantite, imageUrl: product.imageUrl),
                  ),
                );
              },
              child: ProductTile(product: product),
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
            color: _currentIndex == 1 ? Color(0xCC458535) : Colors.transparent
                .withOpacity(100),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(10),
          width: MediaQuery
              .of(context)
              .size
              .width / 5,
          height: 10,

          margin: EdgeInsets.only(
            top: 2,
            left: displayWidth(context) * 0.28,
          ),
        ),
      );
    }catch(e){
      return Container();
    }
  }
}

class ProductTile extends StatelessWidget {
  final Product product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
          children: [
          Text(
          product.name,
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
          ),
          SizedBox(height: 8), // Espace vertical de 8 pixels
          Text(
           product.quantite+'Kg',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          ),
          ],
          ),
          ),
        SizedBox(height: 10,),
        ],
            ),

          );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final String quantite;
  final String id;
  Product({required this.name, required this.imageUrl, required this.quantite, required this.id});
}
