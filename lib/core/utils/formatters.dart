import 'package:intl/intl.dart';

final NumberFormat _decimal = NumberFormat.decimalPattern('id_ID');

String rupiah(int value) => 'Rp ${_decimal.format(value)}';

const List<String> _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const List<String> _monthLong = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatTime(DateTime date) =>
    '${twoDigits(date.hour)}:${twoDigits(date.minute)}';

String formatDate(DateTime date) =>
    '${date.day} ${_monthShort[date.month - 1]} ${date.year}';

String formatDateLong(DateTime date) =>
    '${date.day} ${_monthLong[date.month - 1]} ${date.year}';

String formatDateTime(DateTime date) =>
    '${formatDate(date)} • ${formatTime(date)}';

String formatDateKey(DateTime date) =>
    '${date.year}${twoDigits(date.month)}${twoDigits(date.day)}';

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return formatDate(date);
}

String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
