A flutter macOS plugin which allows dragging files outside your app

roughly based on:
- https://github.com/skalio/native-drag-and-drop
- https://github.com/superlistapp/super_native_extensions

But kept simple (regarding super_native_extensions) and with better drop support (regarding native-drag-and-drop)

Heavily WIP

# Setup
Add the depedency to your `pubspec.yaml`

```yaml
dependencies:
  flutter_drop: 0.0.1
```

```dart
 DropWidget(
  name: "heya",
  child: TextButton(
    onPressed: () {
      print("Button 1");
    },
    child: Text("Button 1"),
  ),
),
```