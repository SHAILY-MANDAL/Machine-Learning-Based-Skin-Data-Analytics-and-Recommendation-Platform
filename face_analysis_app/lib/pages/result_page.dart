import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final File image; // Receiving the image from the previous screen

  AnalysisResultScreen({required this.result, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analysis Result")),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.purple.shade500, Colors.purple.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display uploaded image
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(image, height: 150, width: 150, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Face Analysis Report",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: result.keys.map((key) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: LinearProgressIndicator(
                          value: (result[key] is num) ? (result[key] / 100) : 0.0,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.blueAccent,
                        ),
                        trailing: Text("${result[key]}%", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _shareResults();
                },
                icon: Icon(Icons.share),
                label: Text("Share Results"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareResults() {
    String formattedResults = result.entries.map((e) => "${e.key}: ${e.value}%").join("\n");
    Share.share("Here are my face analysis results:\n\n$formattedResults");
  }
}
