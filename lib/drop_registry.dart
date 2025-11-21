import 'package:flutter/widgets.dart';

class DropRegistry {
  static final Map<String, GlobalKey> _widgets = {};

  static void register(String name, GlobalKey key) {
    _widgets[name] = key;
  }

  static void unregister(String name) {
    _widgets.remove(name);
  }

  static String? hitTest(Offset globalPoint) {
    for (final entry in _widgets.entries) {
      final key = entry.value;
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final pos = box.localToGlobal(Offset.zero);
      final rect = pos & box.size;

      if (rect.contains(globalPoint)) return entry.key;
    }
    return null;
  }
}