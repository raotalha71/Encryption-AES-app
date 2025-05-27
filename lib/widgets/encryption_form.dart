import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionForm extends StatefulWidget {
  final String secretKey;

  const EncryptionForm({super.key, required this.secretKey});

  @override
  _EncryptionFormState createState() => _EncryptionFormState();
}

class _EncryptionFormState extends State<EncryptionForm> {
  final TextEditingController _plainTextController = TextEditingController();
  String _encryptedText = '';
  String _decryptedText = '';

  void _encryptText() {
    if (_plainTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to encrypt')),
      );
      return;
    }
    try {
      final key = encrypt.Key.fromBase64(widget.secretKey);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = encrypter.encrypt(_plainTextController.text, iv: iv);
      setState(() {
        _encryptedText = '${encrypted.base64}:${iv.base64}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encryption Error: Failed to encrypt text'),
        ),
      );
    }
  }

  void _decryptText() {
    if (_encryptedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No encrypted text to decrypt')),
      );
      return;
    }
    try {
      final parts = _encryptedText.split(':');
      if (parts.length != 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid encrypted text format')),
        );
        return;
      }
      final key = encrypt.Key.fromBase64(widget.secretKey);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypt.Encrypted.fromBase64(parts[0]);
      final iv = encrypt.IV.fromBase64(parts[1]);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      setState(() {
        _decryptedText = decrypted;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Decryption Error: Invalid key or corrupted data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Text Encryption',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _plainTextController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter text to encrypt',
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _encryptText,
              child: const Text('Encrypt Text'),
            ),
            ElevatedButton(
              onPressed: _decryptText,
              child: const Text('Decrypt Text'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Encrypted Text:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.shade100,
          ),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          child: SelectableText(_encryptedText),
        ),
        const SizedBox(height: 20),
        const Text(
          'Decrypted Text:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey.shade100,
          ),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 60),
          child: SelectableText(_decryptedText),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _plainTextController.dispose();
    super.dispose();
  }
}
