import 'package:flutter/material.dart';

import '../models/local_image.dart';
import '../services/image_picker_service.dart';

class ImageUploadField extends StatefulWidget {
  final LocalImage? value;
  final String label;
  final ValueChanged<LocalImage?> onChanged;
  final Future<LocalImage?> Function()? pickImage;
  const ImageUploadField({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.pickImage,
  });
  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  bool _busy = false;
  String? _error;
  Future<void> _pick() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final image = await (widget.pickImage ?? ImagePickerService.pickImage)();
      if (!mounted) return;
      if (image != null) widget.onChanged(image);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is ImageSelectionException
            ? error.message
            : 'Tidak dapat membuka gambar. Silakan coba lagi.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (widget.value != null) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            widget.value!.bytes,
            height: 160,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (_, error, stack) => const SizedBox(
              height: 80,
              child: Center(child: Text('Pratinjau tidak tersedia.')),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(widget.value!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(widget.value == null ? 'Pilih Gambar' : 'Ganti Gambar'),
          ),
          if (widget.value != null)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      setState(() => _error = null);
                      widget.onChanged(null);
                    },
              child: const Text('Hapus Gambar'),
            ),
        ],
      ),
      const Text('PNG/JPEG, maksimal 5 MB.'),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );
}
