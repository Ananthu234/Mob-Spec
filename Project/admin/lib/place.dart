import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlacetState();
}

class _PlacetState extends State<Place> {
  TextEditingController placeController = TextEditingController();
  List<Map<String, dynamic>> fetchplace = [];

@override
void initState(){
  super.initState();
  fetchdata();
}

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

  int eid=0;

  Future<void> editplace() async
  {
    try {
      await supabase.from("tbl_place").update({'place_name':placeController.text}).eq("id", eid);
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
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 80,
      ),
      children: [
        Form(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 50,
            ),
            decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(50)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: placeController,
                    decoration: InputDecoration(
                      hintText: "Place",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (eid==0)
                    {
                      insert();
                    }
                    else
                    {
                      editplace();
                    }
                  },
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white54,
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider();
            },
            shrinkWrap: true,
            itemCount: fetchplace.length,
            itemBuilder: (context, index) {
              final _place = fetchplace[index];
              return ListTile(
                leading: Text(
                  _place['place_name'],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            delete(_place['id']);
                          },
                          icon: Icon(Icons.delete_forever_outlined)),
                        IconButton(onPressed: () {
                          setState(() {
                            placeController.text=_place['place_name'];
                            eid=_place['id'];
                          });
                        }, icon: Icon(Icons.edit))
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
