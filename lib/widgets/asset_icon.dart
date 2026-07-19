import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetIcon extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  /// Agar SVG white ho aur background white ho, is se black tint de sakte ho.
  final Color? color;

  const AssetIcon(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = path.toLowerCase();
    if (p.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (_) => const SizedBox.shrink(),
        // Error par ek halka placeholder dikha dein (aur console me error aa jayega)
        // taake pata chal jaye kaunsa asset problem de raha hai.
        clipBehavior: Clip.hardEdge,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
