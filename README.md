A flutter macOS plugin which allows dragging files outside your app

roughly based on:
- https://github.com/skalio/native-drag-and-drop
- https://github.com/superlistapp/super_native_extensions

But kept simple (regarding super_native_extensions) and with better drop support (regarding native-drag-and-drop)

# Setup

Ensure you initialize the plugin e.g.
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDrop.initialize();
  runApp(const MyApp());
}
```

Add the depedency to your `pubspec.yaml`

```yaml
dependencies:
  flutter_drop: 0.0.1
```