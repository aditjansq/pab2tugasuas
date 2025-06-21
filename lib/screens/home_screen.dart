import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pabtugasuas/screens/add_sell_screen.dart'; // Import AddSellScreen
import 'package:pabtugasuas/screens/profile_screen.dart'; // Import ProfileScreen
import 'package:pabtugasuas/screens/detail_screen.dart'; // Import DetailScreen
import 'package:pabtugasuas/widgets/item_card.dart'; // Import ItemCard

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Function to change pages based on the BottomNavigationBar selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of pages that will be shown based on BottomNavigationBar selection
  final List<Widget> _screens = [
    HomeContent(), // Home Content page (index 0)
    AddSellScreen(), // Add Sell Screen (index 1)
    ProfileScreen(), // Profile Screen (index 2)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GO Thrift',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent, // Set to transparent for gradient
        elevation: 10,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
      ),
      body: _screens[_selectedIndex], // Display page based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white, // White background for BottomNavigationBar
        selectedItemColor: Colors.blueAccent, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ), // Bold label for selected item
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ), // Label for unselected item
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Home page
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Sell', // Add product page
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', // Profile page
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _searchQuery = ''; // Store the search query

  // Function to search products based on the query
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Makes the content scrollable to avoid overflow
      child: Column(
        children: [
          // Search input will only appear in the Home page
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearch, // Update the search query on text change
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          // Grid displaying the list of products
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No items available.'));
              }

              final items = snapshot.data!.docs;

              // Filter items based on search query
              final filteredItems = items.where((item) {
                final itemName =
                    item['itemName']?.toString().toLowerCase() ?? '';
                return itemName.contains(_searchQuery.toLowerCase());
              }).toList();

              return GridView.builder(
                shrinkWrap: true, // Prevents overflow by allowing the grid to shrink
                physics: NeverScrollableScrollPhysics(), // Disable GridView scrolling, let the parent scroll
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display two columns
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Item aspect ratio
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index].data();
                  final List<dynamic> imageBase64List = item['images'] ?? [];
                  final String? imageBase64 =
                      imageBase64List.isNotEmpty ? imageBase64List[0] : null;

                  return ItemCard(
                    itemName: item['itemName'] ?? 'No name',
                    price: double.tryParse(item['price'].toString()) ?? 0.0,
                    imageBase64: imageBase64,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            itemName: item['itemName'] ?? '',
                            description: item['description'] ?? '',
                            price: double.tryParse(item['price'].toString()) ?? 0.0,
                            size: item['size'] ?? '',
                            brand: item['brand'] ?? '',
                            category: item['category'] ?? '',
                            color: item['color'] ?? '',
                            material: item['material'] ?? '',
                            imageBase64: imageBase64,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String itemName;
  final double price;
  final String? imageBase64;
  final VoidCallback onTap;

  ItemCard({
    required this.itemName,
    required this.price,
    required this.imageBase64,
    required this.onTap, // Pass it through the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Attach the onTap action
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the product image, name, and price here
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.memory(
                base64Decode(imageBase64 ?? ''),
                fit: BoxFit.cover,
                height: 110, // Reduced height to avoid overflow
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flexible(
                child: Text(
                  itemName,
                  maxLines: 1, // Ensuring item name doesn't overflow
                  overflow: TextOverflow.ellipsis, // Truncate text if it's too long
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Rp ${price.toStringAsFixed(0)}', // Changed to Rp
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 8), // Add some spacing below the price
          ],
        ),
      ),
    );
  }
}
