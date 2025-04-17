import 'package:flutter/material.dart';
import 'package:user_mobspec/main.dart';

class Procategory extends StatefulWidget {
  const Procategory({super.key});

  @override
  State<Procategory> createState() => _ProcategoryState();
}

class _ProcategoryState extends State<Procategory> {
  List<Map<String, dynamic>> category = [];

  Future<void> fetchcat() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        category = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories'),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchcat();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Category'),
        backgroundColor: Colors.blue,
      ),
      body: Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: category.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orangeAccent,
                            strokeWidth: 3,
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: category.length,
                          itemBuilder: (context, index) {
                            final data = category[index];
                            return _buildCategoryCard(
                              context,
                              title: data['category_name'] ?? 'Unknown',
                              imageUrl: data['category_photo'] ?? '',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Procategory(),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
    );
  }
}

Widget _buildCategoryCard(BuildContext context, {required String title, required String imageUrl, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}