import 'package:flutter/material.dart';
import 'package:projectkiaforest/Pages/Informations/information.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
class singleProduit extends StatefulWidget {
  final String imageUrl;
  final String id;
  final String nomProduct;
  final String quantite;
  const singleProduit({Key? key, required this.id, required this.nomProduct, required this.quantite, required this.imageUrl}) : super(key: key);
  @override
  State<singleProduit> createState() => _singleProduitState();
}
class Product {
  final String name;
  final String imageUrl;
  final String quantite;
  final String id;
  Product({required this.name, required this.imageUrl, required this.quantite, required this.id});
}
class _singleProduitState extends State<singleProduit> {
  List<dynamic> dat = [];
  List<dynamic> offers = []; // Liste des offres pour le produit
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
  List<Product> _products = [];
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
    _fetchData();
  }
  bool _isloading = true;
  Future<void> _fetchData() async {
    try {
     final productResponse = await http.get(
          Uri.parse('https://liberaservice.com/gtikia/api/produits?longitude=$longitude&latitude=$latitude'));
      if (productResponse.statusCode == 200) {
        final productJsonData = jsonDecode(productResponse.body);
        List<Product> products = [];
        for (var productData in productJsonData) {
          products.add(Product(
            name: productData['nom'].toString(),
            quantite: (productData['quantite']?? '20Kg').toString(),
            id: productData['id'].toString(),
            imageUrl: (productData['image']?? 'https://th.bing.com/th/id/OIP.5f5_IjMFWHzzHt9xU_LweAHaE8?pid=ImgDet&rs=1').toString(),
          ));
        }
        setState(() {
         _products = products;
         _isloading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    //fetchData();
    //fetchOffers();
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
      String message = data; // Récupérer le message de la notification

      // Afficher la notification à l'utilisateur
      afficherNotification(message);
    });
    //socket.onError((error) {
    //triggernotification(error);
    //streamListener();
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
  void dispose() {
    socket.disconnect();
    // Fermer la connexion socket lorsque vous n'en avez plus besoin
    //socket.disconnect();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool stat = statut == 'acheteur';
    try {
      return Scaffold(
        body: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              height: displayHeight(context) * 0.30,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.opaqueSeparator,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 28,
                              color: Color(0xCC458535),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.nomProduct,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: displayWidth(context) * 0.1,),
                  Text(widget.quantite+'Kg',
                  style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ensuite, nous avons inclus un bouton élevé dans la méthode build qui utilise _isLoading pour désactiver le bouton si le chargement est en cours. Le bouton affiche soit le texte ou un CircularProgressIndicator, en fonction de l'état de _isLoading.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: displayWidth(context) * 0.65),
                      child: Text(
                        'Lire plus',
                        style: TextStyle(
                          //decoration: TextDecoration.underline,
                          color: Color(0xCC458535),
                          fontWeight: FontWeight.w500,
                        ),
                        //textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Plus proche de chez vous",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: displayWidth(context) * 0.75),
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                        color: Color(0xCC458535),
                        fontWeight: FontWeight.w500,
                      ),
                      //textAlign: TextAlign.right,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                _isloading? CircularProgressIndicator():
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => singleProduit(
                                  id: product.id,
                                  nomProduct: product.name,
                                  quantite: product.quantite,
                                  imageUrl: product.imageUrl,
                                ),
                              ),
                            );
                            print('Index de l\'élément : $index');
                          },
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                SizedBox(height: 8),
                                Text(
                                  '${product.name}',
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Quantité: ${product.quantite}',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            stat?
            Container(
            margin: EdgeInsets.only(left: displayWidth(context)*0.2, right: displayWidth(context)*0.2), // Définition de la marge de 8 pixels de tous les côtés
            child: ElevatedButton(
            onPressed: () async{
              //String quantite = widget.quantite;
              _AddProduct(context);
            },
            child: Text('Acheter', style: TextStyle(fontSize: 20),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xCC458535),
                //padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            ): SizedBox(height: 20,),
    ],
        ),
      );
    } catch (e) {
      return Informations();
    }
  }

  final _formKey = GlobalKey<FormState>();
  String? quantite;
  String? prix;
  void _AddProduct(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: SizedBox(
                    width: 300,
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .stretch,
                            children: [
                              SizedBox(height: 10,),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Quantité (Kg)',
                                  suffixText: 'Kg',
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0xCC458535), width: 1.0),
                                      borderRadius: BorderRadius.circular(15)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                //controller: _quantityController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Veuillez entrer une quantité';
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    quantite = value;
                                  });
                                },
                              ),
                              SizedBox(height: 10,),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Prix',
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Color(0xCC458535), width: 1.0),
                                      borderRadius: BorderRadius.circular(15)),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      width: 0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Veuillez entrer un prix';
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    prix = value;
                                  });
                                },
                              ),
                              SizedBox(height: 5,),
                              ElevatedButton(
                                onPressed: () async{
                                  if (_formKey.currentState!.validate()) {
                                    //Navigator.of(context).pop();
                                    String idProposition = widget.id;
                                    final response =
                                        await http.get(Uri.parse('https://liberaservice.com/gtikia/api/ajouter-panier?idAcheteur=$id&quantite=$quantite&prix=$prix&idProposition=$idProposition'));
                                    if (response.statusCode == 200) {
                                      final jsonResponse = jsonDecode(response.body);
                                      var verif1 = jsonResponse["erreur"];
                                      if(verif1){
                                        //SharedPreferences myprefs = await SharedPreferences.getInstance();
                                        final snackBar = SnackBar(
                                          content: Text('Echec de l\'ajout du produit au panier'),
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                        //Navigator.pop(context);
                                      }else{
                                        final snackBar = SnackBar(
                                          content: Text('Produit ajouté au panier'),
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                    else{
                                      print('Requête échouée');
                                      final snackBar = SnackBar(
                                        content: Text('requête échouée. Erreur: ${response.statusCode}'),
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                child: Text('valider'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xCC458535),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Annuler'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xCC458535),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
