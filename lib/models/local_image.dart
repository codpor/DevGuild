import 'dart:typed_data';

/// Data gambar lokal; tidak bergantung pada path yang tidak tersedia di web.
class LocalImage {
  final String name;
  final Uint8List bytes;
  LocalImage({required this.name, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes);
}
