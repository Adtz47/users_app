import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/adhar_form.dart';
import 'package:users_app/driver_license_form.dart';
import 'package:users_app/driver_registration_form.dart';
import 'package:users_app/fare_button.dart';
import 'package:users_app/find_driver.dart';
import 'package:users_app/firebase_messaging_service.dart';
import 'package:users_app/google_login_page.dart';
import 'package:users_app/loginpage.dart';
import 'package:users_app/options_button.dart';
import 'package:users_app/payment_button.dart';
import 'package:users_app/registration_menu.dart';
import 'package:users_app/sidebar.dart';
import 'package:users_app/vehicle_documents.dart';
import 'package:users_app/vehicle_information.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ This is the fix
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2196F3),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home:  InDriveHomePage(),
    );
  }
}

class InDriveHomePage extends StatefulWidget {
  @override
  _InDriveHomePageState createState() => _InDriveHomePageState();
}

class _InDriveHomePageState extends State<InDriveHomePage> {
  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(22.5726, 88.3639); // Default to Kolkata
  Set<Marker> _markers = {}; // ✅ For current location marker

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
     FirebaseMessagingService().initNotifications(); // ✅ FCM init
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _initialPosition = currentLatLng;

      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId("current_location"),
          position: currentLatLng,
          infoWindow: InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers, // ✅ Show marker
          ),

          // ✅ Ride Request Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📍 Destination Input
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
                    SizedBox(height: 10),

                    // 💰 Offer Fare Button
                    GestureDetector(
                      onTap: () {
                        FareButton.showFare(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_rupee, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Offer your fare', style: TextStyle(color: Colors.black54, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 🚖 Find Driver Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FindDriverPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 197, 252, 14),
                          minimumSize: Size(200, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Find a driver', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Money Currency Button
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                PaymentButton.showPaymentOptions(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: 1)],
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/money-currency.png",
                  width: 30,
                ),
              ),
            ),
          ),

          // ✅ Options Button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                OptionsButton.options(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: 1)],
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/options.png",
                  width: 30,
                ),
              ),
            ),
          ),

          // ✅ Sidebar Menu Button
          Positioned(
            top: 32,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Sidebar()));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4, spreadRadius: 1)],
                ),
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/menu.png",
                  width: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
