import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.source,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? source;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = source;
    if (path == null || path.isEmpty) return placeholder;

    if (path.startsWith('data:')) {
      final data = Uri.tryParse(path)?.data;
      if (data == null) return placeholder;
      return Image.memory(
        data.contentAsBytes(),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (kIsWeb) return placeholder;

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
