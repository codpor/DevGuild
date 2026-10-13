import 'package:flutter/material.dart';

import '../models/local_image.dart';

class LocalImageView extends StatelessWidget {
  final LocalImage? image;
  final double height;
  final BoxFit fit;
  const LocalImageView({
    super.key,
    required this.image,
    this.height = 160,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: const Center(child: Icon(Icons.code, size: 40)),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(
        image!.bytes,
        height: height,
        width: double.infinity,
        fit: fit,
        errorBuilder: (_, error, stack) => SizedBox(
          height: height,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }
}
