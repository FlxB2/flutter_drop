import 'dart:typed_data';

class DropFileInfo {
  final String? uri;
  final Uint8List? bytes;
  final String? filename;

  const DropFileInfo({this.uri, this.bytes, this.filename})
      : assert(uri != null || (bytes != null && filename != null));

  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'bytes': bytes,
      'filename': filename,
    };
  }
}
