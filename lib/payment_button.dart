// payment_button.dart
import 'package:flutter/material.dart';

class PaymentButton {
  // Static variable to store the selected option persistently
  static String? _selectedOption;

  static void showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                        'Select Payment Method',
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
                  SizedBox(height: 20),
                  
                  // Cash Option
                  ListTile(
                    leading: Icon(Icons.money),
                    title: Text('Cash'),
                    trailing: _selectedOption == 'Cash'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedOption = 'Cash';
                      });
                      Navigator.pop(context);
                      
                    },
                  ),
                  
                  // QR Code Option
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text('QR Code Payment'),
                    trailing: _selectedOption == 'QR Code Payment'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedOption = 'QR Code Payment';
                      });
                      Navigator.pop(context);
                      
                    },
                  ),
                  
                  // UPI Option
                  ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('UPI'),
                    trailing: _selectedOption == 'UPI'
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedOption = 'UPI';
                      });
                      Navigator.pop(context);
                      
                    },
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

  // Optional: Method to get the currently selected option
  static String? getSelectedOption() {
    return _selectedOption;
  }

  // Optional: Method to clear the selection
  static void clearSelection() {
    _selectedOption = null;
  }
}