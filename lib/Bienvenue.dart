import 'package:flutter/material.dart';
import 'package:projectkiaforest/Pages/Composants/body.dart';

class Bienvenue extends StatefulWidget {
  const Bienvenue({Key? key}) : super(key: key);

  @override
  State<Bienvenue> createState() => _BienvenueState();
}

class _BienvenueState extends State<Bienvenue> {
  @override
  Widget build(BuildContext context) {
    return Body();
  }
}
