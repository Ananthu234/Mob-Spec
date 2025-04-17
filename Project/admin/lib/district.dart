import 'package:admin/main.dart';
import 'package:flutter/material.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  TextEditingController districtController = TextEditingController();
  List<Map<String, dynamic>> fetchdistrict = [];

@override
void initState(){
  super.initState();
  fetchdata();
}

  Future<void> insert() async {
    try {
      await supabase
          .from("tbl_district")
          .insert({'district_name': districtController.text});
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
      final response = await supabase.from("tbl_district").select();
      setState(() {
        fetchdistrict = response;
      });
    } catch (e) {}
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_district').delete().eq('id', id);
      fetchdata();
      districtController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
      ));
    } catch (e) {
      print("Error deleting $e");
    }
  }

  int eid=0;

  Future<void> editdistrict() async
  {
    try {
      await supabase.from("tbl_district").update({'district_name':districtController.text}).eq("id", eid);
       fetchdata();
       districtController.clear();
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: districtController,
                    decoration: InputDecoration(
                      hintText: "District",
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
                      editdistrict();
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
            color: Colors.white,
          ),
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Divider();
            },
            shrinkWrap: true,
            itemCount: fetchdistrict.length,
            itemBuilder: (context, index) {
              final _district = fetchdistrict[index];
              return ListTile(
                leading: Text(
                  _district['district_name'],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            delete(_district['id']);
                          },
                          icon: Icon(Icons.delete_forever_outlined)),
                        IconButton(onPressed: () {
                          setState(() {
                            districtController.text=_district['district_name'];
                            eid=_district['id'];
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
