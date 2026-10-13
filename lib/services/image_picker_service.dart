import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';

import '../models/local_image.dart';

class ImageSelectionException implements Exception {
  final String message;
  const ImageSelectionException(this.message);
  @override
  String toString() => message;
}

class ImagePickerService {
  static const maxBytes = 5 * 1024 * 1024;
  static const maxPixels = 24 * 1024 * 1024;

  static Future<LocalImage?> pickImage() async {
    const type = XTypeGroup(
      label: 'Gambar PNG atau JPEG',
      extensions: ['png', 'jpg', 'jpeg'],
      uniformTypeIdentifiers: ['public.png', 'public.jpeg'],
      mimeTypes: ['image/png', 'image/jpeg'],
    );
    final file = await openFile(acceptedTypeGroups: [type]);
    if (file == null) return null;
    if (await file.length() > maxBytes) {
      throw const ImageSelectionException('Ukuran gambar maksimal 5 MB.');
    }
    return fromBytes(await file.readAsBytes(), file.name);
  }

  static Future<LocalImage> fromBytes(Uint8List bytes, String name) async {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const ImageSelectionException(
        'Pilih gambar berukuran maksimal 5 MB.',
      );
    }
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71 &&
        bytes[4] == 13 &&
        bytes[5] == 10 &&
        bytes[6] == 26 &&
        bytes[7] == 10;
    final jpeg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    if (!png && !jpeg) {
      throw const ImageSelectionException('Format gambar harus PNG atau JPEG.');
    }
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width * descriptor.height > maxPixels) {
        throw const ImageSelectionException(
          'Resolusi gambar terlalu besar (maksimal 24 megapiksel).',
        );
      }
      final longest = descriptor.width > descriptor.height
          ? descriptor.width
          : descriptor.height;
      final scale = longest > 1600 ? 1600 / longest : 1.0;
      codec = await descriptor.instantiateCodec(
        targetWidth: (descriptor.width * scale).round().clamp(1, 1600),
        targetHeight: (descriptor.height * scale).round().clamp(1, 1600),
      );
      image = (await codec.getNextFrame()).image;
      final normalized = await image.toByteData(format: ui.ImageByteFormat.png);
      if (normalized == null || normalized.lengthInBytes > maxBytes) {
        throw const ImageSelectionException(
          'Gambar terlalu besar setelah diproses. Pilih gambar yang lebih kecil.',
        );
      }
      return LocalImage(
        name: name,
        bytes: normalized.buffer.asUint8List(
          normalized.offsetInBytes,
          normalized.lengthInBytes,
        ),
      );
    } on ImageSelectionException {
      rethrow;
    } catch (_) {
      throw const ImageSelectionException(
        'Gambar rusak atau tidak dapat dibaca.',
      );
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
