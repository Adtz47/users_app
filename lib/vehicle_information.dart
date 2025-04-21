import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_app/driver_license_form.dart';
import 'package:users_app/vehicle_documents.dart';

final uid = FirebaseAuth.instance.currentUser?.uid;

class VehicleInformationForm extends StatefulWidget {
  @override
  _VehicleInformationFormState createState() => _VehicleInformationFormState();
}

class _VehicleInformationFormState extends State<VehicleInformationForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _vehicleImage;
  bool _isImagePicked = false;
  bool _isLoadingVehicleImage = false;  // Add loading state flag
  String? _vehicleImageUrlFromCloud;

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _imageError;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('vehicle_information').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _brandController.text = data['brand'] ?? '';
        _modelController.text = data['model'] ?? '';
        _colorController.text = data['color'] ?? '';
        _plateController.text = data['plate_number'] ?? '';
        _yearController.text = data['year'] ?? '';
        _vehicleImageUrlFromCloud = data['vehicle_image_url'];
        
        // Download image in the background if it exists
        if (_vehicleImageUrlFromCloud != null) {
          setState(() {
            _isLoadingVehicleImage = true;  // Set loading state to true
          });
          await _downloadAndSetImage(_vehicleImageUrlFromCloud!);
        }
      } else {
        // fallback to SharedPreferences
        _brandController.text = prefs.getString('vehicle_brand') ?? '';
        _modelController.text = prefs.getString('vehicle_model') ?? '';
        _colorController.text = prefs.getString('vehicle_color') ?? '';
        _plateController.text = prefs.getString('vehicle_plate') ?? '';
        _yearController.text = prefs.getString('vehicle_year') ?? '';
      }
    }
  }

  // Add a method to download and set the image
  Future<void> _downloadAndSetImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      final tempDir = Directory.systemTemp;
      final fileName = 'vehicle_${uid}.jpg';
      final file = await File('${tempDir.path}/$fileName').writeAsBytes(bytes);

      setState(() {
        _vehicleImage = file;
        _isLoadingVehicleImage = false;  // Set loading state to false
      });
    } catch (e) {
      print('Failed to load vehicle image: $e');
      setState(() {
        _isLoadingVehicleImage = false;  // Set loading state to false on error too
      });
    }
  }

  Future<void> _saveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicle_brand', _brandController.text.trim());
    await prefs.setString('vehicle_model', _modelController.text.trim());
    await prefs.setString('vehicle_color', _colorController.text.trim());
    await prefs.setString('vehicle_plate', _plateController.text.trim());
    await prefs.setString('vehicle_year', _yearController.text.trim());
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    final cloudName = 'dgnjiyfdc';
    final uploadPreset = 'cab_booking_app';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'vehicle_images'  // Add folder to organize vehicle images
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
        _vehicleImage = File(picked.path);
        _isImagePicked = true;
        _imageError = null;
      });
    }
  }

  void _submitForm() async {
    setState(() {
      if (_vehicleImage == null && _vehicleImageUrlFromCloud == null) {
        _imageError = 'Please upload photo of your vehicle';
      } else {
        _imageError = null;
      }
    });

    if (_formKey.currentState!.validate() && 
        (_vehicleImage != null || _vehicleImageUrlFromCloud != null)) {
          
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        String? vehicleImageUrl = _vehicleImageUrlFromCloud;

        if (_isImagePicked && _vehicleImage != null) {
          vehicleImageUrl = await _uploadImageToCloudinary(_vehicleImage!);
        }

        Navigator.pop(context);

        if (vehicleImageUrl != null) {
          _vehicleImageUrlFromCloud = vehicleImageUrl;

          await FirebaseFirestore.instance.collection('vehicle_information').doc(uid).set({
            'user_id': uid,
            'brand': _brandController.text.trim(),
            'model': _modelController.text.trim(),
            'color': _colorController.text.trim(),
            'plate_number': _plateController.text.trim(),
            'year': _yearController.text.trim(),
            'vehicle_image_url': vehicleImageUrl,
            'created_at': FieldValue.serverTimestamp(),
          });

          await _saveDataToPrefs();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vehicle information submitted successfully!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VehicleDocumentsPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed. Please try again')),
          );
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
          'Vehicle Information',
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
                        Text(
                          'Upload Vehicle Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 15),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              image: _vehicleImage != null
                                  ? DecorationImage(
                                      image: FileImage(_vehicleImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (_vehicleImage == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _isLoadingVehicleImage
                                          ? CircularProgressIndicator(color: Colors.indigo)
                                          : Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.directions_car, size: 30, color: Colors.indigo),
                                            ),
                                      SizedBox(height: 8),
                                      Text(
                                        _isLoadingVehicleImage ? "Loading..." : "Add Photo",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        if (_imageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _imageError!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 30),
                        Text(
                          'Vehicle Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 15),
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
                            controller: _brandController,
                            decoration: InputDecoration(
                              hintText: 'Vehicle brand',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.branding_watermark, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Enter vehicle brand' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            controller: _modelController,
                            decoration: InputDecoration(
                              hintText: 'Vehicle model',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.model_training, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Enter vehicle model' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            controller: _colorController,
                            decoration: InputDecoration(
                              hintText: 'Vehicle color',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.color_lens, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Enter vehicle color' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            controller: _plateController,
                            decoration: InputDecoration(
                              hintText: 'Plate number',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.confirmation_number, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Enter plate number' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            controller: _yearController,
                            decoration: InputDecoration(
                              hintText: 'Vehicle production year',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.date_range, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'Enter production year' : null,
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