// data.dart

// Daftar kategori produk thrift yang lebih relevan
const List<String> categories = [
  'Pakaian', // Kategori pakaian bekas
  'Sepatu', // Sepatu bekas
  'Tas dan Aksesori', // Tas, dompet, dan aksesori bekas
  'Buku Bekas', // Buku bekas
  'Peralatan Rumah Tangga', // Barang-barang rumah tangga bekas
  'Elektronik Bekas', // Barang elektronik bekas
];

// Daftar ukuran produk untuk pakaian dan sepatu
const Map<String, List<String>> sizes = {
  'Pakaian': ['S', 'M', 'L', 'XL', 'XXL'],
  'Sepatu': ['39', '40', '41', '42', '43'],
};

// Daftar merek produk yang umum di pasar thrift
const Map<String, List<String>> brands = {
  'Pakaian': ['Nike', 'Adidas', 'Levi\'s', 'Zara', 'H&M'],
  'Sepatu': ['Nike', 'Adidas', 'Converse', 'Vans', 'Puma'],
  'Tas dan Aksesori': ['Fossil', 'Coach', 'Louis Vuitton', 'Gucci'],
  'Elektronik Bekas': ['Samsung', 'Sony', 'LG', 'Panasonic'],
};

// Daftar gaya produk thrift
const Map<String, List<String>> styles = {
  'Pakaian': ['Casual', 'Streetwear', 'Formal', 'Boho'],
  'Sepatu': ['Casual', 'Sports', 'Formal'],
  'Tas dan Aksesori': ['Casual', 'Formal', 'Vintage'],
  'Elektronik Bekas': ['Portable', 'Smart', 'Vintage'],
};

// Daftar kondisi produk thrift
const Map<String, List<String>> conditions = {
  'Pakaian': ['Baru', 'Bekas', 'Refurbished'],
  'Sepatu': ['Baru', 'Bekas', 'Refurbished'],
  'Tas dan Aksesori': ['Baru', 'Bekas', 'Refurbished'],
  'Elektronik Bekas': ['Baru', 'Bekas', 'Refurbished'],
};

// Daftar warna produk thrift
const Map<String, List<String>> colors = {
  'Pakaian': ['Merah', 'Biru', 'Putih', 'Hitam'],
  'Sepatu': ['Merah', 'Biru', 'Putih', 'Hitam'],
  'Tas dan Aksesori': ['Merah', 'Hitam', 'Cokelat'],
  'Elektronik Bekas': ['Merah', 'Hitam', 'Putih'],
};

// Daftar material produk thrift
const Map<String, List<String>> materials = {
  'Pakaian': ['Kapas', 'Denim', 'Polyester', 'Wool'],
  'Sepatu': ['Kulit', 'Kanvas', 'Denim'],
  'Tas dan Aksesori': ['Kulit', 'Kanvas', 'Nylon'],
  'Elektronik Bekas': ['Metal', 'Plastik'],
};
