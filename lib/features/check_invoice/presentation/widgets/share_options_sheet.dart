import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareOptionsSheet(
        onSharePdf: onSharePdf,
        onShareImage: onShareImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('share_invoice'.tr(), style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text('share_as_pdf'.tr()),
              onTap: () {
                Navigator.pop(context);
                onSharePdf();
              },
            ),

            ListTile(
              leading: const Icon(Icons.image),
              title: Text('share_as_image'.tr()),
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