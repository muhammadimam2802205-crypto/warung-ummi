import 'dart:math';

enum UserRole { customer, admin }

enum ServiceType { dineIn, takeaway, delivery }

enum OrderStatus {
  pendingConfirmation,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  completed,
  rejected,
  cancelled,
}

enum PaymentMethod { cash, transfer, qris }

enum PaymentStatus { pending, waitingVerification, paid, rejected, unpaid }

extension UserRoleX on UserRole {
  String get label => this == UserRole.admin ? 'Admin' : 'Pelanggan';
}

extension ServiceTypeX on ServiceType {
  String get label => switch (this) {
    ServiceType.dineIn => 'Dine-In',
    ServiceType.takeaway => 'Takeaway',
    ServiceType.delivery => 'Delivery',
  };

  String get description => switch (this) {
    ServiceType.dineIn => 'Makan di tempat',
    ServiceType.takeaway => 'Ambil di kedai',
    ServiceType.delivery => 'Diantar kurir',
  };
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pendingConfirmation => 'Menunggu Konfirmasi',
    OrderStatus.confirmed => 'Dikonfirmasi',
    OrderStatus.preparing => 'Sedang Diproses',
    OrderStatus.readyForPickup => 'Siap Diambil',
    OrderStatus.outForDelivery => 'Sedang Diantar',
    OrderStatus.completed => 'Selesai',
    OrderStatus.rejected => 'Ditolak',
    OrderStatus.cancelled => 'Dibatalkan',
  };

  String get customerHint => switch (this) {
    OrderStatus.pendingConfirmation =>
      'Pesanan menunggu konfirmasi admin kedai.',
    OrderStatus.confirmed => 'Pesanan diterima dan segera disiapkan.',
    OrderStatus.preparing => 'Pesanan sedang disiapkan oleh kedai.',
    OrderStatus.readyForPickup => 'Pesanan sudah siap. Silakan ambil di kedai.',
    OrderStatus.outForDelivery => 'Pesanan sedang diantar oleh kurir.',
    OrderStatus.completed => 'Pesanan telah selesai. Terima kasih!',
    OrderStatus.rejected => 'Pesanan ditolak oleh kedai.',
    OrderStatus.cancelled => 'Pesanan dibatalkan.',
  };

  bool get isFinished =>
      this == OrderStatus.completed ||
      this == OrderStatus.rejected ||
      this == OrderStatus.cancelled;
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Tunai',
    PaymentMethod.transfer => 'Transfer Bank',
    PaymentMethod.qris => 'QRIS',
  };

  String get description => switch (this) {
    PaymentMethod.cash => 'Bayar langsung di kedai',
    PaymentMethod.transfer => 'Transfer ke rekening kedai',
    PaymentMethod.qris => 'Scan QRIS resmi kedai',
  };

  bool get needsProof => this != PaymentMethod.cash;
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.pending => 'Menunggu Pembayaran',
    PaymentStatus.waitingVerification => 'Menunggu Verifikasi',
    PaymentStatus.paid => 'Lunas',
    PaymentStatus.rejected => 'Ditolak',
    PaymentStatus.unpaid => 'Belum Dibayar',
  };
}

String newId([String prefix = 'id']) {
  final random = Random();
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(9999)}';
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final DateTime createdAt;

  AppUser copyWith({String? name, String? phone, String? password}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role,
      createdAt: createdAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String? ?? '',
    password: json['password'] as String? ?? '',
    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.customer,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
    'role': role.name,
    'createdAt': createdAt.toIso8601String(),
  };
}

class Address {
  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.detail,
    this.zoneId,
    this.isPrimary = false,
  });

  final String id;
  final String userId;
  final String label;
  final String recipient;
  final String phone;
  final String detail;
  final String? zoneId;
  final bool isPrimary;

  Address copyWith({bool? isPrimary}) => Address(
    id: id,
    userId: userId,
    label: label,
    recipient: recipient,
    phone: phone,
    detail: detail,
    zoneId: zoneId,
    isPrimary: isPrimary ?? this.isPrimary,
  );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] as String,
    userId: json['userId'] as String,
    label: json['label'] as String,
    recipient: json['recipient'] as String,
    phone: json['phone'] as String,
    detail: json['detail'] as String,
    zoneId: json['zoneId'] as String?,
    isPrimary: json['isPrimary'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'label': label,
    'recipient': recipient,
    'phone': phone,
    'detail': detail,
    'zoneId': zoneId,
    'isPrimary': isPrimary,
  };
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.emoji,
    this.sortOrder = 0,
    this.active = true,
  });

  final String id;
  final String name;
  final String emoji;
  final int sortOrder;
  final bool active;

  Category copyWith({String? name, String? emoji, bool? active}) => Category(
    id: id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    sortOrder: sortOrder,
    active: active ?? this.active,
  );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String? ?? '🍽️',
    sortOrder: json['sortOrder'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'sortOrder': sortOrder,
    'active': active,
  };
}

class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    this.priceDelta = 0,
  });

  final String id;
  final String name;
  final int priceDelta;

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] as String,
    name: json['name'] as String,
    priceDelta: json['priceDelta'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'priceDelta': priceDelta,
  };
}

class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.image = '',
    this.emoji = '🍽️',
    this.available = true,
    this.variants = const [],
    this.sortOrder = 0,
  });

  final String id;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final String image;
  final String emoji;
  final bool available;
  final List<ProductVariant> variants;
  final int sortOrder;

  Product copyWith({
    String? categoryId,
    String? name,
    String? description,
    int? price,
    String? image,
    String? emoji,
    bool? available,
    List<ProductVariant>? variants,
  }) => Product(
    id: id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    image: image ?? this.image,
    emoji: emoji ?? this.emoji,
    available: available ?? this.available,
    variants: variants ?? this.variants,
    sortOrder: sortOrder,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    price: json['price'] as int? ?? 0,
    image: json['image'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '🍽️',
    available: json['available'] as bool? ?? true,
    variants: (json['variants'] as List<dynamic>? ?? [])
        .map(
          (e) => ProductVariant.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    sortOrder: json['sortOrder'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'image': image,
    'emoji': emoji,
    'available': available,
    'variants': variants.map((e) => e.toJson()).toList(),
    'sortOrder': sortOrder,
  };
}

class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.emoji,
    required this.unitPrice,
    required this.qty,
    this.image = '',
    this.variantId,
    this.variantName,
    this.note = '',
  });

  final String id;
  final String productId;
  final String name;
  final String image;
  final String emoji;
  final String? variantId;
  final String? variantName;
  final int unitPrice;
  final int qty;
  final String note;

  int get lineTotal => unitPrice * qty;

  CartItem copyWith({int? qty}) => CartItem(
    id: id,
    productId: productId,
    name: name,
    image: image,
    emoji: emoji,
    variantId: variantId,
    variantName: variantName,
    unitPrice: unitPrice,
    qty: qty ?? this.qty,
    note: note,
  );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    productId: json['productId'] as String,
    name: json['name'] as String,
    image: json['image'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '🍽️',
    variantId: json['variantId'] as String?,
    variantName: json['variantName'] as String?,
    unitPrice: json['unitPrice'] as int? ?? 0,
    qty: json['qty'] as int? ?? 1,
    note: json['note'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'name': name,
    'image': image,
    'emoji': emoji,
    'variantId': variantId,
    'variantName': variantName,
    'unitPrice': unitPrice,
    'qty': qty,
    'note': note,
  };
}

class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.name,
    required this.fee,
    this.active = true,
  });

  final String id;
  final String name;
  final int fee;
  final bool active;

  DeliveryZone copyWith({String? name, int? fee, bool? active}) => DeliveryZone(
    id: id,
    name: name ?? this.name,
    fee: fee ?? this.fee,
    active: active ?? this.active,
  );

  factory DeliveryZone.fromJson(Map<String, dynamic> json) => DeliveryZone(
    id: json['id'] as String,
    name: json['name'] as String,
    fee: json['fee'] as int? ?? 0,
    active: json['active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fee': fee,
    'active': active,
  };
}

class Courier {
  const Courier({
    required this.id,
    required this.name,
    required this.phone,
    this.active = true,
    this.available = true,
  });

  final String id;
  final String name;
  final String phone;
  final bool active;
  final bool available;

  Courier copyWith({
    String? name,
    String? phone,
    bool? active,
    bool? available,
  }) => Courier(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    active: active ?? this.active,
    available: available ?? this.available,
  );

  factory Courier.fromJson(Map<String, dynamic> json) => Courier(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    active: json['active'] as bool? ?? true,
    available: json['available'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'active': active,
    'available': available,
  };
}

class TableSpot {
  const TableSpot({
    required this.id,
    required this.code,
    required this.label,
    this.active = true,
  });

  final String id;
  final String code;
  final String label;
  final bool active;

  factory TableSpot.fromJson(Map<String, dynamic> json) => TableSpot(
    id: json['id'] as String,
    code: json['code'] as String,
    label: json['label'] as String,
    active: json['active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'label': label,
    'active': active,
  };
}

class StoreSettings {
  const StoreSettings({
    required this.name,
    required this.tagline,
    required this.description,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.openHours,
    required this.bankName,
    required this.bankNumber,
    required this.bankHolder,
    required this.qrisNote,
    this.deliveryEnabled = true,
  });

  final String name;
  final String tagline;
  final String description;
  final String address;
  final String phone;
  final bool isOpen;
  final String openHours;
  final String bankName;
  final String bankNumber;
  final String bankHolder;
  final String qrisNote;
  final bool deliveryEnabled;

  StoreSettings copyWith({
    String? name,
    String? tagline,
    String? description,
    String? address,
    String? phone,
    bool? isOpen,
    String? openHours,
    String? bankName,
    String? bankNumber,
    String? bankHolder,
    String? qrisNote,
    bool? deliveryEnabled,
  }) => StoreSettings(
    name: name ?? this.name,
    tagline: tagline ?? this.tagline,
    description: description ?? this.description,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    isOpen: isOpen ?? this.isOpen,
    openHours: openHours ?? this.openHours,
    bankName: bankName ?? this.bankName,
    bankNumber: bankNumber ?? this.bankNumber,
    bankHolder: bankHolder ?? this.bankHolder,
    qrisNote: qrisNote ?? this.qrisNote,
    deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
  );

  factory StoreSettings.fromJson(Map<String, dynamic> json) => StoreSettings(
    name: json['name'] as String? ?? 'Kedai Ummi',
    tagline: json['tagline'] as String? ?? '',
    description: json['description'] as String? ?? '',
    address: json['address'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    isOpen: json['isOpen'] as bool? ?? true,
    openHours: json['openHours'] as String? ?? '',
    bankName: json['bankName'] as String? ?? '',
    bankNumber: json['bankNumber'] as String? ?? '',
    bankHolder: json['bankHolder'] as String? ?? '',
    qrisNote: json['qrisNote'] as String? ?? '',
    deliveryEnabled: json['deliveryEnabled'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'tagline': tagline,
    'description': description,
    'address': address,
    'phone': phone,
    'isOpen': isOpen,
    'openHours': openHours,
    'bankName': bankName,
    'bankNumber': bankNumber,
    'bankHolder': bankHolder,
    'qrisNote': qrisNote,
    'deliveryEnabled': deliveryEnabled,
  };
}

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.emoji,
    required this.unitPrice,
    required this.qty,
    this.image = '',
    this.variantName,
    this.note = '',
  });

  final String productId;
  final String name;
  final String image;
  final String emoji;
  final String? variantName;
  final int unitPrice;
  final int qty;
  final String note;

  int get lineTotal => unitPrice * qty;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    name: json['name'] as String,
    image: json['image'] as String? ?? '',
    emoji: json['emoji'] as String? ?? '🍽️',
    variantName: json['variantName'] as String?,
    unitPrice: json['unitPrice'] as int? ?? 0,
    qty: json['qty'] as int? ?? 1,
    note: json['note'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'image': image,
    'emoji': emoji,
    'variantName': variantName,
    'unitPrice': unitPrice,
    'qty': qty,
    'note': note,
  };
}

class TimelineEntry {
  const TimelineEntry({required this.status, required this.at, this.note = ''});

  final OrderStatus status;
  final DateTime at;
  final String note;

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => TimelineEntry(
    status: OrderStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => OrderStatus.pendingConfirmation,
    ),
    at: DateTime.parse(json['at'] as String),
    note: json['note'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'at': at.toIso8601String(),
    'note': note,
  };
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.timeline,
    this.tableCode,
    this.addressText,
    this.zoneName,
    this.paymentProofPath,
    this.courierId,
    this.courierName,
    this.note = '',
    this.rejectionReason,
  });

  final String id;
  final String orderNumber;
  final String userId;
  final String customerName;
  final String customerPhone;
  final ServiceType serviceType;
  final String? tableCode;
  final String? addressText;
  final String? zoneName;
  final List<OrderItem> items;
  final int subtotal;
  final int deliveryFee;
  final int total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? paymentProofPath;
  final String? courierId;
  final String? courierName;
  final String note;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimelineEntry> timeline;

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  List<OrderStatus> get nextStatuses {
    switch (status) {
      case OrderStatus.pendingConfirmation:
        return const [OrderStatus.confirmed, OrderStatus.rejected];
      case OrderStatus.confirmed:
        return const [OrderStatus.preparing, OrderStatus.cancelled];
      case OrderStatus.preparing:
        return [
          serviceType == ServiceType.delivery
              ? OrderStatus.outForDelivery
              : OrderStatus.readyForPickup,
          OrderStatus.cancelled,
        ];
      case OrderStatus.readyForPickup:
        return const [OrderStatus.completed];
      case OrderStatus.outForDelivery:
        return const [OrderStatus.completed];
      case OrderStatus.completed:
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return const [];
    }
  }

  Order copyWith({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentProofPath,
    String? courierId,
    String? courierName,
    String? rejectionReason,
    DateTime? updatedAt,
    List<TimelineEntry>? timeline,
  }) => Order(
    id: id,
    orderNumber: orderNumber,
    userId: userId,
    customerName: customerName,
    customerPhone: customerPhone,
    serviceType: serviceType,
    tableCode: tableCode,
    addressText: addressText,
    zoneName: zoneName,
    items: items,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    total: total,
    status: status ?? this.status,
    paymentMethod: paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    paymentProofPath: paymentProofPath ?? this.paymentProofPath,
    courierId: courierId ?? this.courierId,
    courierName: courierName ?? this.courierName,
    note: note,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    timeline: timeline ?? this.timeline,
  );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    orderNumber: json['orderNumber'] as String,
    userId: json['userId'] as String,
    customerName: json['customerName'] as String,
    customerPhone: json['customerPhone'] as String? ?? '',
    serviceType: ServiceType.values.firstWhere(
      (e) => e.name == json['serviceType'],
      orElse: () => ServiceType.takeaway,
    ),
    tableCode: json['tableCode'] as String?,
    addressText: json['addressText'] as String?,
    zoneName: json['zoneName'] as String?,
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    subtotal: json['subtotal'] as int? ?? 0,
    deliveryFee: json['deliveryFee'] as int? ?? 0,
    total: json['total'] as int? ?? 0,
    status: OrderStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => OrderStatus.pendingConfirmation,
    ),
    paymentMethod: PaymentMethod.values.firstWhere(
      (e) => e.name == json['paymentMethod'],
      orElse: () => PaymentMethod.cash,
    ),
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == json['paymentStatus'],
      orElse: () => PaymentStatus.pending,
    ),
    paymentProofPath: json['paymentProofPath'] as String?,
    courierId: json['courierId'] as String?,
    courierName: json['courierName'] as String?,
    note: json['note'] as String? ?? '',
    rejectionReason: json['rejectionReason'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    timeline: (json['timeline'] as List<dynamic>? ?? [])
        .map((e) => TimelineEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'userId': userId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'serviceType': serviceType.name,
    'tableCode': tableCode,
    'addressText': addressText,
    'zoneName': zoneName,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'total': total,
    'status': status.name,
    'paymentMethod': paymentMethod.name,
    'paymentStatus': paymentStatus.name,
    'paymentProofPath': paymentProofPath,
    'courierId': courierId,
    'courierName': courierName,
    'note': note,
    'rejectionReason': rejectionReason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'timeline': timeline.map((e) => e.toJson()).toList(),
  };
}
