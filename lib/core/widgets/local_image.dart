import 'package:flutter/widgets.dart';

import 'local_image_io.dart'
    if (dart.library.html) 'local_image_web.dart'
    as impl;

/// Menampilkan gambar dari path lokal perangkat (Android/desktop) atau
/// blob/data URL saat berjalan di web.
///
/// Implementasi dipilih saat compile-time melalui conditional import,
/// sehingga aplikasi tetap bisa di-build untuk Android maupun web tanpa
/// memakai `dart:io` di kode web.
Widget localImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  AlignmentGeometry alignment = Alignment.center,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return impl.localImage(
    path,
    fit: fit,
    width: width,
    height: height,
    alignment: alignment,
    errorBuilder: errorBuilder,
  );
}
