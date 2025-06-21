import 'dart:convert';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String itemName;
  final String description;
  final double price;
  final String size;
  final String? brand;
  final String? category;
  final String? color;
  final String? material;
  final String? imageBase64; // Single image (first image from the list)

  const ItemCard({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.size,
    this.brand, // Optional
    this.category, // Optional
    this.color, // Optional
    this.material, // Optional
    this.imageBase64, // Optional image parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: imageBase64 != null && imageBase64!.isNotEmpty
            ? Image.memory(
                base64Decode(imageBase64!), // Decode the base64 image to display it
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : null, // If no image is available, don't display anything
        title: Text(itemName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            // Menampilkan harga dengan awalan "Rp"
            Text('Rp ${price.toStringAsFixed(0)}'), // Menggunakan toStringAsFixed untuk menghilangkan desimal
            Text('Size: $size'),
            if (category != null) Text('Category: $category'),
            if (brand != null) Text('Brand: $brand'),
            if (color != null) Text('Color: $color'),
            if (material != null) Text('Material: $material'),
          ],
        ),
      ),
    );
  }
}
