import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_drop/drag_file_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_drop/flutter_drop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DropFileInfo? _fileInfo;

  @override
  void initState() {
    super.initState();
    _prepareDragFile();
  }

  Future<void> _prepareDragFile() async {
    try {
      final assetPath = 'assets/flutter.png';
      final data = await rootBundle.load(assetPath);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${assetPath.split('/').last}');
      await file.writeAsBytes(data.buffer.asUint8List());

      setState(() {
        _fileInfo = DropFileInfo(uri: null, bytes: data.buffer.asUint8List(), filename: 'flutter.png');
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error preparing drag file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Drop Example')),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropWidget(
                fileInfo: _fileInfo,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/flutter.png', width: 80, height: 80),
                    const SizedBox(height: 8),
                    const Text('Drag Me!'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
