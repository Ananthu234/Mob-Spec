import 'package:flutter/material.dart';
import 'package:user_mobspec/screens/login_screen.dart';
import 'package:user_mobspec/main.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> placeList = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? selectedDistrict;
  String? selectedPlace;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDist();
  }

  Future<void> insert(String uid) async {
  try {
    final response = await supabase.from('tbl_user').insert({
      'id': uid,
      'user_name': nameController.text,
      'user_email': emailController.text,
      'user_contact': contactController.text,
      'user_address': addressController.text,
      'user_psswd': passwordController.text,
      'place_id': selectedPlace != null ? int.parse(selectedPlace!) : null,
    }).select();  // Add .select() to return the inserted data

    print('Insert Response: $response'); // Debug print

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration successful!")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  } catch (e) {
    print('Insert Error: $e'); // Debug print
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration failed: ${e.toString()}")),
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

 Future<void> register() async {
  print('Starting registration...'); // Debug
  if (passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Passwords do not match")),
    );
    return;
  }

  setState(() => isLoading = true);
  try {
    print('Attempting Supabase signUp...'); // Debug
    final authResponse = await supabase.auth.signUp(
      email: emailController.text,
      password: passwordController.text,
    );
    print('Auth Response: ${authResponse.user?.id}'); // Debug

    if (authResponse.user == null) throw Exception('User is null');
    await insert(authResponse.user!.id);
  } catch (e) {
    print('Registration Error: $e'); // Debug
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
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
            color: Colors.transparent,
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
          'User Registration',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          'Create your account',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade800),
      ),
      child: Column(
        children: [
          _buildTextField(nameController, 'Full Name', Icons.person),
          const SizedBox(height: 10),
          _buildTextField(emailController, 'Email', Icons.email),
          const SizedBox(height: 10),
          _buildTextField(contactController, 'Phone', Icons.phone),
          const SizedBox(height: 10),
          _buildTextField(addressController, 'Address', Icons.location_on),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          _buildDropdown(
            'Place',
            selectedPlace,
            placeList,
            'place_name',
            (value) => setState(() => selectedPlace = value!),
          ),
          const SizedBox(height: 10),
          _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
          const SizedBox(height: 10),
          _buildTextField(confirmPasswordController, 'Confirm Password', Icons.lock, isPassword: true),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        labelStyle: const TextStyle(color: Colors.black),
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

  Widget _buildDropdown(
    String hint,
    String? value,
    List<Map<String, dynamic>> items,
    String displayKey,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(color: Colors.black),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.map, color: Colors.black),
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
      items: items.map((item) => DropdownMenuItem<String>(
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
      child: ElevatedButton(
        onPressed: isLoading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}