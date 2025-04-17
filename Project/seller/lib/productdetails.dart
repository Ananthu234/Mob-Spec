import 'package:flutter/material.dart';
import 'package:seller/main.dart'; // Assuming this contains your supabase client
import 'package:intl/intl.dart'; // For currency formatting

class ProductDetails extends StatefulWidget {
  final int product;
  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String name = '';
  String details = '';
  String price = '';
  String photo = '';
  String brandId = '';
  String categoryId = '';
  bool isLoading = true;
  bool hasError = false;
  String brandName = '';
  String categoryName = '';
  List<Map<String, dynamic>> stockHistory = [];
  bool isLoadingOrders = false;
  final TextEditingController stockController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final currencyFormatter = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchStockHistory();
  }

  Future<void> insertStock() async {
    try {
      await supabase.from('tbl_stock').insert({
        'stock_quantity':stockController.text,
        'product_id':widget.product
      });
      _fetchStockHistory();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stock updated")));
      Navigator.pop(context);
    } catch (e) {
      print("ErrorL $e");
    }
  }

  Future<void> _fetchProductDetails() async {
    try {
      final productResponse = await supabase
          .from("tbl_product")
          .select()
          .eq('id', widget.product)
          .single();

      final brandResponse = await supabase
          .from("tbl_brand")
          .select('brand_name')
          .eq('id', productResponse['brand id'])
          .single();

      final categoryResponse = await supabase
          .from("tbl_category")
          .select('category_name')
          .eq('id', productResponse['category id'])
          .single();

      setState(() {
        name = productResponse['product name']?.toString() ?? 'No name';
        photo = productResponse['product photo']?.toString() ?? '';
        details = productResponse['product details']?.toString() ?? 'No details';
        price = productResponse['product price']?.toString() ?? '0';
        brandId = productResponse['brand id']?.toString() ?? '';
        categoryId = productResponse['category id']?.toString() ?? '';
        brandName = brandResponse['brand_name']?.toString() ?? 'Unknown';
        categoryName = categoryResponse['category_name']?.toString() ?? 'Unknown';
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching product details: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchStockHistory() async {
    setState(() {
      isLoadingOrders = true;
    });
    
    try {
      final response = await supabase
          .from("tbl_stock")
          .select()
          .eq('product_id', widget.product)
          .order('created_at', ascending: false);
      
      setState(() {
        stockHistory = List<Map<String, dynamic>>.from(response);
        isLoadingOrders = false;
      });
    } catch (e) {
      print("Error fetching stock history: $e");
      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  Future<void> _showEditProductDialog() async {
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController priceController = TextEditingController(text: price);
    final TextEditingController detailsController = TextEditingController(text: details);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Product Details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await supabase
                    .from('tbl_product')
                    .update({
                      'product name': nameController.text,
                      'product price': priceController.text,
                      'product details': detailsController.text,
                    })
                    .eq('id', widget.product);
                
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    name = nameController.text;
                    price = priceController.text;
                    details = detailsController.text;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 800 && screenWidth <= 1100;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(name.isNotEmpty ? name : 'Product Details'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading product details',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            hasError = false;
                          });
                          _fetchProductDetails();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : isDesktop
                  ? _buildDesktopLayout()
                  : isTablet
                      ? _buildTabletLayout()
                      : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: photo.isNotEmpty
                      ? Image.network(
                          photo,
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 400,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.error, size: 80, color: Colors.grey),
                                ),
                              ),
                        )
                      : Container(
                          height: 400,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currencyFormatter.format(double.tryParse(price) ?? 0),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsCard(),
                const SizedBox(height: 16),
                _buildStockHistoryCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: photo.isNotEmpty
                      ? Image.network(
                          photo,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.error, size: 80, color: Colors.grey),
                                ),
                              ),
                        )
                      : Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currencyFormatter.format(double.tryParse(price) ?? 0),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsCard(),
                const SizedBox(height: 16),
                _buildStockHistoryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo.isNotEmpty
                ? Image.network(
                    photo,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.error, size: 60, color: Colors.grey),
                          ),
                        ),
                  )
                : Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currencyFormatter.format(double.tryParse(price) ?? 0),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildDetailsCard(),
          const SizedBox(height: 16),
          _buildStockHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.category,
            label: 'Category',
            value: categoryName,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            icon: Icons.business,
            label: 'Brand',
            value: brandName,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[800]),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Product Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Edit Description',
                  onPressed: _showEditProductDialog,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              details,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Stock History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  label: const Text('Add Stock'),
                  onPressed: () {
                   showDialog(context: context, builder: (context) {
                     return AlertDialog(
                      title: Text("Add Stock"),
                      content: Form(
                        key: formKey,
                        child: TextFormField(
                          validator: (value) {
                            if(value=="" || value!.isEmpty){
                              return "Please enter a value";
                            }
                          },
                          controller: stockController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter Stock"
                          ),
                      )),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: Text("Cancel")),
                        TextButton(onPressed: (){
                          if(formKey.currentState!.validate()){
                            insertStock();
                          }
                        }, child: Text("Submit"))
                      ],
                     );
                   },);
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            isLoadingOrders
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : stockHistory.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No stock history available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stockHistory.length,
                        itemBuilder: (context, index) {
                          final order = stockHistory[index];
                          return ListTile(
                            
                            title: Text('Stock'),
                            subtitle: Text('Quantity: ${order['stock_quantity']}'),
                            trailing: Text(order['created_at'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  

  

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}