import 'package:flutter_test/flutter_test.dart';
import 'package:ummie/core/utils/pricing.dart';
import 'package:ummie/data/models.dart';

void main() {
  group('Perhitungan biaya pesanan', () {
    const items = [
      CartItem(
        id: 'c1',
        productId: 'p1',
        name: 'Kebab Ayam Spesial',
        emoji: '🌯',
        unitPrice: 18000,
        qty: 2,
      ),
      CartItem(
        id: 'c2',
        productId: 'p2',
        name: 'Es Teh Manis',
        emoji: '🧋',
        unitPrice: 5000,
        qty: 1,
      ),
    ];
    const zone = DeliveryZone(id: 'z1', name: 'Sekitar Kedai', fee: 5000);

    test('subtotal dihitung dari harga x jumlah', () {
      expect(cartSubtotal(items), 41000);
    });

    test('dine-in dan takeaway tidak dikenakan biaya kirim', () {
      expect(deliveryFeeFor(ServiceType.dineIn, zone), 0);
      expect(deliveryFeeFor(ServiceType.takeaway, zone), 0);
    });

    test('delivery memakai tarif zona', () {
      expect(deliveryFeeFor(ServiceType.delivery, zone), 5000);
      expect(deliveryFeeFor(ServiceType.delivery, null), 0);
      expect(
        orderTotal(items: items, serviceType: ServiceType.delivery, zone: zone),
        46000,
      );
    });

    test('nomor transaksi unik dan berurutan', () {
      final date = DateTime(2026, 11, 20);
      expect(buildOrderNumber(date, 1), 'KU-20261120-0001');
      expect(buildOrderNumber(date, 42), 'KU-20261120-0042');
    });
  });

  group('Alur status pesanan', () {
    Order orderWith(ServiceType serviceType, OrderStatus status) => Order(
      id: 'o1',
      orderNumber: 'KU-20261120-0001',
      userId: 'u1',
      customerName: 'Budi',
      customerPhone: '0812',
      serviceType: serviceType,
      items: const [],
      subtotal: 0,
      deliveryFee: 0,
      total: 0,
      status: status,
      paymentMethod: PaymentMethod.cash,
      paymentStatus: PaymentStatus.unpaid,
      createdAt: DateTime(2026, 11, 20),
      updatedAt: DateTime(2026, 11, 20),
      timeline: const [],
    );

    test('pesanan delivery lanjut ke out for delivery', () {
      final order = orderWith(ServiceType.delivery, OrderStatus.preparing);
      expect(order.nextStatuses, contains(OrderStatus.outForDelivery));
      expect(order.nextStatuses, isNot(contains(OrderStatus.readyForPickup)));
    });

    test('pesanan takeaway lanjut ke siap diambil', () {
      final order = orderWith(ServiceType.takeaway, OrderStatus.preparing);
      expect(order.nextStatuses, contains(OrderStatus.readyForPickup));
    });

    test('pesanan selesai tidak punya status lanjutan', () {
      final order = orderWith(ServiceType.dineIn, OrderStatus.completed);
      expect(order.nextStatuses, isEmpty);
    });
  });

  group('Serialisasi model', () {
    test('order dapat disimpan dan dibaca kembali', () {
      final now = DateTime(2026, 11, 20, 10, 30);
      final order = Order(
        id: 'o1',
        orderNumber: 'KU-20261120-0001',
        userId: 'u1',
        customerName: 'Budi',
        customerPhone: '0812',
        serviceType: ServiceType.delivery,
        addressText: 'Jl. Melati No. 12',
        items: const [
          OrderItem(
            productId: 'p1',
            name: 'Kebab',
            emoji: '🌯',
            variantName: 'Pedas',
            unitPrice: 18000,
            qty: 2,
          ),
        ],
        subtotal: 36000,
        deliveryFee: 5000,
        total: 41000,
        status: OrderStatus.pendingConfirmation,
        paymentMethod: PaymentMethod.qris,
        paymentStatus: PaymentStatus.pending,
        createdAt: now,
        updatedAt: now,
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: now),
        ],
      );

      final restored = Order.fromJson(order.toJson());
      expect(restored.orderNumber, order.orderNumber);
      expect(restored.total, 41000);
      expect(restored.items.single.variantName, 'Pedas');
      expect(restored.serviceType, ServiceType.delivery);
      expect(restored.status, OrderStatus.pendingConfirmation);
    });
  });
}
