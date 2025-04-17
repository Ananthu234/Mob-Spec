import 'package:flutter/material.dart';

class Phcategory extends StatefulWidget {
  const Phcategory({super.key});

  @override
  State<Phcategory> createState() => _Phcategorystate();
}

class _Phcategorystate extends State<Phcategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search..",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "CATEGORIES",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 35,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Phcategory(),
                            ));
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.lightGreen,
                          borderRadius: BorderRadiusDirectional.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            "CAM",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadiusDirectional.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.battery_charging_full,
                            color: Colors.white,
                            size: 50,
                          ),
                          Text(
                            "CPU",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                        
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadiusDirectional.circular(20),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mobile_friendly,
                            color: Colors.white,
                            size: 50,
                          ),
                          Text(
                            "BUDGET",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                        
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadiusDirectional.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.storage,
                            color: Colors.white,
                            size: 50,
                          ),
                          Text(
                            "STORAGE",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                        
                      ),
                      
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
