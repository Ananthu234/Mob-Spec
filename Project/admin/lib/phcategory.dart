import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class Phcategory extends StatefulWidget {
  const Phcategory({super.key});

  @override
  State<Phcategory> createState() => _CategorytState();
}

class _CategorytState extends State<Phcategory> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController photocontroller = TextEditingController();
  List<Map<String, dynamic>> fetchcategory = [];
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
          .from("tbl_phcategory")
          .insert({'phcategory_name': categoryController.text,
            'phcategory_photo':photoUrl});
      categoryController.clear();
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
      final response = await supabase.from("tbl_phcategory").select();
      setState(() {
        fetchcategory = response;
      });
    } catch (e) {}
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_phcategory').delete().eq('id', id);
      fetchdata();
      categoryController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
      ));
    } catch (e) {
      print("Error deleting $e");
    }
  }

  int eid=0;

  Future<void> editcategory() async
  {
    try {
      await supabase.from("tbl_phcategory").update({'phcategory_name':categoryController.text}).eq("id", eid);
       fetchdata();
       categoryController.clear();
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
                    controller: categoryController,
                    decoration: InputDecoration(
                      hintText: "Phcategory",
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                 Expanded(
                  child: TextFormField(
                    onTap: handleImagePick,
                    readOnly: true,
                      controller: photocontroller,
                      decoration: InputDecoration(
                        hintText: "categoryPhoto",
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
                      editcategory();
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
            itemCount: fetchcategory.length,
            itemBuilder: (context, index) {
              final _category = fetchcategory[index];
              return ListTile(
                leading:CircleAvatar(
                  backgroundImage: NetworkImage(_category['phcategory_photo']),
                ),
                title: Text(
                  _category['phcategory_name'],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            delete(_category['id']);
                          },
                          icon: Icon(Icons.delete_forever_outlined)),
                        IconButton(onPressed: () {
                          setState(() {
                            categoryController.text=_category['phcategory_name'];
                            photocontroller.text=_category['phcategory_photo'];
                            eid=_category['id'];
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
