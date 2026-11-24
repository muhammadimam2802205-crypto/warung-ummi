import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/extensions.dart';
import '../core/utils/pricing.dart';
import '../data/local_store.dart';
import '../data/models.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => throw UnimplementedError('LocalStore belum diinisialisasi'),
);

// ---------------------------------------------------------------- AUTH

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthNotifier extends Notifier<AppUser?> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  AppUser? build() {
    final store = ref.read(localStoreProvider);
    final id = store.sessionUserId;
    if (id == null) return null;
    for (final user in store.users) {
      if (user.id == id) return user;
    }
    return null;
  }

  /// Masuk memakai email ATAU nomor telepon.
  /// [remember] = false tetap masuk untuk sesi ini, tetapi tidak menyimpan
  /// sesi di perangkat setelah aplikasi ditutup.
  String? login(String identifier, String password, {bool remember = true}) {
    final trimmed = identifier.trim();
    final normalized = trimmed.toLowerCase();
    AppUser? found;
    for (final user in _store.users) {
      final sameEmail = user.email.toLowerCase() == normalized;
      final samePhone = user.phone.isNotEmpty && user.phone == trimmed;
      if (sameEmail || samePhone) {
        found = user;
        break;
      }
    }
    if (found == null) return 'Email atau nomor telepon belum terdaftar.';
    if (found.password != password) return 'Kata sandi salah.';
    _store.setSessionUserId(remember ? found.id : null);
    state = found;
    return null;
  }

  /// Masuk sebagai tamu: membuat (sekali) akun tamu lokal agar pengguna bisa
  /// melihat menu dan mencoba alur pesanan tanpa mendaftar.
  String? loginAsGuest() {
    const guestEmail = 'tamu@kedaiummi.local';
    AppUser? guest;
    for (final user in _store.users) {
      if (user.email == guestEmail) {
        guest = user;
        break;
      }
    }
    if (guest == null) {
      guest = AppUser(
        id: newId('user'),
        name: 'Tamu',
        email: guestEmail,
        phone: '',
        password: newId('guest'),
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );
      _store.saveUsers([..._store.users, guest]);
    }
    _store.setSessionUserId(guest.id);
    state = guest;
    return null;
  }

  String? register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    final normalized = email.trim().toLowerCase();
    final users = _store.users;
    if (users.any((user) => user.email.toLowerCase() == normalized)) {
      return 'Email sudah digunakan.';
    }
    final user = AppUser(
      id: newId('user'),
      name: name.trim(),
      email: normalized,
      phone: phone.trim(),
      password: password,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );
    _store.saveUsers([...users, user]);
    _store.setSessionUserId(user.id);
    state = user;
    return null;
  }

  void logout() {
    _store.setSessionUserId(null);
    state = null;
  }

  void updateProfile({required String name, required String phone}) {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(name: name.trim(), phone: phone.trim());
    final users = _store.users
        .map((user) => user.id == current.id ? updated : user)
        .toList();
    _store.saveUsers(users);
    state = updated;
  }
}

// ---------------------------------------------------------------- CATALOG

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

class CategoriesNotifier extends Notifier<List<Category>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Category> build() {
    final list = [..._store.categories];
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  void saveCategory(Category category) {
    final list = [...state];
    final index = list.indexWhere((item) => item.id == category.id);
    if (index >= 0) {
      list[index] = category;
    } else {
      list.add(category);
    }
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _store.saveCategories(list);
    state = list;
  }

  void deleteCategory(String id) {
    final list = state.where((item) => item.id != id).toList();
    _store.saveCategories(list);
    state = list;
  }

  Category? byId(String id) {
    for (final category in state) {
      if (category.id == id) return category;
    }
    return null;
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends Notifier<List<Product>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Product> build() {
    final list = [..._store.products];
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  void saveProduct(Product product) {
    final list = [...state];
    final index = list.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      list[index] = product;
    } else {
      list.add(product);
    }
    _store.saveProducts(list);
    state = list;
  }

  void deleteProduct(String id) {
    final list = state.where((item) => item.id != id).toList();
    _store.saveProducts(list);
    state = list;
  }

  void toggleAvailability(String id) {
    final list = state
        .map(
          (item) =>
              item.id == id ? item.copyWith(available: !item.available) : item,
        )
        .toList();
    _store.saveProducts(list);
    state = list;
  }

  Product? byId(String id) {
    for (final product in state) {
      if (product.id == id) return product;
    }
    return null;
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, StoreSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<StoreSettings> {
  @override
  StoreSettings build() => ref.read(localStoreProvider).settings;

  void save(StoreSettings settings) {
    ref.read(localStoreProvider).saveSettings(settings);
    state = settings;
  }

  void toggleOpen(bool isOpen) {
    save(state.copyWith(isOpen: isOpen));
  }
}

// ---------------------------------------------------------------- DELIVERY

final zonesProvider = NotifierProvider<ZonesNotifier, List<DeliveryZone>>(
  ZonesNotifier.new,
);

class ZonesNotifier extends Notifier<List<DeliveryZone>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<DeliveryZone> build() => [..._store.zones];

  void saveZone(DeliveryZone zone) {
    final list = [...state];
    final index = list.indexWhere((item) => item.id == zone.id);
    if (index >= 0) {
      list[index] = zone;
    } else {
      list.add(zone);
    }
    _store.saveZones(list);
    state = list;
  }

  void deleteZone(String id) {
    final list = state.where((item) => item.id != id).toList();
    _store.saveZones(list);
    state = list;
  }
}

final couriersProvider = NotifierProvider<CouriersNotifier, List<Courier>>(
  CouriersNotifier.new,
);

class CouriersNotifier extends Notifier<List<Courier>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Courier> build() => [..._store.couriers];

  void saveCourier(Courier courier) {
    final list = [...state];
    final index = list.indexWhere((item) => item.id == courier.id);
    if (index >= 0) {
      list[index] = courier;
    } else {
      list.add(courier);
    }
    _store.saveCouriers(list);
    state = list;
  }

  void deleteCourier(String id) {
    final list = state.where((item) => item.id != id).toList();
    _store.saveCouriers(list);
    state = list;
  }
}

final tablesProvider = NotifierProvider<TablesNotifier, List<TableSpot>>(
  TablesNotifier.new,
);

class TablesNotifier extends Notifier<List<TableSpot>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<TableSpot> build() => [..._store.tables];

  void saveTable(TableSpot table) {
    final list = [...state];
    final index = list.indexWhere((item) => item.id == table.id);
    if (index >= 0) {
      list[index] = table;
    } else {
      list.add(table);
    }
    _store.saveTables(list);
    state = list;
  }

  void deleteTable(String id) {
    final list = state.where((item) => item.id != id).toList();
    _store.saveTables(list);
    state = list;
  }

  TableSpot? byCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final table in state) {
      if (table.active && table.code.toUpperCase() == normalized) return table;
    }
    return null;
  }
}

// ---------------------------------------------------------------- ADDRESSES

final addressesProvider = NotifierProvider<AddressesNotifier, List<Address>>(
  AddressesNotifier.new,
);

class AddressesNotifier extends Notifier<List<Address>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Address> build() {
    final user = ref.watch(authProvider);
    if (user == null) return [];
    return _forUser(user.id);
  }

  List<Address> _forUser(String userId) {
    final list = _store.addresses.where((a) => a.userId == userId).toList();
    list.sort((a, b) {
      if (a.isPrimary == b.isPrimary) return 0;
      return a.isPrimary ? -1 : 1;
    });
    return list;
  }

  void _reload() {
    final user = ref.read(authProvider);
    state = user == null ? [] : _forUser(user.id);
  }

  void saveAddress(Address address) {
    var all = [..._store.addresses];
    final index = all.indexWhere((item) => item.id == address.id);
    if (index >= 0) {
      all[index] = address;
    } else {
      all.add(address);
    }
    if (address.isPrimary) {
      all = all
          .map(
            (item) => item.userId == address.userId && item.id != address.id
                ? item.copyWith(isPrimary: false)
                : item,
          )
          .toList();
    }
    _store.saveAddresses(all);
    _reload();
  }

  void deleteAddress(String id) {
    final all = _store.addresses.where((item) => item.id != id).toList();
    _store.saveAddresses(all);
    _reload();
  }
}

// ---------------------------------------------------------------- CART

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<CartItem> build() {
    final user = ref.watch(authProvider);
    if (user == null) return [];
    return _store.cartFor(user.id);
  }

  void addItem(
    Product product, {
    ProductVariant? variant,
    int qty = 1,
    String note = '',
  }) {
    final user = ref.read(authProvider);
    if (user == null) return;
    final variantKey = variant?.id ?? '';
    final items = [...state];
    final index = items.indexWhere(
      (item) =>
          item.productId == product.id &&
          (item.variantId ?? '') == variantKey &&
          item.note == note,
    );
    if (index >= 0) {
      final current = items[index];
      items[index] = current.copyWith(qty: current.qty + qty);
    } else {
      items.add(
        CartItem(
          id: newId('cart'),
          productId: product.id,
          name: product.name,
          image: product.image,
          emoji: product.emoji,
          variantId: variant?.id,
          variantName: variant?.name,
          unitPrice: product.price + (variant?.priceDelta ?? 0),
          qty: qty,
          note: note,
        ),
      );
    }
    _store.saveCart(user.id, items);
    state = items;
  }

  void changeQty(String itemId, int qty) {
    final user = ref.read(authProvider);
    if (user == null) return;
    final items = state
        .map((item) => item.id == itemId ? item.copyWith(qty: qty) : item)
        .where((item) => item.qty > 0)
        .toList();
    _store.saveCart(user.id, items);
    state = items;
  }

  void removeItem(String itemId) {
    final user = ref.read(authProvider);
    if (user == null) return;
    final items = state.where((item) => item.id != itemId).toList();
    _store.saveCart(user.id, items);
    state = items;
  }

  void clear() {
    final user = ref.read(authProvider);
    if (user == null) return;
    _store.clearCart(user.id);
    state = [];
  }
}

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.qty),
);

final cartSubtotalProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.lineTotal),
);

// ---------------------------------------------------------------- ORDERS

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

class OrdersNotifier extends Notifier<List<Order>> {
  LocalStore get _store => ref.read(localStoreProvider);

  @override
  List<Order> build() {
    final list = [..._store.orders];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void _persist(List<Order> orders) {
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _store.saveOrders(orders);
    state = orders;
  }

  void _replace(Order updated) {
    _persist(
      state.map((order) => order.id == updated.id ? updated : order).toList(),
    );
  }

  Order createOrder({
    required AppUser user,
    required List<CartItem> items,
    required ServiceType serviceType,
    required PaymentMethod paymentMethod,
    String note = '',
    String? tableCode,
    String? addressText,
    DeliveryZone? zone,
  }) {
    final now = DateTime.now();
    final subtotal = cartSubtotal(items);
    final deliveryFee = deliveryFeeFor(serviceType, zone);
    final counter = _store.nextOrderCounter();
    final order = Order(
      id: newId('order'),
      orderNumber: buildOrderNumber(now, counter),
      userId: user.id,
      customerName: user.name,
      customerPhone: user.phone,
      serviceType: serviceType,
      tableCode: tableCode,
      addressText: addressText,
      zoneName: zone?.name,
      items: items
          .map(
            (item) => OrderItem(
              productId: item.productId,
              name: item.name,
              image: item.image,
              emoji: item.emoji,
              variantName: item.variantName,
              unitPrice: item.unitPrice,
              qty: item.qty,
              note: item.note,
            ),
          )
          .toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: subtotal + deliveryFee,
      status: OrderStatus.pendingConfirmation,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == PaymentMethod.cash
          ? PaymentStatus.unpaid
          : PaymentStatus.pending,
      createdAt: now,
      updatedAt: now,
      note: note,
      timeline: [
        TimelineEntry(
          status: OrderStatus.pendingConfirmation,
          at: now,
          note: 'Pesanan dikirim pelanggan.',
        ),
      ],
    );
    _persist([order, ...state]);
    return order;
  }

  void updateStatus(
    String orderId,
    OrderStatus newStatus, {
    String? note,
    Courier? courier,
    String? rejectionReason,
  }) {
    final order = state.where((item) => item.id == orderId).firstOrNull;
    if (order == null) return;
    if (!order.nextStatuses.contains(newStatus)) return;
    final now = DateTime.now();
    var paymentStatus = order.paymentStatus;
    if (newStatus == OrderStatus.completed &&
        order.paymentMethod == PaymentMethod.cash &&
        paymentStatus == PaymentStatus.unpaid) {
      paymentStatus = PaymentStatus.paid;
    }
    final timeline = [
      ...order.timeline,
      TimelineEntry(
        status: newStatus,
        at: now,
        note: note ?? (courier != null ? 'Kurir: ${courier.name}' : ''),
      ),
    ];
    _replace(
      order.copyWith(
        status: newStatus,
        paymentStatus: paymentStatus,
        timeline: timeline,
        updatedAt: now,
        courierId: courier?.id,
        courierName: courier?.name,
        rejectionReason: rejectionReason,
      ),
    );
  }

  void submitPaymentProof(String orderId, String path) {
    final order = state.where((item) => item.id == orderId).firstOrNull;
    if (order == null) return;
    _replace(
      order.copyWith(
        paymentProofPath: path,
        paymentStatus: PaymentStatus.waitingVerification,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void verifyPayment(String orderId, bool approved) {
    final order = state.where((item) => item.id == orderId).firstOrNull;
    if (order == null) return;
    _replace(
      order.copyWith(
        paymentStatus: approved ? PaymentStatus.paid : PaymentStatus.rejected,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void cancelByCustomer(String orderId) {
    final order = state.where((item) => item.id == orderId).firstOrNull;
    if (order == null) return;
    if (order.status != OrderStatus.pendingConfirmation) return;
    updateStatus(
      orderId,
      OrderStatus.cancelled,
      note: 'Dibatalkan oleh pelanggan.',
    );
  }
}

final myOrdersProvider = Provider<List<Order>>((ref) {
  final user = ref.watch(authProvider);
  final orders = ref.watch(ordersProvider);
  if (user == null) return [];
  return orders.where((order) => order.userId == user.id).toList();
});

final adminStatsProvider = Provider<AdminStats>((ref) {
  final orders = ref.watch(ordersProvider);
  return AdminStats.fromOrders(orders);
});

class AdminStats {
  const AdminStats({
    required this.totalOrders,
    required this.incoming,
    required this.processing,
    required this.ready,
    required this.completed,
    required this.cancelled,
    required this.revenue,
    required this.todayOrders,
    required this.todayRevenue,
  });

  final int totalOrders;
  final int incoming;
  final int processing;
  final int ready;
  final int completed;
  final int cancelled;
  final int revenue;
  final int todayOrders;
  final int todayRevenue;

  factory AdminStats.fromOrders(List<Order> orders) {
    final now = DateTime.now();
    var revenue = 0;
    var todayRevenue = 0;
    var todayOrders = 0;
    for (final order in orders) {
      final paid = order.paymentStatus == PaymentStatus.paid;
      final valid =
          order.status != OrderStatus.rejected &&
          order.status != OrderStatus.cancelled;
      if (paid && valid) revenue += order.total;
      final sameDay =
          order.createdAt.year == now.year &&
          order.createdAt.month == now.month &&
          order.createdAt.day == now.day;
      if (sameDay) {
        todayOrders++;
        if (paid && valid) todayRevenue += order.total;
      }
    }
    return AdminStats(
      totalOrders: orders.length,
      incoming: orders
          .where((o) => o.status == OrderStatus.pendingConfirmation)
          .length,
      processing: orders
          .where(
            (o) =>
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.preparing,
          )
          .length,
      ready: orders
          .where(
            (o) =>
                o.status == OrderStatus.readyForPickup ||
                o.status == OrderStatus.outForDelivery,
          )
          .length,
      completed: orders.where((o) => o.status == OrderStatus.completed).length,
      cancelled: orders
          .where(
            (o) =>
                o.status == OrderStatus.cancelled ||
                o.status == OrderStatus.rejected,
          )
          .length,
      revenue: revenue,
      todayOrders: todayOrders,
      todayRevenue: todayRevenue,
    );
  }
}
