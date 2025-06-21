import 'dart:convert';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String itemName;
  final String description;
  final double price;
  final String size;
  final String? brand;
  final String? category;
  final String? color;
  final String? material;
  final String? imageBase64;  // Single image in base64 format
  final List<String>? imageBase64List; // List of images in base64 format

  const DetailScreen({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.size,
    this.brand,
    this.category,
    this.color,
    this.material,
    this.imageBase64,
    this.imageBase64List, // Accepting a list of images
  });

  @override
  Widget build(BuildContext context) {
    // Default to the first image if no imageBase64 is provided, or use images from the list if available
    final images = imageBase64List != null && imageBase64List!.isNotEmpty
        ? imageBase64List!
        : imageBase64 != null && imageBase64!.isNotEmpty
            ? [imageBase64!]
            : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display multiple images with border radius
            if (images.isNotEmpty)
              Column(
                children: images.map((imageBase64) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.memory(
                      base64Decode(imageBase64),
                      fit: BoxFit.cover,
                      height: 250,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // Product name (only displayed once above the price)
            Text(
              itemName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Price display
            Text(
              'Rp ${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Size: $size',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            if (category != null)
              Text('Category: $category', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            if (brand != null)
              Text('Brand: $brand', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            if (color != null)
              Text('Color: $color', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            if (material != null)
              Text('Material: $material', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 20),
            
            // Title for Product Description
            const Text(
              'Product Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Improved description display with clearer formatting
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
