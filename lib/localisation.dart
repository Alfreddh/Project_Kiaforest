import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:projectkiaforest/Pages/Informations/information.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Localisation extends StatefulWidget {
  //final double latitude;
  //final double longitude;
  final String id;
  const Localisation({Key? key, required this.id}) : super(key: key);

  @override
  State<Localisation> createState() => _LocalisationState();
}

class _LocalisationState extends State<Localisation> {
  String? nom;
  String? numero;
  String? lieu;
  String? statut;
  String? id;
  double? latitude;
  double? longitude;
  //double? longi;
  //double? lati;
  void chargement() async{
    SharedPreferences myprefs = await SharedPreferences.getInstance();
    setState(() {
      nom = myprefs.getString('nom') ?? '';
      numero = myprefs.getString('numero') ?? '';
      lieu = myprefs.getString('ville') ?? '';
      id = myprefs.getString('id') ?? '';
      latitude = double.parse(myprefs.getString('latitude') ?? '');
      longitude = double.parse(myprefs.getString('longitude') ?? '');
      statut = myprefs.getString('statut') ?? '';
    });
    fetchData();
  }
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng destinationLocation = LatLng(7.4108485, 2.3448603);
  static const LatLng sourceLocation = LatLng(6.5003224, 2.3448903);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  //double get latitude => widget.latitude;
  //double get longitude => widget.longitude;
  ConnectivityResult? _connectivityResult;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  void getCurrentLocation() async{
    Timer.periodic(Duration(seconds: 5), (Timer timer) async {
    Location location = Location();
    location.getLocation().then(
          (location) {
            currentLocation = location;
            setState(() {
              //currentLocation = location;
            });
            },
    );
    //GoogleMapController googleMapController = await _controller.future;

    //location.onLocationChanged.listen((newloc) {
      //currentLocation = newloc;
      //googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          //zoom: 13.5,
          //target: LatLng(newloc.latitude!, newloc.longitude!))));
      //setState(() {
        //currentLocation = newloc;
      //});
    //});
    //print(currentLocation);
      });
    }
    double? startlatitude;
    double? startlongitude;
    double? distance;
    bool? verification;
  List<double> _latitudes = [];
  List<double> _longitudes = [];
  double? _longitude;
  double? _latitude;
  void fetchData() async {
    var response = await http.get(Uri.parse('https://liberaservice.com/gtikia/api/donnee-plante?longitude=$longitude&latitude=$latitude&idPlante=${widget.id}'));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<double> latitudes = [];
      List<double> longitudes = [];

      for (var item in jsonData) {
        double latitude = double.parse(item['latitude']);
        double longitude = double.parse(item['longitude']);
        latitudes.add(latitude);
        longitudes.add(longitude);
      }
      setState(() {
        _latitudes = latitudes;
        _longitudes = longitudes;
      });

      print('Latitudes: $latitudes');
      print('Longitudes: $longitudes');
    } else {
      print('Erreur lors de la requête HTTP: ${response.statusCode}');
    }
  }
  void startTracking() {
    Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      // Faites quelque chose avec les nouvelles coordonnées, par exemple les afficher à l'écran
      print('Latitude: $latitude, Longitude: $longitude');
    });
  }
  BitmapDescriptor? customMarkerIcon;

  void setCustomMarkerIcon() async {
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'images/R.png',
    );
  }
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late IO.Socket socket;
  @override
  void initState(){
    chargement();
    startTracking();
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
      'Nouvelle notification',
      message,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  @override
  Widget build(BuildContext context) {
    //LatLng sourceLocation = LatLng(latitude, longitude);
    try {
      setCustomMarkerIcon();
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Localisation',
            style: TextStyle(fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xCC458535),
        ),
        body:
        GoogleMap(
          initialCameraPosition:
          CameraPosition(target: sourceLocation, zoom: 13.5,
          ),
          polylines: {
            Polyline(
              polylineId: PolylineId("route"),
              points: polylineCoordinates,
              color: Colors.green,
              width: 6,
            ),
          },
          markers: {
            Marker(
              markerId: MarkerId("currentLocation"),
              position: LatLng(_latitude!, _longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
            for (int i = 0; i < _latitudes.length; i++)
            Marker(
            markerId: MarkerId('marker$i'),
            position: LatLng(_latitudes[i], _longitudes[i]),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          },
          onMapCreated: (mapController) {
            _controller.complete(mapController);
          },
        ),
      );
    }catch(e){
      return Informations();
    }
    }
  }
