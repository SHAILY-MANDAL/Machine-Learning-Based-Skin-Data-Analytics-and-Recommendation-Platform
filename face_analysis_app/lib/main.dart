import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(FaceAnalysisApp());
}

class FaceAnalysisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

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
            // Lottie Animation for a cool effect
            Lottie.asset(
              'assets/face_scan.json', // Ensure this file is inside the assets folder
              height: 200,
            ),
            SizedBox(height: 20),

            // Animated Text
            Text(
              "Face Analysis",
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),

            SizedBox(height: 20),

            // Progress Indicator
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
