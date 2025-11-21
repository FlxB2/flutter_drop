import 'package:flutter/widgets.dart';
import 'package:flutter_drop/drop_registry.dart';

class DropWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const DropWidget({super.key, required this.name, required this.child});

  @override
  DropWidgetState createState() => DropWidgetState();
}

class DropWidgetState extends State<DropWidget> {
  final key = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _register());
  }

  void _register() {
    DropRegistry.register(widget.name, key);
  }

  @override
  void dispose() {
    DropRegistry.unregister(widget.name);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: key, child: widget.child);
  }
}
