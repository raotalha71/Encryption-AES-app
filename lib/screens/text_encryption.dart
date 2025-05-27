import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../widgets/encryption_form.dart';

class TextEncryptionScreen extends StatefulWidget {
  const TextEncryptionScreen({super.key});

  @override
  _TextEncryptionScreenState createState() => _TextEncryptionScreenState();
}

class _TextEncryptionScreenState extends State<TextEncryptionScreen> {
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
        key = encrypt.Key.fromSecureRandom(32).base64;
        await storage.write(key: 'encryption_key', value: key);
      }
      setState(() {
        secretKey = key!;
      });
    } catch (e) {
      final fallbackKey = encrypt.Key.fromSecureRandom(32).base64;
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
      appBar: AppBar(title: const Text('Text Encryption'), centerTitle: true),
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
            EncryptionForm(
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
