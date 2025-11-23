class DropFileInfo {
  final String uri;

  const DropFileInfo({required this.uri});

  /// Convert to map for sending over MethodChannel
  Map<String, dynamic> toMap() {
    return {'uri': uri};
  }

  /// Create from a map
  factory DropFileInfo.fromMap(Map<dynamic, dynamic> map) {
    return DropFileInfo(uri: map['uri'] as String);
  }
}
