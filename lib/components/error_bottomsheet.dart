import 'package:flutter/material.dart';

class errorBottomsheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  color: const Color.fromARGB(255, 245, 245, 245),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: Image.asset(
                                'assets/images/mark.png',
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Sorry for inconvenience',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 39, 39, 39),
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We are not able to provide service on the route you have selected.we will expand our services soonr',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          'Powered by online ambulance',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child: const Text(
                            'Update Route',
                            style: TextStyle(
                                color: Color.fromARGB(255, 237, 237, 237)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: const Text('Update Route'),
        ),
      ),
    );
  }
}