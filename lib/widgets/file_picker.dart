// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
// Only import dart:io if not on web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io' if (dart.library.html) 'dart:io' as io;

class FilePickerWidget extends StatefulWidget {
  final String secretKey;

  const FilePickerWidget({super.key, required this.secretKey});

  @override
  _FilePickerWidgetState createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  String? _selectedFilePath;
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  Uint8List? _pendingDownloadBytes;
  String? _pendingDownloadFileName;

  Future<void> _pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'docx', 'txt'],
      );
      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _selectedFileName = result.files.single.name;
            _selectedFileBytes = result.files.single.bytes;
            _selectedFilePath = null;
          });
        } else if (result.files.single.path != null) {
          setState(() {
            _selectedFilePath = result.files.single.path;
            _selectedFileName = result.files.single.name;
            _selectedFileBytes = null;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected file: ${_selectedFileName ?? ''}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Failed to pick file')),
      );
    }
  }

  Future<void> _encryptFile() async {
    if ((!kIsWeb && _selectedFilePath == null) ||
        (kIsWeb && _selectedFileBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to encrypt')),
      );
      return;
    }
    try {
      final key = encrypt.Key.fromBase64(widget.secretKey);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final iv = encrypt.IV.fromSecureRandom(16);
      List<int> fileContent;
      if (kIsWeb) {
        fileContent = _selectedFileBytes!;
      } else {
        fileContent = await io.File(_selectedFilePath!).readAsBytes();
      }
      final encrypted = encrypter.encryptBytes(fileContent, iv: iv);

      if (kIsWeb) {
        final outputBytes = Uint8List.fromList([
          ...iv.bytes,
          ...encrypted.bytes,
        ]);
        _pendingDownloadBytes = outputBytes;
        _pendingDownloadFileName = "${_selectedFileName ?? 'file'}.enc";
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Encryption Complete'),
            content: const Text(
              'Click the button below to download your encrypted file.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final blob = html.Blob([_pendingDownloadBytes!]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.AnchorElement(href: url)
                    ..setAttribute("download", _pendingDownloadFileName!)
                    ..click();
                  html.Url.revokeObjectUrl(url);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Encrypted file downloaded!')),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final encryptedFilePath = '${directory.path}/$_selectedFileName.enc';
        await io.File(
          encryptedFilePath,
        ).writeAsBytes([...iv.bytes, ...encrypted.bytes]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Encrypted file saved as $_selectedFileName.enc'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encryption Error: Failed to encrypt file'),
        ),
      );
    }
  }

  Future<void> _decryptFile() async {
    if ((!kIsWeb && _selectedFilePath == null) ||
        (kIsWeb && _selectedFileBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to decrypt')),
      );
      return;
    }
    try {
      Uint8List encryptedBytes;
      String outputFileName;
      if (kIsWeb) {
        encryptedBytes = _selectedFileBytes!;
        outputFileName =
            '${(_selectedFileName ?? 'file').replaceAll('.enc', '')}.dec';
      } else {
        final file = io.File(_selectedFilePath!);
        encryptedBytes = await file.readAsBytes();
        outputFileName =
            '${(_selectedFileName ?? 'file').replaceAll('.enc', '')}.dec';
      }

      if (encryptedBytes.length < 17) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid encrypted file format')),
        );
        return;
      }
      final ivBytes = encryptedBytes.sublist(0, 16);
      final cipherBytes = encryptedBytes.sublist(16);

      final key = encrypt.Key.fromBase64(widget.secretKey);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final iv = encrypt.IV(ivBytes);

      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(cipherBytes),
        iv: iv,
      );

      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Decryption Complete'),
            content: const Text(
              'Click the button below to download your decrypted file.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final blob = html.Blob([decryptedBytes]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor = html.AnchorElement(href: url)
                    ..setAttribute("download", outputFileName)
                    ..click();
                  html.Url.revokeObjectUrl(url);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Decrypted file downloaded!')),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final decryptedFilePath = '${directory.path}/$outputFileName';
        await io.File(decryptedFilePath).writeAsBytes(decryptedBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Decrypted file saved as $outputFileName')),
        );
      }
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
          'File Encryption',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _pickFile(), // For encryption: allow pdf, docx, txt
          child: const Text('Select File'),
        ),
        ElevatedButton(
          onPressed: () => _pickFile(
            allowedExtensions: ['enc'],
          ), // For decryption: only .enc
          child: const Text('Select Encrypted File'),
        ),
        if (_selectedFileName != null) ...[
          const SizedBox(height: 10),
          Text(
            'Selected: $_selectedFileName',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _encryptFile,
              child: const Text('Encrypt File'),
            ),
            ElevatedButton(
              onPressed: _decryptFile,
              child: const Text('Decrypt File'),
            ),
          ],
        ),
      ],
    );
  }
}
