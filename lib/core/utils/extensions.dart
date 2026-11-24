extension IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

extension StringX on String {
  bool get isBlank => trim().isEmpty;
}
