import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlacetState();
}

class _PlacetState extends State<Place> {
  final TextEditingController placeController = TextEditingController();
  List<Map<String, dynamic>> distList = [];
  List<Map<String, dynamic>> fetchplace = [];

  @override
  void initState() {
    super.initState();
    fetchdist();
    fetchdata();
  }

  Future<void> fetchdist() async {
    try {
      print("Distrist");
      final response = await supabase.from("tbl_district").select();
      print(response);
      setState(() {
        distList = response;
      });
    } catch (e) {
      print("Error $e");
    }
  }

  String? selectedDistrict;

  Future<void> insert() async {
    try {
      await supabase
          .from("tbl_place")
          .insert({'place_name': placeController.text});
      fetchdata();
      print("inserted");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Data inserted successfully")));
    } catch (e) {
      print("Error $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("insert Failed:$e")));
    }
  }

  Future<void> fetchdata() async {
    try {
      final response = await supabase.from("tbl_place").select();
      setState(() {
        fetchplace = response;
      });
    } catch (e) {}
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_place').delete().eq('id', id);
      fetchdata();
      placeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
      ));
    } catch (e) {
      print("Error deleting $e");
    }
  }

  int eid = 0;

  Future<void> editplace() async {
    try {
      await supabase
          .from("tbl_place")
          .update({'place_name': placeController.text}).eq("id", eid);
      fetchdata();
      placeController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
      children: [
        Form(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent,Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "District",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: selectedDistrict,
                    items: distList.map((district) {
                      return DropdownMenuItem(
                        value: district['id'].toString(),
                        child: Text(
                          district['district_name'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value!;
                      });
                    },
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    controller: placeController,
                    decoration: InputDecoration(
                      hintText: "Place",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (eid == 0) {
                      insert();
                    } else {
                      editplace();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider(color: Colors.grey.shade300);
            },
            shrinkWrap: true,
            itemCount: fetchplace.length,
            itemBuilder: (context, index) {
              final _place = fetchplace[index];
              return ListTile(
                leading: Text(
                  _place['place_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          delete(_place['id']);
                        },
                        icon: Icon(Icons.delete_forever_outlined, color: Colors.red.shade600),
                        tooltip: 'Delete',
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            placeController.text = _place['place_name'];
                            eid = _place['id'];
                          });
                        },
                        icon: Icon(Icons.edit, color: Colors.teal.shade600),
                        tooltip: 'Edit',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}