import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

/// Bottom sheet offering the two ways to share an invoice: as a PDF
/// or as an image. Call [show] to display it.
class ShareOptionsSheet extends StatelessWidget {
  const ShareOptionsSheet({
    super.key,
    required this.onSharePdf,
    required this.onShareImage,
  });

  final VoidCallback onSharePdf;
  final VoidCallback onShareImage;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSharePdf,
    required VoidCallback onShareImage,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // نفس لون باقي الكروت والـ dialogs، بدل الافتراضي الباهت على الـ navy
      backgroundColor: context.colors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ShareOptionsSheet(onSharePdf: onSharePdf, onShareImage: onShareImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'share_invoice'.tr(),
              style: context.text.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _ShareOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'share_as_pdf'.tr(),
              onTap: () {
                Navigator.pop(context);
                onSharePdf();
              },
            ),

            const SizedBox(height: 8),

            _ShareOption(
              icon: Icons.image_outlined,
              title: 'share_as_image'.tr(),
              onTap: () {
                Navigator.pop(context);
                onShareImage();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;

    return ListTile(
      onTap: onTap,
      // كل خيار في صف بحد ومستدير، بدل ListTile مسطح بأيقونة افتراضية
      tileColor: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: scheme.primary),
      ),
      title: Text(
        title,
        style: context.text.bodyLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        // بتتقلب لوحدها في RTL
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}
