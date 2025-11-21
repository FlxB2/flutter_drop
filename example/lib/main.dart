import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_drop/flutter_drop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This is the function we pass to DropWidget
  Future<Uri?> _getDragFile() async {
    try {
      final assetPath = 'assets/flutter.png';
      final data = await rootBundle.load(assetPath);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${assetPath.split('/').last}');
      await file.writeAsBytes(data.buffer.asUint8List());

      return file.uri;
    } catch (e) {
      print("Error preparing drag file: $e");
      return null;
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
                getUri: _getDragFile,
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
