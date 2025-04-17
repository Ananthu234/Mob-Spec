import 'package:admin/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Brand extends StatefulWidget {
  const Brand({super.key});

  @override
  State<Brand> createState() => _BrandtState();
}

class _BrandtState extends State<Brand> {
  TextEditingController brandController = TextEditingController();
  TextEditingController photocontroller = TextEditingController();
  List<Map<String, dynamic>> fetchbrand = [];

    PlatformFile? photo;

    Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        photo = result.files.first;
        photocontroller.text = result.files.first.name;
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
  

@override
void initState(){
  super.initState();
  fetchdata();
}

  Future<void> insert() async {
    try {
       String? photoUrl = await photoUpload();
      await supabase
          .from("tbl_brand")
          .insert({'brand_name': brandController.text,
          'brand_photo':photoUrl});
          

      fetchdata();
      
      print("inserted");
      brandController.clear();
      photocontroller.clear();
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
      final response = await supabase.from("tbl_brand").select();
      setState(() {
        fetchbrand = response;
      });
    } catch (e) {
       print("Error deleting $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_brand').delete().eq('id', id);
      fetchdata();
      brandController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
      ));
    } catch (e) {
      print("Error deleting $e");
    }
  }

  int eid=0;

  Future<void> editbrand() async
  {
    try {
      await supabase.from("tbl_brand").update({'brand_name':brandController.text}).eq("id", eid);
       fetchdata();
       brandController.clear();
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
                borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: brandController,
                    decoration: InputDecoration(
                      hintText: "Brand",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ), Expanded(
                  child: TextFormField(
                    onTap: handleImagePick,
                      controller: photocontroller,
                      decoration: InputDecoration(
                        hintText: "BrandPhoto",
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
                      editbrand();
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
            itemCount: fetchbrand.length,
            itemBuilder: (context, index) {
              final _brand = fetchbrand[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_brand['brand_photo']),
                ),
                
               title:  Text(
                  _brand['brand_name'],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            delete(_brand['id']);
                          },
                          icon: Icon(Icons.delete_forever_outlined)),
                        IconButton(onPressed: () {
                          setState(() {
                            brandController.text=_brand['brand_name'];
                            photocontroller.text=_brand['brand_photo'];
                            eid=_brand['id'];
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
