import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_app/adhar_form.dart';

final uid = FirebaseAuth.instance.currentUser?.uid;

class DriverLicenseForm extends StatefulWidget {
  @override
  _DriverLicenseFormState createState() => _DriverLicenseFormState();
}

class _DriverLicenseFormState extends State<DriverLicenseForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _frontImage;
  File? _backImage;
  bool _isLoadingFrontImage = false;
  bool _isLoadingBackImage = false;

  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _validityDateController = TextEditingController();

  String? _imageError;
  bool _isFrontImagePicked = false;
  bool _isBackImagePicked = false;

  String? _frontImageUrlFromCloud;
  String? _backImageUrlFromCloud;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('driver_licenses').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _licenseNumberController.text = data['license_number'] ?? '';
        _validityDateController.text = data['validity_date'] ?? '';
        
        _frontImageUrlFromCloud = data['front_image_url'];
        _backImageUrlFromCloud = data['back_image_url'];

        // Download images in the background if they exist
        if (_frontImageUrlFromCloud != null) {
          setState(() {
            _isLoadingFrontImage = true;
          });
          await _downloadAndSetImage(_frontImageUrlFromCloud!, true);
        }
        
        if (_backImageUrlFromCloud != null) {
          setState(() {
            _isLoadingBackImage = true;
          });
          await _downloadAndSetImage(_backImageUrlFromCloud!, false);
        }
      } else {
        // fallback to shared preferences
        _licenseNumberController.text = prefs.getString('driver_license_number') ?? '';
        _validityDateController.text = prefs.getString('driver_license_validity') ?? '';
      }
    }
  }

  Future<void> _downloadAndSetImage(String imageUrl, bool isFrontImage) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      final tempDir = Directory.systemTemp;
      final fileName = isFrontImage ? 'front_license_${uid}.jpg' : 'back_license_${uid}.jpg';
      final file = await File('${tempDir.path}/$fileName').writeAsBytes(bytes);

      setState(() {
        if (isFrontImage) {
          _frontImage = file;
          _isLoadingFrontImage = false;
        } else {
          _backImage = file;
          _isLoadingBackImage = false;
        }
      });
    } catch (e) {
      print('Failed to load license image: $e');
      setState(() {
        if (isFrontImage) {
          _isLoadingFrontImage = false;
        } else {
          _isLoadingBackImage = false;
        }
      });
    }
  }

  Future<void> _saveDataToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_license_number', _licenseNumberController.text.trim());
    await prefs.setString('driver_license_validity', _validityDateController.text.trim());
  }

  Future<String?> _uploadImageToCloudinary(File imageFile, String folder) async {
    final cloudName = 'dgnjiyfdc';
    final uploadPreset = 'cab_booking_app';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder  // Add folder to organize license images
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

  Future<void> _pickFrontImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _frontImage = File(picked.path);
        _isFrontImagePicked = true;
        _imageError = null;
      });
    }
  }

  Future<void> _pickBackImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _backImage = File(picked.path);
        _isBackImagePicked = true;
        _imageError = null;
      });
    }
  }

  void _submitForm() async {
    setState(() {
      if ((_frontImage == null && _frontImageUrlFromCloud == null) || 
          (_backImage == null && _backImageUrlFromCloud == null)) {
        _imageError = 'Please upload both front and back images of the license';
      } else {
        _imageError = null;
      }
    });

    if (_formKey.currentState!.validate() &&
        (_frontImage != null || _frontImageUrlFromCloud != null) &&
        (_backImage != null || _backImageUrlFromCloud != null)) {
          
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        String? frontImageUrl = _frontImageUrlFromCloud;
        String? backImageUrl = _backImageUrlFromCloud;

        if (_isFrontImagePicked && _frontImage != null) {
          frontImageUrl = await _uploadImageToCloudinary(_frontImage!, 'driver_licenses/front');
        }
        if (_isBackImagePicked && _backImage != null) {
          backImageUrl = await _uploadImageToCloudinary(_backImage!, 'driver_licenses/back');
        }

        Navigator.pop(context);

        if (frontImageUrl != null && backImageUrl != null) {
          _frontImageUrlFromCloud = frontImageUrl;
          _backImageUrlFromCloud = backImageUrl;

          await FirebaseFirestore.instance.collection('driver_licenses').doc(uid).set({
            'user_id': uid,
            'license_number': _licenseNumberController.text.trim(),
            'validity_date': _validityDateController.text.trim(),
            'front_image_url': frontImageUrl,
            'back_image_url': backImageUrl,
            'created_at': FieldValue.serverTimestamp(),
          });

          await _saveDataToPrefs();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('License details submitted successfully!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdharForm()),
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
          'License Details',
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
                          'Upload License Images',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickFrontImage,
                                child: Container(
                                  height: 160,
                                  margin: EdgeInsets.only(right: 8),
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
                                    image: _frontImage != null
                                        ? DecorationImage(image: FileImage(_frontImage!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: _frontImage == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _isLoadingFrontImage
                                                ? CircularProgressIndicator(color: Colors.indigo)
                                                : Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.indigo.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.add_photo_alternate, size: 30, color: Colors.indigo),
                                                  ),
                                            SizedBox(height: 12),
                                            Text(
                                              _isLoadingFrontImage ? "Loading..." : "Front Side",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickBackImage,
                                child: Container(
                                  height: 160,
                                  margin: EdgeInsets.only(left: 8),
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
                                    image: _backImage != null
                                        ? DecorationImage(image: FileImage(_backImage!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: _backImage == null
                                      ? Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _isLoadingBackImage
                                                ? CircularProgressIndicator(color: Colors.indigo)
                                                : Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.indigo.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.add_photo_alternate, size: 30, color: Colors.indigo),
                                                  ),
                                            SizedBox(height: 12),
                                            Text(
                                              _isLoadingBackImage ? "Loading..." : "Back Side",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ],
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
                          'License Number',
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
                            controller: _licenseNumberController,
                            decoration: InputDecoration(
                              hintText: 'Enter license number',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.credit_card, color: Colors.indigo),
                              ),
                            ),
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'License number is required' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Validity Date',
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
                            controller: _validityDateController,
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
                            onChanged: (_) => _saveDataToPrefs(),
                            validator: (value) => value!.isEmpty ? 'Validity date is required' : null,
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