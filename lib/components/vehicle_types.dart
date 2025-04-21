import 'dart:convert';
import 'package:flutter/material.dart';
import '../../colors.dart' as color;

class VehiclesTypes extends StatelessWidget {
  final List<Map<String, dynamic>> vehiclesData = [
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '34 KM',
      'name': 'Patient Transfer',
      'price': 'Rs1000',
      'types': 'Vehicles : Eco, Omni, etc.',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '20 KM',
      'name': 'Basic Life Support (BLS)',
      'price': 'Rs1200',
      'types': 'Vehicles : Bolero, Cruiser, Tavera, Mahindra  Marshal, etc.',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '28 KM',
      'name': 'Advance Life Support(ALS)',
      'price': 'Rs1500',
      'types': 'Vehicles : Traveller, Winger,etc.',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '34 KM',
      'name': 'Dead Body (Medium)',
      'price': 'Rs2000',
      'types':
          'Vehicles : Bolero, Cruiser, Tavera, Innova, Mahindra Marshal, etc.',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '28 KM',
      'name': 'Dead Body (Big)',
      'price': 'Rs1200',
      'types': 'Vehicles : Traveller ,Winger ,etc.',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '34 KM',
      'name': 'Animal Ambulance',
      'price': 'Rs3000',
      'types': 'Ambulances for Animals emergency',
    },
    {
      'image': 'assets/onlineAmbulance.png',
      'distance': '34 KM',
      'name': 'Pink Ambulance',
      'price': 'Rs3000',
      'types': 'Ambulances for Woman emergency',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles Types'),
      ),
      body: ListView.builder(
        itemCount: vehiclesData.length,
        itemBuilder: (BuildContext context, int index) {
          final vehicle = vehiclesData[index];
          return _buildListItem(vehicle);
        },
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> vehicleData) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
            color: Color.fromARGB(255, 246, 246, 246))), // Add border
      ),
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 4, left: 4, right: 4, bottom: 4),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 249, 249),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(vehicleData['image']),
                  ),
                ),
                Text(
                  vehicleData['distance'],
                  style: const TextStyle(
                      fontSize: 12,
                      color: color.AppColors.hintColor,
                      fontWeight: FontWeight.w100),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicleData['name'],
                          style: const TextStyle(
                              fontSize: 14,
                              color: color.AppColors.hintColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        vehicleData['price'],
                        style: const TextStyle(
                            fontSize: 14,
                            color: color.AppColors.textColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicleData['types'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: color.AppColors.borderColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}