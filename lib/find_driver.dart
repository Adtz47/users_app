import 'package:flutter/material.dart';
import 'package:users_app/options_button.dart';

class FindDriverPage extends StatefulWidget {
  const FindDriverPage({Key? key}) : super(key: key);
  

  @override
  _FindDriverPageState createState() => _FindDriverPageState();
  
}

class _FindDriverPageState extends State<FindDriverPage> {
  // Controller for the TextField to capture user input
  final TextEditingController _searchController = TextEditingController();
  bool isNearestDriverAccepted = false;

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Your Fare'),
        backgroundColor: const Color.fromARGB(255, 247, 248, 250),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField for searching drivers
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                
                hintText: 'Rs.',
                hintStyle: TextStyle(fontSize: 40,color: Colors.black ),
                
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Optional: Add logic to filter drivers as the user types
                print('Search input: $value');
              },
            ),
            const SizedBox(height: 20),

            // Column of TextButtons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    print('Nearest Drivers pressed');
                    // TODO: Implement logic to show nearest drivers
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.airplane_ticket_sharp, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Promo Code',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print('Cash button pressed');
                    // TODO: Implement logic to show top-rated drivers
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.money, color: Color.fromARGB(255, 79, 255, 59)),
                      SizedBox(width: 8),
                      Text(
                        'cash',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                
                
              ],
            ),
            const SizedBox(height: 10),
            Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Accept nearest driver", // Label for toggle
                              style: TextStyle(fontSize: 16,color:Colors.black),
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

            const SizedBox(height: 10),
            TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.black),
                        hintText: 'To',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 210),

            // Optional: Add a button to submit the search
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Adjusts spacing between items
  children: [
    // Search Button (Takes up available space)
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          String searchQuery = _searchController.text;
          print('Searching for driver: $searchQuery');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 197, 252, 14),
          minimumSize: const Size(0, 50), // Adjust width dynamically
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Search',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ),

    const SizedBox(width: 10), // Spacing between buttons

    // Floating Options Button (Fixed size)
    GestureDetector(
      onTap: () {
        print("Options button is pressed");
        OptionsButton.options(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          //color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          "assets/images/options.png",
          width: 30,
          
        ),
      ),
    ),
  ],
)

          ],
        ),
      ),
    );
  }
}

// Helper function to navigate to this page
void navigateToFindDriver(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const FindDriverPage()),
  );
}