import 'package:flutter/material.dart';
import '../../colors.dart' as color;

class BookingAcceptDriverRequest extends StatelessWidget {
  final List<Map<String, dynamic>> vehiclesData = [
    {
      'icon': Icons.minor_crash,
      'name': 'Distance',
      'subtitle': '8km away',
      'description': 'Vehicles : Eco, Omni, etc.',
    },
    {
      'icon': Icons.traffic,
      'name': 'Traffic rate',
      'subtitle': '8% (Low)',
      'description': 'Vehicles : Eco, Omni, etc.',
    },
    {
      'icon': Icons.timer,
      'name': 'Estimated Time (ETA)',
      'subtitle': '25 mins',
      'description':
          'Schools in session till 2pm \nBanks open till 5pm \nRoad: Recently repaired',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Accept Request'),
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 249, 249),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Icon(
                vehicleData['icon'],
                size: 20,
                color: color.AppColors
                    .hintColor, // Check if hintColor is defined in colors.dart
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 246, 246, 246),
                  ),
                ),
              ),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        vehicleData['subtitle'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicleData['description'],
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: color.AppColors.borderColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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