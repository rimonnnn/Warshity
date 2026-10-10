// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:warshity/core/extensions/context_extension.dart';

// class FinallyPrice extends StatelessWidget {
//   const FinallyPrice({super.key, required this.total});

//   final double total;

//   @override
//   Widget build(BuildContext context) {
//     final scheme = context.colors;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       width: double.infinity,
//       decoration: BoxDecoration(
//         // primaryContainer بدل outlineVariant: الإجمالي النهائي أهم رقم في الفاتورة،
//         // فلازم يبان مميز مش كأنه خط فاصل
//         color: scheme.primaryContainer,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               "net_invoice".tr(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: context.text.bodyLarge?.copyWith(
//                 color: scheme.onPrimaryContainer,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             total.toStringAsFixed(2),
//             style: context.text.titleMedium?.copyWith(
//               color: scheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
