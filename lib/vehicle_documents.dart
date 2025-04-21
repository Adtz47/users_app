import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_app/registration_menu.dart';

final uid = FirebaseAuth.instance.currentUser?.uid;

class VehicleDocumentsPage extends StatefulWidget {
  @override
  _VehicleDocumentsPageState createState() => _VehicleDocumentsPageState();
}

class _VehicleDocumentsPageState extends State<VehicleDocumentsPage> {
  final ImagePicker _picker = ImagePicker();

  File? _permitPartA;
  File? _permitPartB;
  File? _registrationFront;
  File? _registrationBack;

  bool _isPermitAPicked = false;
  bool _isPermitBPicked = false;
  bool _isRegFrontPicked = false;
  bool _isRegBackPicked = false;

  bool _isLoadingPermitA = false;
  bool _isLoadingPermitB = false;
  bool _isLoadingRegFront = false;
  bool _isLoadingRegBack = false;

  String? _permitPartAUrlFromCloud;
  String? _permitPartBUrlFromCloud;
  String? _registrationFrontUrlFromCloud;
  String? _registrationBackUrlFromCloud;

  String? _errorPermitA;
  String? _errorPermitB;
  String? _errorRegFront;
  String? _errorRegBack;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('vehicle_documents').doc(uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          
          _permitPartAUrlFromCloud = data['permit_part_a_url'];
          _permitPartBUrlFromCloud = data['permit_part_b_url']; 
          _registrationFrontUrlFromCloud = data['registration_front_url'];
          _registrationBackUrlFromCloud = data['registration_back_url'];

          // Download images in the background if they exist
          if (_permitPartAUrlFromCloud != null) {
            setState(() {
              _isLoadingPermitA = true;
            });
            await _downloadAndSetImage(_permitPartAUrlFromCloud!, 'permit_a');
          }
          
          if (_permitPartBUrlFromCloud != null) {
            setState(() {
              _isLoadingPermitB = true;
            });
            await _downloadAndSetImage(_permitPartBUrlFromCloud!, 'permit_b');
          }
          
          if (_registrationFrontUrlFromCloud != null) {
            setState(() {
              _isLoadingRegFront = true;
            });
            await _downloadAndSetImage(_registrationFrontUrlFromCloud!, 'reg_front');
          }
          
          if (_registrationBackUrlFromCloud != null) {
            setState(() {
              _isLoadingRegBack = true;
            });
            await _downloadAndSetImage(_registrationBackUrlFromCloud!, 'reg_back');
          }
        }
      } catch (e) {
        print('Error loading documents data: $e');
      }
    }
  }

  Future<void> _downloadAndSetImage(String imageUrl, String imageType) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      final tempDir = Directory.systemTemp;
      final fileName = '${imageType}_${uid}.jpg';
      final file = await File('${tempDir.path}/$fileName').writeAsBytes(bytes);

      setState(() {
        switch (imageType) {
          case 'permit_a':
            _permitPartA = file;
            _isLoadingPermitA = false;
            break;
          case 'permit_b':
            _permitPartB = file;
            _isLoadingPermitB = false;
            break;
          case 'reg_front':
            _registrationFront = file;
            _isLoadingRegFront = false;
            break;
          case 'reg_back':
            _registrationBack = file;
            _isLoadingRegBack = false;
            break;
        }
      });
    } catch (e) {
      print('Failed to load image: $e');
      setState(() {
        switch (imageType) {
          case 'permit_a':
            _isLoadingPermitA = false;
            break;
          case 'permit_b':
            _isLoadingPermitB = false;
            break;
          case 'reg_front':
            _isLoadingRegFront = false;
            break;
          case 'reg_back':
            _isLoadingRegBack = false;
            break;
        }
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile, String folder) async {
    final cloudName = 'dgnjiyfdc';
    final uploadPreset = 'cab_booking_app';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        print('Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<void> _pickImage(String imageType) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        switch (imageType) {
          case 'permit_a':
            _permitPartA = File(picked.path);
            _isPermitAPicked = true;
            _errorPermitA = null;
            break;
          case 'permit_b':
            _permitPartB = File(picked.path);
            _isPermitBPicked = true;
            _errorPermitB = null;
            break;
          case 'reg_front':
            _registrationFront = File(picked.path);
            _isRegFrontPicked = true;
            _errorRegFront = null;
            break;
          case 'reg_back':
            _registrationBack = File(picked.path);
            _isRegBackPicked = true;
            _errorRegBack = null;
            break;
        }
      });
    }
  }

  void _submitDocuments() async {
    setState(() {
      _errorPermitA = (_permitPartA == null && _permitPartAUrlFromCloud == null) ? 'Required' : null;
      _errorPermitB = (_permitPartB == null && _permitPartBUrlFromCloud == null) ? 'Required' : null;
      _errorRegFront = (_registrationFront == null && _registrationFrontUrlFromCloud == null) ? 'Required' : null;
      _errorRegBack = (_registrationBack == null && _registrationBackUrlFromCloud == null) ? 'Required' : null;
    });

    if ((_permitPartA != null || _permitPartAUrlFromCloud != null) &&
        (_permitPartB != null || _permitPartBUrlFromCloud != null) &&
        (_registrationFront != null || _registrationFrontUrlFromCloud != null) &&
        (_registrationBack != null || _registrationBackUrlFromCloud != null)) {
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        String? permitAUrl = _permitPartAUrlFromCloud;
        String? permitBUrl = _permitPartBUrlFromCloud;
        String? regFrontUrl = _registrationFrontUrlFromCloud;
        String? regBackUrl = _registrationBackUrlFromCloud;

        // Upload new images to Cloudinary if picked
        if (_isPermitAPicked && _permitPartA != null) {
          permitAUrl = await _uploadImageToCloudinary(_permitPartA!, 'vehicle_documents/permit_a');
        }
        if (_isPermitBPicked && _permitPartB != null) {
          permitBUrl = await _uploadImageToCloudinary(_permitPartB!, 'vehicle_documents/permit_b');
        }
        if (_isRegFrontPicked && _registrationFront != null) {
          regFrontUrl = await _uploadImageToCloudinary(_registrationFront!, 'vehicle_documents/reg_front');
        }
        if (_isRegBackPicked && _registrationBack != null) {
          regBackUrl = await _uploadImageToCloudinary(_registrationBack!, 'vehicle_documents/reg_back');
        }

        // Close loading dialog
        Navigator.pop(context);

        // Check if all uploads were successful
        if (permitAUrl != null && permitBUrl != null && regFrontUrl != null && regBackUrl != null) {
          // Update stored URLs
          _permitPartAUrlFromCloud = permitAUrl;
          _permitPartBUrlFromCloud = permitBUrl;
          _registrationFrontUrlFromCloud = regFrontUrl;
          _registrationBackUrlFromCloud = regBackUrl;

          // Save to Firestore
          await FirebaseFirestore.instance.collection('vehicle_documents').doc(uid).set({
            'user_id': uid,
            'permit_part_a_url': permitAUrl,
            'permit_part_b_url': permitBUrl,
            'registration_front_url': regFrontUrl,
            'registration_back_url': regBackUrl,
            'updated_at': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('All documents uploaded successfully!')),
          );

          // Navigate to next screen if needed
           Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationMenu()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('One or more image uploads failed. Please try again.')),
          );
        }
      } catch (e) {
        // Close loading dialog if there's an error
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildUploadBox({
    required String label,
    File? file,
    String? cloudImageUrl,
    required String imageType,
    String? error,
    IconData iconData = Icons.file_copy,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(imageType),
          child: Container(
            width: 150,
            height: 150,
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
              image: file != null
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : null,
            ),
            child: (file == null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoading
                          ? CircularProgressIndicator(color: Colors.indigo)
                          : Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, size: 30, color: Colors.indigo),
                            ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          isLoading ? "Loading..." : label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
      ],
    );
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
          'Vehicle Documents',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Required Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildUploadBox(
                            label: 'Vehicle Permit - Part A',
                            file: _permitPartA,
                            cloudImageUrl: _permitPartAUrlFromCloud,
                            imageType: 'permit_a',
                            error: _errorPermitA,
                            iconData: Icons.description,
                            isLoading: _isLoadingPermitA,
                          ),
                          _buildUploadBox(
                            label: 'Vehicle Permit - Part B',
                            file: _permitPartB,
                            cloudImageUrl: _permitPartBUrlFromCloud,
                            imageType: 'permit_b',
                            error: _errorPermitB,
                            iconData: Icons.description_outlined,
                            isLoading: _isLoadingPermitB,
                          ),
                          _buildUploadBox(
                            label: 'Vehicle Registration - Front',
                            file: _registrationFront,
                            cloudImageUrl: _registrationFrontUrlFromCloud,
                            imageType: 'reg_front',
                            error: _errorRegFront,
                            iconData: Icons.assignment,
                            isLoading: _isLoadingRegFront,
                          ),
                          _buildUploadBox(
                            label: 'Vehicle Registration - Back',
                            file: _registrationBack,
                            cloudImageUrl: _registrationBackUrlFromCloud,
                            imageType: 'reg_back',
                            error: _errorRegBack,
                            iconData: Icons.assignment_outlined,
                            isLoading: _isLoadingRegBack,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitDocuments,
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
          ],
        ),
      ),
    );
  }
}