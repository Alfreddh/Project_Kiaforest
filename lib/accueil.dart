import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/customTextField.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:projectkiaforest/un_produit.dart';
import 'package:projectkiaforest/panier_acheteur.dart';
import 'package:projectkiaforest/panierRamasseur.dart';
import 'package:projectkiaforest/navbar.dart';
import 'package:projectkiaforest/productList.dart';
import 'package:projectkiaforest/notification.dart';
import 'package:projectkiaforest/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectkiaforest/localisation.dart';
import 'package:projectkiaforest/singleTuto.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/io.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeScreen();
}
class Plant {
  final String name;
  final String imageUrl;
  final String id;

  Plant({required this.name, required this.imageUrl, required this.id});
}

class Product {
  final String name;
  final String imageUrl;
  final String quantite;
  final String id;
  Product({required this.name, required this.imageUrl, required this.quantite, required this.id});
}

class Tutorial {
  final String title;
  final String imageUrl;
  final String id;

  Tutorial({required this.title, required this.imageUrl, required this.id});
}

class HomeScreen extends State<Accueil> {
  //final channel = new IOWebSocketChannel.connect('https://liberaservice.com/')
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;

  //socket.connect();
  List<Plant> _plants = [];
  List<Product> _products = [];
  List<Tutorial> _tutorials = [];
  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (_currentIndex) {
      case 0:
        var root =
        MaterialPageRoute(builder: (BuildContext context) => Accueil());
        break;
      case 1:
        var root =
        MaterialPageRoute(builder: (BuildContext context) => ProductListPage());
        Navigator.of(context).push(root);
        break;
      case 2:
        var root = MaterialPageRoute(
            builder: (BuildContext context) => Notificationss());
        Navigator.of(context).push(root);
        break;
      case 3:
        var root =
        MaterialPageRoute(builder: (BuildContext context) => Profil());
        Navigator.of(context).push(root);
        break;
      default:
        var root =
        MaterialPageRoute(builder: (BuildContext context) => Accueil());
        Navigator.of(context).push(root);
    }
  }

  final ScrollController _scrollController = ScrollController();
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  String? latitude;
  String? longitude;
  String? solde;
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
    _fetchData();
  }
  @override
  void initState() {
    super.initState();
    chargement();
    fetchOption();
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
  Future<void> _fetchData() async {
    try {
      final plantResponse = await http.get(
          Uri.parse('https://liberaservice.com/gtikia/api/plantes?longitude=$longitude&latitude=$latitude'));
      final productResponse = await http.get(
          Uri.parse('https://liberaservice.com/gtikia/api/liste-tout'));
      final tutorialResponse = await http.get(
          Uri.parse('https://liberaservice.com/gtikia/api/plantes?longitude=$longitude&latitude=$latitude'));
      if (plantResponse.statusCode == 200 &&
          productResponse.statusCode == 200 &&
          tutorialResponse.statusCode == 200) {
        final plantJsonData = jsonDecode(plantResponse.body);
        final productJsonData = jsonDecode(productResponse.body);
        final tutorialJsonData = jsonDecode(plantResponse.body);

        List<Plant> plants = [];
        for (var plantData in plantJsonData) {
          plants.add(Plant(
            name: (plantData['nom'] ?? '').toString(),
            id: (plantData['id'] ?? '').toString(),
            imageUrl: (plantData['image'] ?? 'https://th.bing.com/th/id/OIP.5f5_IjMFWHzzHt9xU_LweAHaE8?pid=ImgDet&rs=1').toString(),
          ));
        }
        List<Product> products = [];
        for (var productData in productJsonData) {
          products.add(Product(
            name: productData['nomProduit'].toString(),
            quantite: productData['quantite'].toString(),
            id: productData['id'].toString(),
            imageUrl: productData['image'].toString(),
          ));
        }
        List<Tutorial> tutorials = [];
        for (var tutorialData in tutorialJsonData) {
          tutorials.add(Tutorial(
            title: (tutorialData['nom'] ?? '').toString(),
            id: (tutorialData['id'] ?? '').toString(),
            imageUrl: (tutorialData['image']?? '').toString(),
          ));
        }

        setState(() {
          _plants = plants;
          _products = products;
          _tutorials = tutorials;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    bool stat = statut == 'ramasseur';
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'KIAFOREST',
            style: TextStyle(
                fontSize: 30.0,
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
          return false;
        },
        child: Column(
          children: [

        Container(
        decoration: BoxDecoration(
        color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(10),
        constraints:
        BoxConstraints(maxWidth: displayWidth(context) * 0.96),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              'Rechercher un produit:',
              style: TextStyle(
                  fontSize: displayWidth(context) * 0.06,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 5),
            CustomTextField(
              controller: searchController,
              hintText: 'Rechercher un produit',
              prefixicon: Icons.search,
              keybaordType: TextInputType.text,
            ),

            SizedBox(height: 5),
            stat?
            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: displayWidth(context) * 0.7,
                maxHeight: displayHeight(context) * 0.07,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _AddProduct(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                    ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.add,
                          color: Colors.white,),
                          SizedBox(width: 5),
                          Text(
                            'Ajouter un produit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ): SizedBox(height: 20,),
          ],
        ),
      ),
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height *
                          0.57,
                      child: ListView(
                        children: [
                          SizedBox(height: 16),
                          stat ?
                          Text(
                            'Plantes',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ) : SizedBox(height: 8,),
                          SizedBox(height: 8),
                          stat ?
                          Container(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _plants.length,
                              itemBuilder: (context, index) {
                                final plant = _plants[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Localisation(id: plant.id)),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      width: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              child: Image.network(
                                                plant.imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            plant.name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ) : SizedBox(height: 10,),
                          SizedBox(height: 16),
                          Text(
                            'Produits',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 6,
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
                                            'Quantité: ${product.quantite} Kg',
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
                          SizedBox(height: 16),
                          stat ?
                          Text(
                            'Tutoriels',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ) : Text(
                            'Plus proches de chez vous',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8),
                          stat ?
                          Column(
                            children: [
                              for (final tutorial in _plants)
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => singleTuto(id: tutorial.id, nomastuce: tutorial.name, imageUrl: tutorial.imageUrl),
                                      ),
                                    );
                                  },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      margin: EdgeInsets.only(
                                          left: displayWidth(context) * 0.1,
                                          right: displayWidth(context) * 0.1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              child: Image.network(
                                                tutorial.imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            tutorial.name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                ),
                            ],
                          ) : Column(
                            children: [
                              for (final tutorial in _products)
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => singleProduit(
                                          id: tutorial.id,
                                          nomProduct: tutorial.name,
                                          quantite: tutorial.quantite,
                                          imageUrl: tutorial.imageUrl,
                                        ),
                                      ),
                                    );
                                  },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      margin: EdgeInsets.only(
                                          left: displayWidth(context) * 0.1,
                                          right: displayWidth(context) * 0.1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(10),
                                              child: Image.network(
                                                tutorial.imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            tutorial.name,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                ),
                            ],
                          ),
                        ],),
                    ),
                  ]
              ),
        ),
      bottomNavigationBar: Navbar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Color(0xCC458535),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(10),
        width: MediaQuery
            .of(context)
            .size
            .width / 5,
        height: 10,
        //color: _currentIndex == _currentIndex ? Colors.green : Colors.transparent,
        margin: EdgeInsets.only(
          top: 2,
          left: MediaQuery
              .of(context)
              .size
              .width / 4 * _currentIndex + 20,
        ),
      ),
    );
  }
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> options = [];
  var selectedOption;// Variable to store the selected option
  String selectedOptionid = '';
  String quantite = ''; // Variable to store the selected option

  Future<void> fetchOption() async {
    final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/produits-liste'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        options = List<Map<String, dynamic>>.from(jsonData);
      });
    } else {
      // Gestion des erreurs
      print('Erreur lors de la récupération des options : ${response.statusCode}');
    }
  }


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
                              DropdownButtonFormField(
                                value: selectedOption,
                                onChanged: (e){
                                  setState((){
                                    selectedOption = e;
                                  });
                                },
                                items: options.map((option) {
                                  final optionId = option['id'].toString();
                                  final optionName = option['nom'];
                                  return DropdownMenuItem(
                                    value: optionId,
                                    child: Text(optionName),
                                  );}).toList(),
                                decoration: InputDecoration(
                                  labelText: 'Sélectionnez une option',
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
                              ),
                              SizedBox(height: 15,),
                              TextFormField(
                                //controller: TextEditingController(text: quantite),
                                onChanged: (value) {
                                  setState(() {
                                    quantite = value;
                                  });
                                },
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
                              ),
                              SizedBox(height: 5,),
                              ElevatedButton(
                                onPressed: () async{
                                  if (_formKey.currentState!.validate()) {
                                    //String idProduitList = (options.map((e) => e['nom'] == selectedOption ? e['id'] : '0')).toString();
                                    final response =
                                        await http.get(Uri.parse('https://liberaservice.com/gtikia/api/ajouter-proposition-vente?idRamasseur=$id&quantite=$quantite&idProduit=$selectedOption'));
                                    if (response.statusCode == 200) {
                                      final jsonResponse = jsonDecode(response.body);
                                      var verif2 = jsonResponse["erreur"];
                                      print(verif2);
                                      if (!verif2) {
                                        final snackBar = SnackBar(
                                          content: Text('Produit ajouté'),
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                      } else {
                                        final snackBar = SnackBar(
                                          content: Text('Echec lors l\'ajout du produit'),
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        Navigator.of(context).pop();
                                      }
                                    }else{
                                      final snackBar = SnackBar(
                                        content: Text('Requête échouée. Erreur ${response.statusCode}'),
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

class Option {
  final int id;
  final String name;

  Option({required this.id, required this.name});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      name: json['name'],
    );
  }
}
