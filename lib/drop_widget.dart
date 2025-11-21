import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DropWidget extends StatefulWidget {
  final Widget child;
  final Future<Uri?> Function() getUri; // parent provides the Future<Uri>

  const DropWidget({
    super.key,
    required this.child,
    required this.getUri,
  });

  @override
  DropWidgetState createState() => DropWidgetState();
}

class DropWidgetState extends State<DropWidget> {
  final key = GlobalKey();
  static const platform = MethodChannel('flutter_drop');

  Offset? _pointerDownPosition;
  final double _dragThreshold = 5.0; // pixels
  Uri? _dragUri;

  // Exposed function to trigger fetching the URI
  Future<Uri> prepareDrag() async {
    _dragUri = await widget.getUri();
    return _dragUri!;
  }

  void _onPointerDown(PointerDownEvent event) {
    prepareDrag();
    _pointerDownPosition = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) async {
    if (_pointerDownPosition == null) return;

    final distance = (event.position - _pointerDownPosition!).distance;
    if (distance >= _dragThreshold) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      final size = box?.size ?? Size.zero;

      try {
        await platform.invokeMethod('startNativeDrag', {
          'x': _pointerDownPosition!.dx,
          'y': _pointerDownPosition!.dy,
          'width': size.width,
          'height': size.height,
          'uri': _dragUri?.toFilePath(),
        });
      } on PlatformException catch (e) {
        if (kDebugMode) print("Error starting native drag: $e");
      }

      _pointerDownPosition = null;
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
