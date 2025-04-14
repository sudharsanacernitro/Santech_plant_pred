import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'global_settings.dart';
import 'chat.dart';
import 'plant_data.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // Dropdown values
  String _selectedCategory = "leaf";
  String _selectedType = "apple";

  // Map of available types for each category
  final Map<String, List<String>> _typeOptions = {
    "leaf": ["apple", "turmeric","potato"],
    "fruit": ["apple"]
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    String fileName = p.basename(_image!.path);
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(_image!.path, filename: fileName),
      "category": _selectedCategory, // Send selected category
      "type": _selectedType, // Send selected type
    });

    try {
      String? ip = GlobalSettings.instance.ip;
      Response response = await _dio.post(
        "http://${ip!}:5000/upload",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

            if (response.statusCode == 200 && response.data != null) {
        String diseaseName = response.data['diseaseName'] ?? "Unknown Disease";
        _showSuccessDialog(diseaseName);
      }  else {
         _showErrorDialog('Error submitting form!');
      }
    } catch (e) {
       _showErrorDialog('Error submitting form!');
    }
  }

// Function to show success dialog with disease name
void _showSuccessDialog(String diseaseName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Diagnosis Result"),
        content: Text("Predicted Disease: $diseaseName"),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage(disease_name:diseaseName)),//HealthFormScreen(ip:_controller1.text)),
              );
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}


// Function to show error dialog
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text('Scan'),
              actions: [
                IconButton(
                  icon: Icon(Icons.data_exploration), // Replace with any icon
                  onPressed: () {
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => ThingSpeakData()) );
                  },
                ),
              ],
      
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image != null ? Container( 
                    width: screenWidth,
                  height: .5*screenHeight,
                    child: Image.file(_image!)) : Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHYeK7N6x3-H9XG0gyd_Vncoq8vnpM_rD1iw&s'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       DropdownButton<String>(
                    value: _selectedCategory,
                    items: _typeOptions.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          // Reset _selectedType to a valid default when category changes
                          _selectedType = _typeOptions[_selectedCategory]!.first;
                        });
                      }
                    },
                  ),
              
                  SizedBox(width: 10),
              
                  // Dropdown for "Apple or Turmeric"
                  DropdownButton<String>(
                    value: _selectedType,
                    items: _typeOptions[_selectedCategory]!.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                  ),
              

                    ],
                  ),
                 
                  SizedBox(height: 20),
              
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick Image'),
                  ),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text('Upload Image'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
