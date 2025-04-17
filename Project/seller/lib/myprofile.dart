import 'package:flutter/material.dart';
import 'package:seller/main.dart'; // Ensure this path is correct

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? photoUrl;
  bool isLoading = true; // To show loading state while fetching

  @override
  void initState() {
    super.initState();
    fetchSeller();
  }

  Future<void> fetchSeller() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        print('No authenticated user found');
        setState(() {
          isLoading = false;
        });
        return;
      }
      // Fetch data from 'tbl_seller' table where 'id' matches the authenticated user's ID
      final response = await supabase
          .from('tbl_seller')
          .select()
          .eq('id', uid)
          .single();
      
      setState(() {
        nameController.text = response['seller name'] ?? '';
        emailController.text = response['seller email'] ?? '';
        phoneController.text = response['seller contact'] ?? '';
        photoUrl = response['seller photo'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching seller data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateSeller() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        throw 'No authenticated user found';
      }
      await supabase.from('tbl_seller').update({
        'seller name': nameController.text,
        'seller contact': phoneController.text,
        // Email typically shouldn't be editable, so it's excluded from update
      }).eq('id', uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating seller data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: screenWidth > 800 ? 600 : screenWidth * 0.9,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.deepPurple[100],
                          backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                              ? NetworkImage(photoUrl!)
                              : null,
                          child: photoUrl == null || photoUrl!.isEmpty
                              ? Text(
                                  nameController.text.isNotEmpty
                                      ? nameController.text[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Seller Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your account details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildProfileField('Name', nameController, Icons.person, true),
                        const SizedBox(height: 16),
                        _buildProfileField('Mobile', phoneController, Icons.phone, true,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildProfileField('Email', emailController, Icons.email, false),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: isLoading ? null : _updateSeller,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Uncomment and implement navigation when ready
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const Schangepassword()),
                            // );
                          },
                          child: const Text(
                            'Change Password',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isEditable, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditable,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        prefixIcon: Icon(icon, color: Colors.deepPurple[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}