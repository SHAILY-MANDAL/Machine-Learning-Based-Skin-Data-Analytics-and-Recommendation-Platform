import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'upload_page.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation for Smooth UI
            Lottie.asset(
              'assets/face_scan.json', // Add a Lottie JSON file in assets
              height: 180,
            ),
            SizedBox(height: 20),

            // Animated Text Kit for Cool Text Effect
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "Welcome to Face Analysis",
                  textStyle: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  speed: Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
            ),
            SizedBox(height: 30),

            // Animated Button with Ripple Effect
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageUploadScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Start Analysis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios, color: Colors.blue.shade900),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
