import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seller/main.dart';
import 'package:seller/productdetails.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  // Controllers
  final TextEditingController productController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  // Data Lists
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];

  // Selected Values
  PlatformFile? photo;
  String? selectedBrand;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _fetchCategories();
    _fetchProducts();
  }

  // Data Fetching Methods
  Future<void> _fetchBrands() async {
    try {
      final response = await supabase.from("tbl_brand").select();
      setState(() => brands = response);
    } catch (e) {
      print("Error fetching brands: $e");
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() => categories = response);
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await supabase.from("tbl_product").select();
      setState(() => products = response);
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  // Image Handling Methods
  Future<void> _handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        photo = result.files.first;
        photoController.text = result.files.first.name;
      });
    }
  }

  Future<String?> _uploadPhoto() async {
    try {
      final bucketName = 'photo';
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${photo!.name}";
      await supabase.storage.from(bucketName).uploadBinary(filePath, photo!.bytes!);
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  // Product Insertion
  Future<void> _insertProduct() async {
    String uid = supabase.auth.currentUser!.id;
    String? photoUrl = await _uploadPhoto();
    try {
      await supabase.from("tbl_product").insert({
        'product name': productController.text,
        'product details': detailController.text,
        'product price': priceController.text,
        'brand id': selectedBrand,
        'category id': selectedCategory,
        'product photo': photoUrl,
        'seller_id': uid,
      });
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      _clearForm();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Adding failed: $e")),
      );
    }
  }

  // Delete Product Method
  Future<void> _deleteProduct(int productId) async {
    try {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmDelete != true) return;

      await supabase.from("tbl_product").delete().eq('id', productId);
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
    }
  }

  void _clearForm() {
    productController.clear();
    detailController.clear();
    priceController.clear();
    photoController.clear();
    setState(() {
      selectedBrand = null;
      selectedCategory = null;
      photo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Add New Product',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: productController,
                      decoration: _inputDecoration('Product Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: detailController,
                      maxLines: 3,
                      decoration: _inputDecoration('Product Details'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Price'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField(
                            value: selectedCategory,
                            decoration: _inputDecoration('Category'),
                            items: categories.map((category) {
                              return DropdownMenuItem(
                                value: category['id'].toString(),
                                child: Text(category['category_name']),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => selectedCategory = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: selectedBrand,
                            decoration: _inputDecoration('Brand'),
                            items: brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand['id'].toString(),
                                child: Text(brand['brand_name']),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => selectedBrand = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: photoController,
                      readOnly: true,
                      onTap: _handleImagePick,
                      decoration: _inputDecoration('Select Photo')
                          .copyWith(suffixIcon: const Icon(Icons.image)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _insertProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add Product', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(product: product['id']),
                                  ),
                                );
                              },
                              child: Image.network(
                                product['product photo'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  product['product name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '\$${product['product price'] ?? ''}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _deleteProduct(product['id']),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}