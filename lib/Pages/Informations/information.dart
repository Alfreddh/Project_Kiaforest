import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
class Informations extends StatefulWidget {
  const Informations({Key? key}) : super(key: key);

  @override
  State<Informations> createState() => _InformationsState();
}

class _InformationsState extends State<Informations> {
  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SpinKitChasingDots(
            color: Color(0xCC458535), // Couleur de l'animation
            size: 70.0, // Taille de l'animation
          ),
        ),
      ),
    );
  }

}

