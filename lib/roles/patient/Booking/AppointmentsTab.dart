import 'package:flutter/material.dart';

class Appointmentstab extends StatefulWidget {
  const Appointmentstab({super.key});

  @override
  State<Appointmentstab> createState() => _AppointmentstabState();
}

class _AppointmentstabState extends State<Appointmentstab> {
  String selectedCategory = "Up Coming";
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Center(child: Text("My Bookings")),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                _catagory("Up Coming"),

                _catagory("Completed"),
                _catagory("Canceled")
              ],),
            ),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height:250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5),]
                ),
                child: Column(
                  children: [
                    Center(child: Text("May 22, 2023 - 10.00 AM")),
                  ],
                ),

              ),
            )
            
          ],
        ),
      )
    );
  }
  Widget _catagory(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          fontWeight:
          selectedCategory == title ? FontWeight.bold : FontWeight.normal,
          color:
          selectedCategory == title ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

}
