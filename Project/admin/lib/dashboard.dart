import 'package:admin/brand.dart';
import 'package:admin/category.dart';
import 'package:admin/district.dart';
import 'package:admin/phcategory.dart';
import 'package:admin/phone.dart';
import 'package:admin/place.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedIndex = 0;

  List<String> pageName = ['District', 'Category', 'Place', 'Brand','Phcategory','Phone'];

  List<IconData> pageIcon = [
    Icons.location_city,
    Icons.catching_pokemon,
    Icons.place_rounded,
    Icons.branding_watermark,
      Icons.catching_pokemon,
        Icons.branding_watermark,

  ];

  List<Widget> pageContent = [
    District(),
    Category(),
    Place(),
    Brand(),
    Phcategory(),
    Phone(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87, // Dark tech theme
        elevation: 4,
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900, // Dark tech background
              Colors.blueGrey.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // Optional: Uncomment and add a subtle circuit pattern
          // image: DecorationImage(
          //   image: AssetImage("assets/circuit-pattern.png"),
          //   fit: BoxFit.cover,
          //   opacity: 0.1,
          // ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.black.withOpacity(0.9), // Sleek black sidebar
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: pageName.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          print(index);
                          selectedIndex = index;
                        });
                      },
                      leading: Icon(
                        pageIcon[index],
                        color: Colors.blueAccent, // Tech accent color
                        size: 28, // Slightly larger icons
                      ),
                      title: Text(
                        pageName[index],
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.white70, // Highlight selected
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      tileColor: selectedIndex == index
                          ? Colors.blueAccent.withOpacity(0.2)
                          : null, // Highlight selected tile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.all(16), // Add some padding
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.95), // Tech panel
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: pageContent[selectedIndex],
              ),
            )
          ],
        ),
      ),
    );
  }
}