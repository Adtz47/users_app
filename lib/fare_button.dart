// payment_button.dart
import 'package:flutter/material.dart';

class FareButton {
  static void showFare(BuildContext context) {
    bool isNearestDriverAccepted = false; // Initial state
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with title and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offer your fare',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: SizedBox(
                      width: 200, // Set a fixed width
                      child: TextField(
                        style: TextStyle(fontSize: 40),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center, // Ensures text input is also centered
                        decoration: InputDecoration(
                          hintText: "Rs.",
                          hintStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft, // Aligns everything to the left
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start, // Ensures left alignment
                      children: [
                        TextButton(
                          onPressed: () => print("Promo code clicked"),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.airplane_ticket, color: Colors.blue),
                              SizedBox(width: 8),
                              Text("Promo code"),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => print("Cash payment selected"),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.money, color: Colors.green),
                              SizedBox(width: 8),
                              Text("Cash"),
                            ],
                          ),
                        ),

                        // Toggle Button (Switch)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Accept nearest driver", // Label for toggle
                              style: TextStyle(fontSize: 16),
                            ),
                            Switch(
                              value: isNearestDriverAccepted,
                              onChanged: (value) {
                                setState(() {
                                  isNearestDriverAccepted = value;
                                });
                                print("Toggle switched: $value");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("Nearest driver accepted: $isNearestDriverAccepted");
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
                      'Done',
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
