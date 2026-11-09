import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:itr_proj/firebase_options.dart';
import 'package:itr_proj/splashscreen.dart';
import 'package:itr_proj/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cricketscore',
      theme: CricketTheme.themeData,
      home: const Spshsc(),
      debugShowCheckedModeBanner: false,
    );
  }
}
