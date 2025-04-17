import 'package:admin/main.dart'; // Assuming this contains Supabase initialization
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Added for PlatformFile

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> phCategories = [];
  List<Map<String, dynamic>> phones = [];

  PlatformFile? photo;
  String? selectedBrand;
  String? selectedPhCategory;

  @override
  void initState() {
    super.initState();
    fetchBrands();
    fetchPhCategories();
    fetchPhones();
  }

  Future<void> fetchBrands() async {
    try {
      final response = await supabase.from("tbl_brand").select();
      setState(() {
        brands = response;
      });
    } catch (e) {
      print("Error fetching brands: $e");
    }
  }

  Future<void> fetchPhCategories() async {
    try {
      final response = await supabase.from("tbl_phcategory").select();
      setState(() {
        phCategories = response;
      });
    } catch (e) {
      print("Error fetching phcategory: $e");
    }
  }

  Future<void> fetchPhones() async {
    try {
      final response = await supabase.from("tbl_phone").select();
      setState(() {
        phones = response;
      });
    } catch (e) {
      print("Error fetching phone: $e");
    }
  }

  Future<void> insert() async {
    try {
      await supabase.from("tbl_phone").insert({
        'phn_name': phoneController.text,
        'phn_details': detailController.text,
        'phn_photo': photo?.path,
        'brand_id': selectedBrand,
        'phcategory_id': selectedPhCategory,
      });
      fetchPhones();
      print("Inserted successfully");
      phoneController.clear();
      detailController.clear();
      photoController.clear();
      setState(() {
        photo = null;
        selectedBrand = null;
        selectedPhCategory = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Phone added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Insert failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> pickPhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          photo = result.files.first;
          photoController.text = photo!.name;
        });
      }
    } catch (e) {
      print("Error picking photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Subtle background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Phone',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Name',
                        labelStyle: TextStyle(color: Colors.teal.shade700),
                        prefixIcon: Icon(Icons.phone_android, color: Colors.teal.shade700),
                        filled: true,
                        fillColor: Colors.teal.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: detailController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Phone Details',
                        labelStyle: TextStyle(color: Colors.teal.shade700),
                        prefixIcon: Icon(Icons.description, color: Colors.teal.shade700),
                        filled: true,
                        fillColor: Colors.teal.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedBrand,
                            onChanged: (value) => setState(() => selectedBrand = value),
                            items: brands.map((brand) {
                              return DropdownMenuItem<String>(
                                value: brand['id'].toString(),
                                child: Text(brand['brand_name']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Brand',
                              labelStyle: TextStyle(color: Colors.teal.shade700),
                              prefixIcon: Icon(Icons.branding_watermark, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedPhCategory,
                            onChanged: (value) => setState(() => selectedPhCategory = value),
                            items: phCategories.map((phCategory) {
                              return DropdownMenuItem<String>(
                                value: phCategory['id'].toString(),
                                child: Text(phCategory['phcategory_name']),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Colors.teal.shade700),
                              prefixIcon: Icon(Icons.category, color: Colors.teal.shade700),
                              filled: true,
                              fillColor: Colors.teal.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: pickPhoto,
                      child: TextField(
                        controller: photoController,
                        enabled: false, // Disable direct editing
                        decoration: InputDecoration(
                          labelText: 'Phone Photo',
                          labelStyle: TextStyle(color: Colors.teal.shade700),
                          prefixIcon: Icon(Icons.image, color: Colors.teal.shade700),
                          suffixIcon: Icon(Icons.upload, color: Colors.teal.shade700),
                          filled: true,
                          fillColor: Colors.teal.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: insert,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Add Phone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}