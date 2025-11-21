import 'package:flutter/material.dart';
import 'package:flutter_drop/flutter_drop.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDrop.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Row(
            children: [
              DropWidget(
                name: "heya",
                child: TextButton(
                  onPressed: () {
                    print("Button 1");
                  },
                  child: Text("Button 1"),
                ),
              ),
              TextButton(
                onPressed: () {
                  print("Button 2");
                },
                child: Text("Button 2"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
