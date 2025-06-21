import 'package:flutter/material.dart';

// Provider untuk mengelola daftar item favorit
class FavoriteItemsProvider with ChangeNotifier {
  List<String> _favoriteItems = [];

  // Mendapatkan daftar favorit
  List<String> get favoriteItems => _favoriteItems;

  // Menambahkan item ke daftar favorit
  void addFavorite(String itemName) {
    _favoriteItems.add(itemName);
    notifyListeners(); // Memberitahu widget yang mendengarkan perubahan
  }

  // Menghapus item dari daftar favorit
  void removeFavorite(String itemName) {
    _favoriteItems.remove(itemName);
    notifyListeners();
  }
}
