import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DropWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const DropWidget({super.key, required this.name, required this.child});

  @override
  DropWidgetState createState() => DropWidgetState();
}

class DropWidgetState extends State<DropWidget> {
  final key = GlobalKey();
  static const platform = MethodChannel('flutter_drop');

  Offset? _pointerDownPosition;
  final double _dragThreshold = 5.0; // pixels

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) async {
    if (_pointerDownPosition == null) return;

    final distance = (event.position - _pointerDownPosition!).distance;
    if (distance >= _dragThreshold) {
      try {
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        final size = box?.size ?? Size.zero;

        print("Starting native drag");
        await platform.invokeMethod('startNativeDrag', {
          'x': _pointerDownPosition!.dx,
          'y': _pointerDownPosition!.dy,
          'width': size.width,
          'height': size.height,
          //'fileName': widget.fileName,
        });
      } on PlatformException catch (e) {
        print("Error starting native drag: $e");
      }
      _pointerDownPosition = null; // prevent retriggering
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointerDownPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Container(key: key, child: widget.child),
    );
  }
}
