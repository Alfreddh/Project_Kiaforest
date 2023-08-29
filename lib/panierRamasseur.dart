import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/customTextField.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:projectkiaforest/un_produit.dart';
import 'package:projectkiaforest/panier_acheteur.dart';
import 'package:projectkiaforest/navbar.dart';
import 'package:projectkiaforest/productList.dart';
import 'package:projectkiaforest/notification.dart';
import 'package:projectkiaforest/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CartRamasseurPage extends StatefulWidget {
  @override
  _CartRamasseurPageState createState() => _CartRamasseurPageState();
}

class _CartRamasseurPageState extends State<CartRamasseurPage> {
  int _currentIndex = 0;
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;
  void chargement() async {
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
    fetchCart();
  }

  @override
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
      'Nouvelle notification',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }
  bool isLoading = true;
  List<CartItemModel> cartItems = [];
  List<PayItemModel> payItems = [];
  Future<void> fetchCart() async {
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/liste-proposition?idRamasseur=${myprefs.getString('id')}'));
    final response1 = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/liste-acheteurs?id=${myprefs.getString('id')}'));
    if (response.statusCode == 200 && response1.statusCode == 200) {
      final snackBar1 = SnackBar(
        content: Text('Reponse envoyée'),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              10.0),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          snackBar1);
      print("#####################");
      try {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final jsonData1 = json.decode(response1.body) as List<dynamic>;
        setState(() {
          cartItems = jsonData.map((item) => CartItemModel.fromJson(item)).toList();
          payItems = jsonData1.map((item) => PayItemModel.fromJson(item)).toList();
          isLoading = false;
        });
        print(cartItems);
        } catch (e) {
        print(e);
      }
      print("#####################");
    } else {
      // Gestion des erreurs
      print('Erreur lors de la récupération des options : ${response.statusCode}');
      }
  }
  void removeCartItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }
  void removePayItem(int index) {
    setState(() {
      payItems.removeAt(index);
    });
  }
  @override
  Widget build(BuildContext context) {
    print(cartItems);
    final List<Widget> _tabs = [
      CartTab(cartItem: cartItems, removeCartItem: removeCartItem),
      OrdersTab(cartItem: payItems, removeCartItem: removePayItem),
    ];
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text('Liste des Produits'),
          backgroundColor: Colors.green,
        ),
        resizeToAvoidBottomInset: false,
        body: isLoading? CircularProgressIndicator(): _tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Mes produits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Les offres',
            ),
          ],
          selectedItemColor: Color(0xCC458535),
        ),
      );
    } catch (e) {
      return Container();
    }
  }
}

class CartItemModel {
  final int id;
  final double prix;
  final String quantite;
  final String nomProduit;

  CartItemModel({
    required this.id,
    required this.prix,
    required this.quantite,
    required this.nomProduit,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      prix: double.tryParse( json['prix'] ?? "0")??0,
      quantite: (json['quantite']??"").toString(),
      nomProduit: json['nomProduit']??"",
    );
  }
}
class PayItemModel {
  final int id;
  final double prix;
  final String quantite;
  final String nomProduit;
  final String idAcheteur;

  PayItemModel({
    required this.id,
    required this.prix,
    required this.quantite,
    required this.nomProduit,
    required this.idAcheteur,
  });

  factory PayItemModel.fromJson(Map<String, dynamic> json) {
    return PayItemModel(
      id: json['id'],
      prix: double.tryParse( json['prix'] ?? "0")??0,
      quantite: (json['quantite']??"").toString(),
      nomProduit: (json['nomProduit']??"").toString(),
      idAcheteur: (json['idAcheteur']?? '').toString(),
    );
  }
}

class CartTab extends StatelessWidget {
  final List<CartItemModel> cartItem;
  final Function(int) removeCartItem;

  CartTab({
    required this.cartItem,
    required this.removeCartItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItem.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: ListTile(
                    title: Text(cartItem[index].nomProduit),
                    subtitle: Text('${cartItem[index].quantite}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async{
                            final response1 =
                            await http.get(Uri.parse(
                                'https://liberaservice.com/gtikia/api/proposition-vente-supprimer?id=${cartItem[index].id}'));
                            if (response1.statusCode == 200) {
                              //Navigator.pop(context);
                              removeCartItem(index);
                            } else {
                              await Future.delayed(Duration(seconds: 2));
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Erreur'),
                                    content: Text("Requête échouée."),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                        ),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Retirer'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          ),
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
    );
  }
}

class OrdersTab extends StatelessWidget {
  final List<PayItemModel> cartItem;
  final Function(int) removeCartItem;

  OrdersTab({
    required this.cartItem,
    required this.removeCartItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItem.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: ListTile(
                    title: Text(cartItem[index].nomProduit),
                    subtitle: Text('${cartItem[index].quantite}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async{
                            final response =
                                await http.get(Uri.parse('https://liberaservice.com/gtikia/api/modifier-etat-panier?etat=1&idPanier=${cartItem[index].id}'));
                            if (response.statusCode == 200) {
                              final jsonResponse = jsonDecode(response.body);
                              var verif2 = jsonResponse["erreur"];
                              print(verif2);
                              if (verif2) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Erreur'),
                                      content: Text("Opération échouée."),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                          ),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Succès'),
                                      content: Text("Vente refusée."),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                          ),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                removeCartItem(index);
                              }
                            }
                          },
                          child: Text('Refuser'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async{
                          final response =
                          await http.get(Uri.parse('https://liberaservice.com/gtikia/api/modifier-etat-panier?etat=2&idPanier=${cartItem[index].id}'));
                          if (response.statusCode == 200) {
                          final jsonResponse = jsonDecode(response.body);
                          var verif2 = jsonResponse["erreur"];
                          print(verif2);
                          if (verif2) {
                            showDialog(
                            context: context,
                            builder: (BuildContext context) {
                            return AlertDialog(
                            title: Text('Erreur'),
                            content: Text("Vente échouée."),
                            actions: [
                            ElevatedButton(
                            onPressed: () {
                            Navigator.of(context).pop();
                            },
                            style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            ),
                            child: Text('OK'),
                            ),
                            ],
                            );
                            },
                            );
                          }else {
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                          return AlertDialog(
                          title: Text('Succès'),
                          content: Text("Produit en cours de vente."),
                          actions: [
                          ElevatedButton(
                          onPressed: () {
                          Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          child: Text('OK'),
                          ),
                          ],
                          );
                          },
                          );
                          removeCartItem(index);
                          }
                          }
                          },
                          child: Text('Vendre'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            'Total: \$${cartItem.fold<double>(0, (sum, item) => sum + item.prix)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
