Flutter plugin which allows dragging files outside your app.

Only basic support for images and macOS right now. 

# Setup
Add the depedency to your `pubspec.yaml`

```yaml
dependencies:
  flutter_drop: 0.0.1
```

```dart
 DropWidget(
  getUri: _getDragFile,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset('assets/flutter.png', width: 80, height: 80),
      const SizedBox(height: 8),
      const Text('Drag Me!'),
    ],
  )
 )
```

where `_getDragFile` returns `Future<Uri?>` to your file.