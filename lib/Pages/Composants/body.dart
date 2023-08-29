import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:projectkiaforest/localisation.dart';
import 'package:projectkiaforest/inscription.dart';
import 'package:projectkiaforest/Pages/Informations/information.dart';
import 'package:projectkiaforest/Map/main.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/un_produit.dart';
import 'package:projectkiaforest/tutoriels.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:projectkiaforest/accueil.dart';

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:map_launcher/map_launcher.dart';

import 'package:projectkiaforest/maps_sheet.dart';
import 'package:projectkiaforest/show_marker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:projectkiaforest/profil.dart';
import 'package:pinput/pinput.dart';

import '../../customTextField.dart';
class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String montoken = '';
  CountryCode? __countryCode;
  String phonenumber = '';
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formClef = GlobalKey<FormState>();
  bool isLoading = false;
  bool isConnected = true;
  set countryCode(CountryCode countryCode) {}

  void _showcodeincorrectErrorModal() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Code incorrect"),
            content: Text("Le code que vous venez d'entrer est incorrect. Reessayez"),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
  _popup_forgot(size, phonenumber) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.green,
              // title: Container( color: Colors.black,child: Image.asset('assets/images/back1.jpg')),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              // title: Text('Nous avions envoye un au numero +22952623705'),
              contentPadding: EdgeInsets.all(0),
              content: Stack(
                // alignment: Alignment.center,
                children: [
                  ClipPath(
                      clipper: DirectionalWaveClipper(verticalPosition:VerticalPosition.top, horizontalPosition: HorizontalPosition.right),
                      child: Container(
                        // padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30), topRight: Radius.circular(30))
                        ),
                        // padding: EdgeInsets.only(left: 20, right: 20),
                        width: size.width,
                        height: size.height/3,
                        // margin: EdgeInsets.only(top: 40),
                        child: Wrap(

                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 40, left: 20, right: 10),
                                child: Text('Un SMS contenant un code de validation a été envoyé au numero +229$phonenumber.', textAlign: TextAlign.justify,
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, letterSpacing: 1),
                                ),
                            ),
                            SizedBox(height: 50,),
                            Text(' Entrez le code', textAlign: TextAlign.left ,style: TextStyle(fontWeight: FontWeight.w500),),
                            Container(
                              // color: Colors.grey,
                              margin: EdgeInsets.only(top: displayHeight(context) * 0.04,left: displayWidth(context) * 0.06),
                              child: Pinput(
                                length: 4,
                                defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  submittedPinTheme: defaultPinTheme.copyDecorationWith(
                                      color: Color.fromRGBO(234, 239, 243, 1),
                                    ),
                                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                                showCursor: true,
                                androidSmsAutofillMethod:  AndroidSmsAutofillMethod.smsUserConsentApi,
                                //runs when every textfield is filled
                                onCompleted: (String verificationCode) async {
                                  //print(verificationCode);
                                  //print('Latitude: ${_currentPosition.latitude}, Longitude: ${_currentPosition.longitude}',);
                                  //final response2 =
                                  //await http.get(Uri.parse(
                                  //  'https://liberaservice.com/gtikia/api/verificationSms?numero=$phonenumber&code=$verificationCode'));
                                  //if (response2.statusCode == 200) {
                                  //final jsonResponse = jsonDecode(
                                  //    response2.body);
                                  //var verif = jsonResponse["erreur"];
                                  //print(verif);
                                  //if (verif) {
                                  //  print('requête échouée');
                                  // }else {
                                  final response3 =
                                    await http.get(Uri.parse('https://liberaservice.com/gtikia/api/infosUser?numero=$phonenumber'));
                                    if (response3.statusCode == 200) {
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
                                      final jsonResponse1 = jsonDecode(response3.body);
                                      SharedPreferences myprefs = await SharedPreferences.getInstance();
                                        myprefs.setString('nom', jsonResponse1["nom"]);
                                        myprefs.setString('solde', jsonResponse1["solde"]);
                                        myprefs.setString('numero', jsonResponse1["numero"]);
                                        //myprefs.setString(
                                            //'lieu', jsonResponse1["lieu"]);
                                        myprefs.setString('id', jsonResponse1["id"]);
                                        myprefs.setString('latitude',
                                            jsonResponse1["latitude"]);
                                        myprefs.setString('longitude',
                                            jsonResponse1["longitude"]);
                                        myprefs.setString(
                                            'statut', jsonResponse1["role"]);
                                        myprefs.setString(
                                            'id', jsonResponse1["id"]);
                                        myprefs.setString(
                                            'ville', jsonResponse1["ville"]);
                                        myprefs.setBool('isconnected', true);
                                        final snackBar1 = SnackBar(
                                          content: Text('Vous êtes connecté.e'),
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
                                        var root = MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Accueil());
                                        Navigator.of(context).push(root);
                                        triggernotification();
                                      } else {
                                        _showcodeincorrectErrorModal();
                                      }
                                      //triggernotification();
                                      //Navigator.pop(context);
                                      //}
                                      //else{
                                      //_showcodeincorrectErrorModal();
                                      //}
                                      //} else {
                                      //print('Request failed with status: ${response.body}.');
                                      //}
                                    }
    //} else {
    //print('Requête échouée');
          //}
                                //}
                                ),
                            ),
                            //if(isLoading)
                          ],
                        ),
                      )
                  ),
                ],
              )
          );
        });
  }
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(20),
    ),
  );
  void showNumberNotFoundError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text("Votre numéro n'existe pas."),
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

  void _showLoginModal(BuildContext context) {
    showDialog(
        context: context,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connexion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Numéro de téléphone',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            phonenumber = value;
                          });
                        },
                        controller: _phoneController,
                        style: TextStyle(
                          fontSize: 18.0, // définit la taille de la police à 18
                        ),
                        decoration: InputDecoration(

                          prefixIcon:
                          CountryCodePicker(
                            onChanged: (countryCode) {
                              setState(() {
                                __countryCode = countryCode;
                              });
                            },
                            initialSelection: 'BJ',
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            favorite: ['BJ', 'TG', 'CI'],
                            showFlag: true,
                            showFlagMain: true,
                            alignLeft: false,
                            //padding: EdgeInsets.only(right: 8.0),
                            textStyle: TextStyle(fontSize: 18.0, color: Colors.black),
                            flagWidth: 20.0,
                            flagDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                            ),
                          ),
                          labelText: 'Téléphone',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green.shade100,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green.shade100,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez entrer un numéro de téléphone valide.';
                          }
                        },

                      ),
                      SizedBox(height: 12.0),
                      GestureDetector(
                        onTap: () async{
                          setState(() {
                            isLoading = true;
                          });
                          await Future.delayed(Duration(seconds: 5));
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context);
                          var root = MaterialPageRoute(builder: (BuildContext context) => RegistrationPage() );
                          Navigator.of(context).push(root);
                        },
                        child: isLoading
                            ? SpinKitChasingDots(
                          color: Colors.white,
                          size: 20.0,
                        )
                            : Text(
                          "Je n'ai pas de compte",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.green,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(

                        onPressed: () async{
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            final response =
                            await http.get(Uri.parse('https://liberaservice.com/gtikia/api/verification?numero=$phonenumber'));
                            if (response.statusCode == 200) {
                              final jsonResponse = jsonDecode(response.body);
                              var verif2 = jsonResponse["succes"];
                              print(verif2);
                              if (verif2) {
                                final response1 =
                                await http.get(Uri.parse(
                                    'https://liberaservice.com/gtikia/api/smsEnvois?numero=$phonenumber'));
                                if (response1.statusCode == 200) {
                                  //Navigator.pop(context);
                                  await Future.delayed(Duration(seconds: 2));
                                  setState(() {
                                    isLoading = false;
                                  });
                                  _popup_forgot(MediaQuery
                                      .of(context)
                                      .size, phonenumber);
                                } else {
                                  await Future.delayed(Duration(seconds: 2));
                                  setState(() {
                                    isLoading = false;
                                  });
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
                              } else {
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  isLoading = false;
                                });
                                showNumberNotFoundError(context);
                              }
                            }else{
                              await Future.delayed(Duration(seconds: 2));
                              setState(() {
                                isLoading = false;
                              });
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
                            //var root = MaterialPageRoute(builder: (BuildContext context) => Localisation(latitude: latitude, longitude: longitude) );
                            //Navigator.of(context).push(root);
                            //var root = MaterialPageRoute(builder: (BuildContext context) => Profil() );
                            //Navigator.of(context).push(root);
                            print(phonenumber);
                          }
                          //double latitude = _currentPosition.latitude;
                          //double longitude = _currentPosition.longitude;

                        },
                        child: isLoading
                            ? SpinKitChasingDots(
                          color: Colors.white,
                          size: 20.0,
                        )
                            : Text(
                          'Se connecter',
                          style: TextStyle(
                            //fontSize: 20.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xCC458535),
                          padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
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
      },
    );
  }
    );
  }
  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371; // Rayon moyen de la Terre en kilomètres

    // Convertir les degrés en radians
    double startLatRad = degreesToRadians(startLatitude);
    double startLonRad = degreesToRadians(startLongitude);
    double endLatRad = degreesToRadians(endLatitude);
    double endLonRad = degreesToRadians(endLongitude);

    // Calcul des différences de latitude et de longitude
    double latDiff = endLatRad - startLatRad;
    double lonDiff = endLonRad - startLonRad;

    // Calcul de la distance haversine
    double a = pow(sin(latDiff / 2), 2) +
        cos(startLatRad) * cos(endLatRad) * pow(sin(lonDiff / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
  triggernotification(){
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'KIAFOREST',
        body: 'Vous êtes connecté!',
      ),
    );
  }

  @override
  void initState(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    getTokenFromSharedPreferences();
  }

  void getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      montoken = prefs.getString('mtoken') ?? '';
      print("Mon token récupéré depuis les SharedPreferences est $montoken");
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:  WillPopScope(
        onWillPop: () async {
      return false;
      },
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top:0),
            padding: EdgeInsets.only(top: displayWidth(context) * 0.03, left: size.width * 0.01),
            height: size.height * 0.75,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.16,),
                Text(
                  "KIAFOREST",
                  style: TextStyle(fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.13,
                    color: Colors.black87,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.green,
                        offset: Offset(2, 1),
                      ),

                    ],
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: size.height * 0.38,),
                Text('Achetez ou Vendez des produits forestiers non ligneux ici...',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: size.height * 0.25,
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Color(0xAA536957), Color(0XFF002407)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.1,),
                ElevatedButton(

                  onPressed: () async{
                    Future.delayed(Duration.zero, () async{
                      bool locationEnabled = await Geolocator.isLocationServiceEnabled();
                      if (!locationEnabled) {
                        await Geolocator.openLocationSettings();
                      }
                    });
                    _showLoginModal(context);
                  },

                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xCC458535),
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60,),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}




