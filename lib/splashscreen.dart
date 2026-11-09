import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itr_proj/main_navigation_screen.dart';
import 'package:itr_proj/theme.dart';

class Spshsc extends StatefulWidget {
  const Spshsc({super.key});

  @override
  State<Spshsc> createState() => _SpshscState();
}

class _SpshscState extends State<Spshsc> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    });
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: CricketTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: CricketTheme.border, width: 1.5),
                boxShadow: const [CricketTheme.cardShadow],
              ),
              child: const Icon(
                Icons.sports_cricket,
                size: 64,
                color: CricketTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "CricScore",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: CricketTheme.primaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Live Cricket Scoring & Series",
              style: TextStyle(
                fontSize: 13.5,
                color: CricketTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 36),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: CricketTheme.primaryGreen,
                strokeWidth: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
