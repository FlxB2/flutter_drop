https://github.com/user-attachments/assets/cd391c85-a825-4dd4-b046-08fa88568e30


Flutter plugin which allows dropping files outside your app.

Only basic support for macOS right now. 

# Setup
Add the depedency to your `pubspec.yaml`

```yaml
dependencies:
  flutter_drop: 0.0.1
```

```dart
  DropWidget(
    getInfo: _getInfo,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/flutter.png', width: 80, height: 80),
        const SizedBox(height: 8),
        const Text('Drag Me!'),
      ],
    ),
  )
```

where `_getInfo` returns `Future<Uri?>` to your file.
