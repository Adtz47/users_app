import 'package:flutter/material.dart';

class OptionsButton {
  static void options(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        bool isMoreThan4Passengers = false; // Single declaration here

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Toggle Button (Switch)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "More than 4 passengers",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: isMoreThan4Passengers,
                        onChanged: (value) {
                          setState(() {
                            isMoreThan4Passengers = value; // Update the shared state
                          });
                          print("More than 4 passengers: $value");
                        },
                      ),
                    ],

                  ),

                  SizedBox(height: 20),

                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.comment, color: Colors.black),
                      hintText: 'Comments',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      print("More than 4 passengers selected: $isMoreThan4Passengers");
                      // TODO: Implement ride finding logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 197, 252, 14),
                      minimumSize: Size(450, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}