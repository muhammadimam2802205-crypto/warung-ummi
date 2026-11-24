import 'package:flutter/widgets.dart';

/// Pada web, gambar pilihan galeri tersedia sebagai blob URL (atau data URL
/// bila disimpan sebagai base64), sehingga dapat dimuat lewat `Image.network`.
Widget localImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  AlignmentGeometry alignment = Alignment.center,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.network(
    path,
    fit: fit,
    width: width,
    height: height,
    alignment: alignment,
    errorBuilder: errorBuilder,
  );
}
