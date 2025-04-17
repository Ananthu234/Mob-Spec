import 'package:flutter/material.dart';
import 'package:seller/Product.dart';
import 'package:seller/myprofile.dart';
import 'package:seller/viewcomplaints.dart';
import 'package:seller/vieworders.dart';

class Dashbord extends StatefulWidget {
  const Dashbord({super.key});

  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  int selectedIndex = 0;
  List<String> pageName = [
    'Add Product',
    'my profile',
    'View complaint',
    'View orders',
  ];

  List<IconData> pageIcon = [
    Icons.receipt_long,
    Icons.person,
    Icons.view_list,
    Icons.view_list,
  ];

  List<Widget> pageContent = [
    Product(),
    Myprofile(),
    Viewcomplaint(),
    Vieworders(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Seller Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 4.0, // Adds a shadow for depth
      ),
      // Added drawer
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey.shade800, // Matches the side nav color
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: pageName.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  Navigator.pop(context); // Close the drawer after selection
                },
                selected: selectedIndex == index,
                tileColor: selectedIndex == index
                    ? Colors.blueGrey.shade600
                    : Colors.transparent,
                leading: Icon(
                  pageIcon[index],
                  color: selectedIndex == index ? Colors.white : Colors.white70,
                ),
                title: Text(
                  pageName[index],
                  style: TextStyle(
                    color: selectedIndex == index ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Row(
        children: [
          // Side Navigation Bar (unchanged)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey.shade800, // Darker shade of blue-grey
              padding: EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    selected: selectedIndex == index,
                    tileColor: selectedIndex == index
                        ? Colors.blueGrey.shade600
                        : Colors.transparent,
                    leading: Icon(
                      pageIcon[index],
                      color: selectedIndex == index
                          ? Colors.white
                          : Colors.white70,
                    ),
                    title: Text(
                      pageName[index],
                      style: TextStyle(
                        color: selectedIndex == index
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Main content area (unchanged)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: pageContent[selectedIndex], // Display selected page content
              ),
            ),
          ),
        ],
      ),
    );
  }
}