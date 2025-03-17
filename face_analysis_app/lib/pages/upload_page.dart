import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'result_page.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _loading = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:5000/analyze')); // Android Emulator
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      setState(() {
        _analysisResult = json.decode(responseData);
        _loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            result: _analysisResult!,
            image: _image!, // Passing the uploaded image
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showErrorDialog("Error analyzing image. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Face Image")),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, height: 250, width: 250, fit: BoxFit.cover),
                      ),
                    )
                  : Lottie.asset('assets/upload.json', height: 200), // Animated Upload Icon
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: getImage,
                icon: Icon(Icons.image),
                label: Text("Pick Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: analyzeImage,
                icon: Icon(Icons.analytics),
                label: Text("Analyze Face"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              SizedBox(height: 20),
              if (_loading) CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
