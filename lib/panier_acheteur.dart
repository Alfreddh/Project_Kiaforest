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
import 'package:projectkiaforest/paiement.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CartAcheteurPage extends StatefulWidget {
  @override
  _CartAcheteurPageState createState() => _CartAcheteurPageState();
}

class _CartAcheteurPageState extends State<CartAcheteurPage> {
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
      String message = data; // Récupérer le message de la notification

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
  bool _isLoading = true;
  List<CartItemModel> cartItems = [];
  List<PayItemModel> payItems = [];
  Future<void> fetchCart() async{
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/liste-panier?id=${myprefs.getString('id')}'));
    final response1 = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/mes-achats?id=${myprefs.getString('id')}'));
    if (response.statusCode == 200 && response1.statusCode == 200) {
      final snackBar = SnackBar(
        content: Text('Bien'),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              10.0),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          snackBar);
      try {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final jsonData1 = json.decode(response.body) as List<dynamic>;
        setState(() {
          cartItems = jsonData.map((item) => CartItemModel.fromJson(item)).toList();
          payItems = jsonData1.map((item) => PayItemModel.fromJson(item)).toList();
          _isLoading = false;
        });
        print(cartItems);
      } catch (e) {
        print(e);
        final snackBar = SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            snackBar);
      }
      print("#####################");
    } else {
      // Gestion des erreurs
      final snackBar = SnackBar(
        content: Text('${response.statusCode}'),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              10.0),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          snackBar);
      print('Erreur lors de la récupération des options : ${response.statusCode}');
    }
  }
  void removeCartItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }
  @override
  Widget build(BuildContext context) {
    print(cartItems);
    final List<Widget> _tabs = [
      CartTab(cartItem: cartItems, removeCartItem: removeCartItem),
      OrdersTab(cartItem: payItems, removeCartItem: removeCartItem),
    ];
    try {
      return Scaffold(
        appBar: AppBar(
          title: Text('Liste des Produits'),
          backgroundColor: Colors.green,
        ),
        resizeToAvoidBottomInset: false,
        body: //_isLoading? CircularProgressIndicator():
        _tabs[_currentIndex],
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
              label: 'Mon panier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Mes achats',
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
  final int code;
  final double prix;
  final String quantite;
  final String nomProduit;
  final String etat;

  CartItemModel({
    required this.id,
    required this.code,
    required this.prix,
    required this.quantite,
    required this.nomProduit,
    required this.etat,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      prix: double.tryParse( json['prix'] ?? "0")??0,
      quantite: (json['quantite']??"").toString(),
      nomProduit: (json['nomProduit']??"").toString(),
      etat: (json['etat'] ?? "").toString(),
      code: json['code'],
    );
  }
}

class PayItemModel {
  final String id;
  final double prix;
  final String quantite;
  final String nomProduit;
  final String date;

  PayItemModel({
    required this.id,
    required this.prix,
    required this.quantite,
    required this.nomProduit,
    required this.date,
  });

  factory PayItemModel.fromJson(Map<String, dynamic> json) {
    return PayItemModel(
      id: (json['id'] ?? "").toString(),
      prix: double.tryParse( json['prix'] ?? "0")??0,
      quantite: (json['quantite']??"").toString(),
      nomProduit: (json['nomProduit']??"").toString(),
      date: (json['datte']?? '').toString(),
    );
  }
}
class AddProductDialog extends StatefulWidget {
  final double prix;
  final int idPanier;

  AddProductDialog({required this.prix, required this.idPanier});

  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  bool? payload;
  final _formKey = GlobalKey<FormState>();
  String pay_numero = '';

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        pay_numero = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Numéro de paiement',
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xCC458535), width: 1.0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          width: 0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer un numéro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          payload = true;
                        });
                        final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/paiement?numero=$pay_numero&idPanier=${widget.idPanier}&montant=${widget.prix}'));
                        if (response.statusCode == 200) {
                          final jsonResponse = jsonDecode(response.body);
                          var token = jsonResponse["token"];
                          var verif2 = jsonResponse["erreur"];
                          if (!verif2) {
                            final snackBar = SnackBar(
                              content: Text('Transaction créée'),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            await Future.delayed(Duration(seconds: 30));
                            final response1 = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/verifier-paiement?token=$token'));
                            if (response1.statusCode == 200) {
                              final jsonResponse = jsonDecode(response.body);
                              Navigator.of(context).pop(); // Fermer le premier showDialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Opération'),
                                    content: Text("Transfert $jsonResponse."),
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
                              setState(() {
                                payload = false;
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Erreur'),
                                    content: Text("Échec lors de l'initialisation de l'opération."),
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
                              setState(() {
                                payload = false;
                              });
                            }
                          } else {
                            print('Requête échouée');
                            setState(() {
                              payload = false;
                            });
                          }
                        } else {
                          print('Requête échouée');
                          setState(() {
                            payload = false;
                          });
                        }
                      }
                    },
                    child: payload!
                        ? Text('Valider')
                        : Row(children: [CircularProgressIndicator(), Text('Veuillez patienter...')]),
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
                                'https://liberaservice.com/gtikia/api/supprimer-panier?id=${cartItem[index].id}'));
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
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async{
                            cartItem[index].code == 2 ?
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(prix: cartItem[index].prix, idPanier: cartItem[index].id),
                              ),
                            ):
                            showDialog(
                            context: context,
                            builder: (BuildContext context) {
                            return AlertDialog(
                            title: Text('Paiement'),
                            content: Text('La commande est : ${cartItem[index].etat}'), // Remplacez par la variable contenant l'état de la commande
                            actions: <Widget>[
                            TextButton(
                            child: Text('Fermer'),
                            onPressed: () {
                            Navigator.of(context).pop(); // Ferme le AlertDialog
                            },
                            ),
                            ],
                            );
                            },
                            );
                          },
                          child: cartItem[index].code == 2 ? Text('Acheter'): Text('Voir l\'état'),
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
                          onPressed: () {
                            removeCartItem(index);
                          },
                          child: Text('Supprimer'),
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
