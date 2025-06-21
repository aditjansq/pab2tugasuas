import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // List untuk menyimpan item favorit
  List<String> favoriteItems = [];

  // Fungsi untuk menambahkan item ke daftar favorit
  void addFavorite(String itemName) {
    setState(() {
      favoriteItems.add(itemName);
    });
  }

  // Fungsi untuk menghapus item dari daftar favorit
  void removeFavorite(String itemName) {
    setState(() {
      favoriteItems.remove(itemName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Items'),
      ),
      body: favoriteItems.isEmpty
          ? const Center(
              child: Text(
                'Belum ada item favorit.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Menghapus item dari daftar favorit
                      removeFavorite(item);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Metode statis yang bisa dipanggil dari luar (seperti di DetailScreen)
  static void addToFavorites(BuildContext context, String itemName) {
    final _FavoriteScreenState? state =
        context.findAncestorStateOfType<_FavoriteScreenState>();
    state?.addFavorite(itemName);
  }
}
