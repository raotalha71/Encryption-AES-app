import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/text_encryption.dart';
import 'screens/file_encryption.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AES Encryption App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(
          name: '/text-encryption',
          page: () => const TextEncryptionScreen(),
        ),
        GetPage(
          name: '/file-encryption',
          page: () => const FileEncryptionScreen(),
        ),
      ],
    );
  }
}

class HackerBackground extends StatelessWidget {
  final Widget child;

  const HackerBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

// In your main screen (e.g., HomeScreen, FileEncryptionScreen, etc.)
@override
Widget build(BuildContext context) {
  return HackerBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      // ...existing Scaffold content...
    ),
  );
}
