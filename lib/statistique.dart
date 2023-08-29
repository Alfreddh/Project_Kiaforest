import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  //Map<String, dynamic> statistics = {}; // Les statistiques récupérées de l'API
  List<dynamic> statistics = [];
  bool _isloading = false;
  @override
  void initState() {
    super.initState();
    fetchStatistics(); // Appel de la fonction pour récupérer les statistiques depuis l'API
  }

  Future<void> fetchStatistics() async {
    final response = await http.get(Uri.parse('https://liberaservice.com/api/plante.php'));
    if (response.statusCode == 200) {
      setState(() {
        statistics = json.decode(response.body);
        _isloading = true;
      });
    } else {
      // Gestion des erreurs en cas d'échec de la requête
      print('Failed to fetch statistics. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques'),
      ),
      body: _isloading
          ?
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  title: Text(
                    'Nombre de produits mis en ligne',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    statistics[0]['nom'],
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Nombre de produits Vendus',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    statistics[0]['nom'],
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
          : Center(
        child: CircularProgressIndicator(), // Affichage d'un indicateur de chargement tant que les statistiques sont en cours de récupération
      ),
    );
  }
}
