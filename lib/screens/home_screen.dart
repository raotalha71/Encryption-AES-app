// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:io' as io;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AES Encryption App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the AES Encryption App!',
              style: TextStyle(
                fontSize: isSmall ? 16 : 22, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'Encrypt and decrypt text or files securely using AES.',
              style: TextStyle(
                fontSize: isSmall ? 12 : 16, // Responsive font size
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton(
              onPressed: () => Get.toNamed('/text-encryption'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.02,
                ),
                textStyle: TextStyle(fontSize: isSmall ? 14 : 16),
              ),
              child: const Text('Text Encryption'),
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: () => Get.toNamed('/file-encryption'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.02,
                ),
                textStyle: TextStyle(fontSize: isSmall ? 14 : 16),
              ),
              child: const Text('File Encryption'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadDecryptedFile(
    Uint8List decryptedBytes,
    String outputFileName,
  ) async {
    if (kIsWeb) {
      // Download the decrypted file
      final blob = html.Blob([decryptedBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", outputFileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Save the decrypted file to disk
      final directory = await getApplicationDocumentsDirectory();
      final decryptedFilePath = '${directory.path}/$outputFileName';
      await io.File(decryptedFilePath).writeAsBytes(decryptedBytes);
    }
  }
}
