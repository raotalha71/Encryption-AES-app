import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../widgets/file_picker.dart';
// Make sure that the file_picker.dart file exists in the widgets directory
// and that it exports a FilePicker widget.

// If FilePicker is not defined, create it in lib/widgets/file_picker.dart:

class FileEncryptionScreen extends StatefulWidget {
  const FileEncryptionScreen({super.key});

  @override
  _FileEncryptionScreenState createState() => _FileEncryptionScreenState();
}

class _FileEncryptionScreenState extends State<FileEncryptionScreen> {
  final storage = const FlutterSecureStorage();
  String secretKey = '';
  String customKey = '';
  bool isUsingCustomKey = false;

  @override
  void initState() {
    super.initState();
    _loadOrGenerateKey();
  }

  Future<void> _loadOrGenerateKey() async {
    try {
      String? key = await storage.read(key: 'encryption_key');
      if (key == null) {
        final generatedKey = encrypt.Key.fromSecureRandom(32);
        key = generatedKey.base64;
        await storage.write(key: 'encryption_key', value: key);
      }
      setState(() {
        secretKey = key!;
      });
    } catch (e) {
      final generatedKey = encrypt.Key.fromSecureRandom(32);
      final fallbackKey = generatedKey.base64;
      setState(() {
        secretKey = fallbackKey;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using temporary encryption key for this session'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Encryption'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Encryption Key:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isUsingCustomKey = !isUsingCustomKey;
                          customKey = '';
                        });
                      },
                      child: Text(
                        isUsingCustomKey
                            ? 'Using Custom Key'
                            : 'Using Auto-Generated Key',
                      ),
                    ),
                    if (isUsingCustomKey) ...[
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter custom encryption key',
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            customKey = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilePickerWidget(
              secretKey: isUsingCustomKey && customKey.isNotEmpty
                  ? customKey
                  : secretKey,
            ),
          ],
        ),
      ),
    );
  }
}
