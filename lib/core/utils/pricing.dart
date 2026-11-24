import '../../data/models.dart';

/// Perhitungan biaya terpusat agar konsisten di cart, checkout, dan order.
int cartSubtotal(Iterable<CartItem> items) =>
    items.fold(0, (sum, item) => sum + item.lineTotal);

int deliveryFeeFor(ServiceType serviceType, DeliveryZone? zone) {
  if (serviceType != ServiceType.delivery) return 0;
  return zone?.fee ?? 0;
}

int orderTotal({
  required Iterable<CartItem> items,
  required ServiceType serviceType,
  DeliveryZone? zone,
}) {
  return cartSubtotal(items) + deliveryFeeFor(serviceType, zone);
}

String buildOrderNumber(DateTime date, int counter) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return 'KU-${date.year}$month$day-${counter.toString().padLeft(4, '0')}';
}
