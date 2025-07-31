import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget buildToast(
  BuildContext context,
  ToastOverlay overlay, {
  required String title,
  required String subtitle,
  Widget? trailing,
}) {
  return SurfaceCard(
    child: Basic(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      // PrimaryButton(
      //     size: ButtonSize.small,
      //     onPressed: () {
      //       overlay.close();
      //     },
      //     child: const Text('Undo')),
      trailingAlignment: Alignment.centerRight,
    ),
  );
}
