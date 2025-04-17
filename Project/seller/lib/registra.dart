import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seller/dashbord.dart';
import 'package:seller/login.dart';
import 'package:seller/main.dart';

class Registra extends StatefulWidget {
  const Registra({super.key});

  @override
  State<Registra> createState() => _RegistraState();
}

class _RegistraState extends State<Registra> {
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];
  TextEditingController photoController = TextEditingController();
  TextEditingController proofController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  PlatformFile? photo;
  PlatformFile? proof;
  String? selectedDistrict;
  String? selectedPlace;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDist();
  }

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        photo = result.files.first;
        photoController.text = result.files.first.name;
      });
    }
  }

  Future<void> handleProofPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        proof = result.files.first;
        proofController.text = result.files.first.name;
      });
    }
  }

  Future<String?> photoUpload() async {
    try {
      final bucketName = 'photo';
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${photo!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            photo!.bytes!,
          );
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<String?> proofUpload() async {
    try {
      final bucketName = 'photo';
      String formattedDate = DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${proof!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            proof!.bytes!,
          );
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error proof upload: $e");
      return null;
    }
  }

  Future<void> insert(String uid) async {
    String? photoUrl = await photoUpload();
    String? proofUrl = await proofUpload();
    try {
      await supabase.from("tbl_seller").insert({
        'id': uid,
        'seller name': nameController.text,
        'seller email': mailController.text,
        'seller contact': contactController.text,
        'seller address': addressController.text,
        'place id': selectedPlace,
        'seller photo': photoUrl,
        'seller proof': proofUrl,
         'seller password': passwordController.text,

      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashbord()),
      );
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    }
  }

  Future<void> fetchDist() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        distList = response;
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      final response = await supabase.from("tbl_place").select().eq('district_id', id);
      setState(() {
        placeList = response;
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> reg() async {
    if (passwordController.text != conPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final authResponse = await supabase.auth.signUp(
        email: mailController.text,
        password: passwordController.text,
      );
      String uid = authResponse.user!.id;
      await insert(uid);
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_add,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Seller Sign Up',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          'Create your seller account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 117, 152, 182),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade800),
      ),
      child: Column(
        children: [
          ...[
            _buildTextField(nameController, 'Full Name', Icons.person),
            _buildTextField(mailController, 'Email', Icons.email),
            _buildTextField(contactController, 'Phone', Icons.phone),
            _buildTextField(addressController, 'Address', Icons.location_on),
            _buildDropdown(
              'District',
              selectedDistrict,
              distList,
              'district_name',
              (value) {
                setState(() => selectedDistrict = value!);
                fetchPlace(value!);
              },
            ),
            _buildDropdown(
              'Place',
              selectedPlace,
              placeList,
              'place_name',
              (value) => setState(() => selectedPlace = value!),
            ),
            _buildFileField(photoController, 'Photo', handleImagePick, Icons.camera_alt),
            _buildFileField(proofController, 'Proof', handleProofPick, Icons.verified),
            _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
            _buildTextField(conPasswordController, 'Confirm Password', Icons.lock, isPassword: true),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ].map((widget) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: widget,
              )).toList(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: const Text(
              'Already have an account? Login here',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFileField(
    TextEditingController controller,
    String label,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: TextFormField(
        controller: controller,
        enabled: false,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: Icon(Icons.upload_file, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade800),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<Map<String, dynamic>> items,
    String displayKey,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField(
      value: value,
      style: const TextStyle(color: Colors.black),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(Icons.map, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) => DropdownMenuItem(
            value: item['id'].toString(),
            child: Text(item[displayKey]),
          )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(onPressed: (){reg();}, child: Text('Sign in')),
    );
  }
}