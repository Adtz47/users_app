import 'package:flutter/material.dart';

class BookingCanceled extends StatelessWidget {
  const BookingCanceled({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Canceled'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height *
            0.3, // Set height to 30% of screen height
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Set margin of 5px
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 243, 243,
                        243), // Set the background color of the container
                    borderRadius:
                        BorderRadius.circular(8.0), // Apply border radius
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title and Subtitle in vertical layout
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.95,
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                flex: 8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking Canceled',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Your booking has been canceled successfully.',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      20), // Add spacing between text and image
                              Image.asset(
                                'assets/images/checked.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // OK Button with 90% width of the parent
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button press, you can navigate back to the previous screen or any other action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 12, 21),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}