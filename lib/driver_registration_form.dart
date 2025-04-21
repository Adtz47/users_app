import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'driver_license_form.dart';


final uid = FirebaseAuth.instance.currentUser?.uid;

class DriverRegistrationForm extends StatefulWidget {
  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  String? _imageError;
   bool _isImagePicked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
  final prefs = await SharedPreferences.getInstance();
  final userDoc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();

  if (userDoc.exists) {
    final data = userDoc.data()!;
    setState(() {
      _nameController.text = data['name'] ?? '';
      _surnameController.text = data['surname'] ?? '';
      _dobController.text = data['dob'] ?? '';
      _vehicleController.text = data['vehicle'] ?? '';

      // Load profile image from URL if it exists
      if (data['profile_image'] != null && data['profile_image'].toString().isNotEmpty) {
        _profileImage = File(''); // Temporary assignment
        _downloadAndSetImage(data['profile_image']);
      }
    });

    // Cache locally
    await prefs.setString('driver_name', data['name'] ?? '');
    await prefs.setString('driver_surname', data['surname'] ?? '');
    await prefs.setString('driver_dob', data['dob'] ?? '');
    await prefs.setString('driver_vehicle', data['vehicle'] ?? '');
  } else {
    // Load from SharedPreferences
    setState(() {
      _nameController.text = prefs.getString('driver_name') ?? '';
      _surnameController.text = prefs.getString('driver_surname') ?? '';
      _dobController.text = prefs.getString('driver_dob') ?? '';
      _vehicleController.text = prefs.getString('driver_vehicle') ?? '';
    });
  }
}


Future<void> _downloadAndSetImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;

    final tempDir = Directory.systemTemp;
    final file = await File('${tempDir.path}/profile_image.jpg').writeAsBytes(bytes);

    setState(() {
      _profileImage = file;
    });
  } catch (e) {
    print('Failed to load profile image: $e');
  }
}



  Future<void> _saveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_name', _nameController.text.trim());
    await prefs.setString('driver_surname', _surnameController.text.trim());
    await prefs.setString('driver_dob', _dobController.text.trim());
    await prefs.setString('driver_vehicle', _vehicleController.text.trim());
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dgnjiyfdc';
    final uploadPreset = 'cab_booking_app';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      print('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
        _imageError = null;
        _isImagePicked = true;
      });
    }
  }

void _submitForm() async {
  setState(() {
    _imageError = _profileImage == null ? 'Please select a profile picture' : null;
  });

  if (_formKey.currentState!.validate() && _profileImage != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    String? imageUrl;

    if (_isImagePicked) {
      // If the image was picked, upload to Cloudinary
      imageUrl = await _uploadImageToCloudinary(_profileImage!);
    } else {
      // If no new image was picked, fetch the existing image URL from Firestore
      final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
      imageUrl = doc.data()?['profile_image'];
    }

    Navigator.pop(context);

    if (imageUrl != null) {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
        'user_id': uid,
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'dob': _dobController.text.trim(),
        'vehicle': _vehicleController.text.trim(),
        'profile_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Save the form data to SharedPreferences
      await _saveDataToPrefs();

      // Navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DriverLicenseForm()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed. Please try again')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 17, 56, 90),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 17, 56, 90),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                image: _profileImage != null
                                    ? DecorationImage(
                                        image: FileImage(_profileImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _profileImage == null
                                  ? Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.indigo.withOpacity(0.7),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (_imageError != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _imageError!,
                                style: TextStyle(color: Colors.red, fontSize: 13),
                              ),
                            ),
                          ),
                        const SizedBox(height: 25),
                        Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
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
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.person, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Name is required' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Surname',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
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
                          child: TextFormField(
                            controller: _surnameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your surname',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.person_outline, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Surname is required' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
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
                          child: TextFormField(
                            controller: _dobController,
                            decoration: InputDecoration(
                              hintText: 'DD/MM/YYYY',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.calendar_today, color: Colors.indigo),
                              ),
                            ),
                            keyboardType: TextInputType.datetime,
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Vehicle Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
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
                          child: TextFormField(
                            controller: _vehicleController,
                            decoration: InputDecoration(
                              hintText: 'Make, model, and year',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.directions_car, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Vehicle information is required' : null,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 17, 56, 90),
                              minimumSize: Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
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