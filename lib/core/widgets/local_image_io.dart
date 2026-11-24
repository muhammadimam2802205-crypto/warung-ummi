import 'dart:io';

import 'package:flutter/widgets.dart';

Widget localImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  AlignmentGeometry alignment = Alignment.center,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    alignment: alignment,
    errorBuilder: errorBuilder,
  );
}
