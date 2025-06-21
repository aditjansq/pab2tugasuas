import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Menambahkan Firebase Auth untuk mendapatkan data pengguna
import 'package:pabtugasuas/screens/home_screen.dart'; // Ganti dengan path yang benar sesuai struktur folder

class AddSellScreen extends StatefulWidget {
  const AddSellScreen({super.key});

  @override
  _AddSellScreenState createState() => _AddSellScreenState();
}

class _AddSellScreenState extends State<AddSellScreen> {
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isLoading = false;
  List<XFile>? _imageFiles = [];

  String? _selectedCategory;
  String? _selectedStyle;
  String? _selectedCondition;
  String? _selectedColor;
  String? _selectedMaterial;

  List<String> styles = [];
  List<String> conditions = [];
  List<String> colors = [];
  List<String> materials = [];

  double? _latitude;
  double? _longitude;
  String? selectedAddress;

  // Menambahkan controller untuk nama pengguna
  String? _userName;
  String? _fullName;

  // Daftar kategori produk
  List<String> categories = [
    'Pakaian',
    'Sepatu',
    'Tas dan Aksesori',
    'Buku Bekas'
  ];

  @override
  void initState() {
    super.initState();

    // Mengambil nama pengguna dari Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'Anonymous'; // Gunakan 'Anonymous' jika tidak ada nama
      });

      // Mengambil nama lengkap dari Firestore jika tersedia
      _getFullName(user.uid);
    }

    // Memeriksa izin lokasi dan mengambil lokasi
    _checkLocationPermissionAndGetLocation();
  }

  // Ambil nama lengkap pengguna dari Firestore
  Future<void> _getFullName(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc['fullname'] ?? 'Anonymous';
        });
      }
    } catch (e) {
      print("Error fetching full name: $e");
    }
  }

  void _setOptions(String category) {
    _selectedStyle = null;
    _selectedCondition = null;
    _selectedColor = null;
    _selectedMaterial = null;
    styles = [];
    conditions = [];
    colors = [];
    materials = [];

    if (category == 'Pakaian') {
      styles = ['Casual', 'Streetwear'];
      conditions = ['New', 'Used'];
      colors = ['Red', 'Blue', 'Black'];
      materials = ['Cotton', 'Leather'];
    } else if (category == 'Sepatu') {
      styles = ['Sporty', 'Casual'];
      conditions = ['New', 'Used'];
      colors = ['Black', 'White'];
      materials = ['Canvas', 'Leather'];
    } else if (category == 'Tas dan Aksesori') {
      styles = ['Casual', 'Formal'];
      conditions = ['New', 'Used'];
      colors = ['Black', 'Brown', 'White'];
      materials = ['Leather', 'Canvas'];
    } else if (category == 'Buku Bekas') {
      conditions = ['New', 'Used'];
      materials = ['Paper', 'Cardboard'];
    }
  }

  void _openCategoryModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return RadioListTile<String>(
              title: Text(categories[index]),
              value: categories[index],
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _setOptions(value!);
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles?.addAll(pickedFiles);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        selectedAddress = "Mengambil lokasi...";
      });

      // Mengecek dan meminta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            selectedAddress = 'Lokasi ditolak';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          selectedAddress = 'Lokasi ditolak secara permanen';
        });
        return;
      }

      // Mendapatkan lokasi pengguna
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;

      _latitude = position.latitude;
      _longitude = position.longitude;

      await _updateAddress(_latitude!, _longitude!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        selectedAddress = 'Gagal mendapatkan lokasi: ${e.toString()}';
      });
    }
  }

  Future<void> _updateAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

        setState(() {
          selectedAddress = address;
        });
      } else {
        setState(() {
          selectedAddress = 'Alamat tidak ditemukan';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        selectedAddress = 'Gagal mendapatkan alamat';
      });
    }
  }

  Future<void> _addItem() async {
    final String itemName = _itemNameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String price = _priceController.text.trim();

    if (itemName.isEmpty ||
        description.isEmpty ||
        price.isEmpty ||
        _selectedCategory == null ||
        _selectedStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String?> encodedImages = [];
      if (_imageFiles != null && _imageFiles!.isNotEmpty) {
        for (var imageFile in _imageFiles!) {
          String? encodedImage = await compressAndEncodeImage(imageFile);
          if (encodedImage != null) {
            encodedImages.add(encodedImage);
          }
        }
      }

      // Menambahkan nama pengupload ke data Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'itemName': itemName,
        'description': description,
        'price': double.tryParse(price) ?? 0.0,
        'category': _selectedCategory,
        'style': _selectedStyle,
        'condition': _selectedCondition,
        'color': _selectedColor,
        'material': _selectedMaterial,
        'createdAt': Timestamp.now(),
        'images': encodedImages,
        'location': {
          'latitude': _latitude,
          'longitude': _longitude,
          'address': selectedAddress,
        },
        'userName': _userName, // Menambahkan nama pengupload
        'fullName': _fullName ?? 'Anonymous', // Menambahkan fullName
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')));

      _itemNameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _imageFiles = [];
        _selectedCategory = null;
        _selectedStyle = null;
        _selectedCondition = null;
        _selectedColor = null;
        _selectedMaterial = null;
        selectedAddress = null;
        _userName = null; // Reset nama pengguna
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> compressAndEncodeImage(XFile imageFile,
      {int maxWidth = 400, int quality = 70}) async {
    final bytes = await File(imageFile.path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    img.Image resized = img.copyResize(image, width: maxWidth);
    List<int> jpg = img.encodeJpg(resized, quality: quality);

    if (jpg.length > 900 * 1024) {
      return null;
    }

    return base64Encode(jpg);
  }

  Future<void> _checkLocationPermissionAndGetLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jual Produk',
          style: TextStyle(fontWeight: FontWeight.bold), // Bold title
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImages,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text("Tambah foto",
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _imageFiles!.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _imageFiles!.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imageFiles![index].path),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("Belum ada foto")),
              const SizedBox(height: 10),
              Text("Judul", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
              _buildTextField(
                  _itemNameController, 'e.g. Levi\'s 578 baggy jeans hitam'),
              const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
              _buildTextField(_descriptionController, 'Tulis deskripsi produk'),
              const Text("Price", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
              _buildTextField(_priceController, 'Price', isNumber: true),
              const SizedBox(height: 20),
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
              GestureDetector(
                onTap: _openCategoryModal,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedCategory ?? 'Select Category'),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (_selectedCategory != null)
                Text("Category: ${_selectedCategory!.toLowerCase()}"),
              const SizedBox(height: 20),
              if (_selectedCategory != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Style", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
                    DropdownButton<String>( 
                      isExpanded: true,
                      value: _selectedStyle,
                      items: styles.map((String style) {
                        return DropdownMenuItem<String>(
                          value: style,
                          child: Text(style),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedStyle = value),
                      hint: const Text("Select Style"),
                    ),
                    const Text("Condition", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
                    DropdownButton<String>( 
                      isExpanded: true,
                      value: _selectedCondition,
                      items: conditions.map((String condition) {
                        return DropdownMenuItem<String>(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCondition = value),
                      hint: const Text("Select Condition"),
                    ),
                    const Text("Color", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
                    DropdownButton<String>( 
                      isExpanded: true,
                      value: _selectedColor,
                      items: colors.map((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedColor = value),
                      hint: const Text("Select Color"),
                    ),
                    const Text("Material", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
                    DropdownButton<String>( 
                      isExpanded: true,
                      value: _selectedMaterial,
                      items: materials.map((String material) {
                        return DropdownMenuItem<String>(
                          value: material,
                          child: Text(material),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedMaterial = value),
                      hint: const Text("Select Material"),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold)), // Bold
              Column(
                children: [
                  if (selectedAddress != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(selectedAddress!),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text("Ambil Lokasi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Tombol dengan latar belakang hitam
                          foregroundColor:
                              Colors.white, // Warna teks tombol putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Border radius sedikit
                          ),
                          minimumSize:
                              const Size(150, 50), // Ukuran tombol sama
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Tombol dengan latar belakang hitam
                          foregroundColor:
                              Colors.white, // Warna teks tombol putih
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Border radius sedikit
                          ),
                          minimumSize:
                              const Size(150, 50), // Ukuran tombol sama
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Upload',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black), // Warna teks hitam
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black), // Label hitam
          filled: true,
          fillColor: Colors.white, // Latar belakang input putih
          border: InputBorder.none, // Menghilangkan border outline
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
