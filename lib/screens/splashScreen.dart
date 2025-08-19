import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:innerspace_coworking/mainScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AnimatedSplashScreen(
          splash: Container(
            width: 100,
            child: Image.asset(
              'assets/coworkingLogo.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          nextScreen:
              //  BranchMapScreen(),
              BottomNavScreen(),
          // HomeScreen(),
          splashIconSize: double.infinity,
          splashTransition: SplashTransition.scaleTransition,
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          duration: 1500,
        ),
      ),
    );
  }
}
