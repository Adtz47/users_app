import 'package:flutter/material.dart';
import 'package:users_app/adhar_form.dart';
import 'package:users_app/vehicle_documents.dart';
import 'package:users_app/vehicle_information.dart';
import 'driver_registration_form.dart';
import 'driver_license_form.dart';

class RegistrationMenu extends StatelessWidget {
  const RegistrationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Personal Information',
        'icon': Icons.person,
        'page': DriverRegistrationForm(),
      },
      {
        'title': 'Driver License',
        'icon': Icons.credit_card,
        'page': DriverLicenseForm(),
      },
      {
        'title': 'Aadhaar Card',
        'icon': Icons.badge,
        'page': AdharForm(),
      },
      {
        'title': 'Vehicle Information',
        'icon': Icons.directions_car,
        'page': VehicleInformationForm(),
      },
      {
        'title': 'Vehicle Documents',
        'icon': Icons.description,
        'page': VehicleDocumentsPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Color.fromARGB(255, 17, 56, 90), // Dark blue color
  elevation: 0,
  
  title: const Text(
    '  Driver Registration Menu',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
  ),
),

      body: Container(
        color: Color.fromARGB(255, 17, 56, 90), // Dark blue background for top portion
        child: Column(
          children: [
            // Spacer for visual balance
            SizedBox(height: 50),
            // Main content area
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item['page']),
                          );
                        },
                        leading: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['icon'], color: Colors.indigo),
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}