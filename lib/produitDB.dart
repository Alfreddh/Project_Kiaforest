import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:projectkiaforest/notif.dart';

class ProductDatabase extends ChangeNotifier {
  // Créer la base de données
  Future<Database> _createDatabase() async {
    String path = join(await getDatabasesPath(), 'product_database.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, description TEXT)');
          'INSERT INTO products(1, Andansonia, Un bon produit)';
    });
  }

  // Ajouter un produit à la base de données
  Future<void> addProduct(String name, String description) async {
        Database db = await _createDatabase();
    int id = await db.insert('products', {'name': name, 'description': description});
    notifyListeners();
    // Envoyer une notification
    Notifications.sendNotification('Nouveau produit ajouté', 'Le produit $name a été ajouté.');
  }

  // Récupérer la liste des produits
  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await _createDatabase();
    return await db.query('products');
  }
}
