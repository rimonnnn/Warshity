import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:warshity/core/constants/app_radius.dart';
import 'package:warshity/core/extensions/context_extension.dart';

class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({
    super.key,
    required this.imageBytes,
    required this.onPick,
    this.height,
    this.enabled = true,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final double? height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPick : null,
      child: Container(
        width: double.infinity,
        height: height ?? 150,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageBytes != null
            ? Image.memory(
                imageBytes!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: context.colors.primary,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Upload Product Image'.tr(),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text('PNG, JPG'.tr(), textAlign: TextAlign.center),
                ],
              ),
      ),
    );
  }
}
