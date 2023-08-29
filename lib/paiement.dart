import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class PaymentPage extends StatefulWidget {
  final double prix;
  final int idPanier;

  PaymentPage({required this.prix, required this.idPanier});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String payNumero = '';
  bool? payload;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;

  Future<void> sendPaymentData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/paiement?numero=$payNumero&idPanier=${widget.idPanier}&montant=${widget.prix}'));
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
    }

    @override
    void initState(){
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiment'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: displayHeight(context) * 0.3, left: displayWidth(context) * 0.1, right: displayWidth(context) * 0.1),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.payment),
                    helperStyle: TextStyle(
                        fontSize: displayWidth(context) * 0.031,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xCC458535), width: 1.0),
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 0,
                        color: Colors.grey,
                      ),
                    ),
                    hintText: 'Numéro de Paiement',
                    hintStyle: TextStyle(
                        fontSize: displayWidth(context) * 0.038,
                        fontWeight: FontWeight.normal),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un numéro';
                  }
                  return null;
                },
                onSaved: (value) {
                  payNumero = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  sendPaymentData();
                },
                child: Text('Envoyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xCC458535),
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
