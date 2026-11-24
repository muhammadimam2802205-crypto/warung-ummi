import 'models.dart';

/// Data awal aplikasi Kedai Ummi.
///
/// Katalog mengikuti daftar menu pada `docs/prd.md` bagian 3. Harga, kategori,
/// dan ketersediaan tetap dapat diubah admin melalui aplikasi.
class SeedData {
  static Map<String, dynamic> build() {
    final now = DateTime.now();

    final users = <AppUser>[
      AppUser(
        id: 'user-admin',
        name: 'Ummi',
        email: 'admin@kedaiummi.id',
        phone: '0812-3456-7890',
        password: 'admin123',
        role: UserRole.admin,
        createdAt: now.subtract(const Duration(days: 240)),
      ),
      AppUser(
        id: 'user-budi',
        name: 'Budi Santoso',
        email: 'budi@mail.com',
        phone: '0812-9876-5432',
        password: '123456',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      AppUser(
        id: 'user-siti',
        name: 'Siti Rahayu',
        email: 'siti@mail.com',
        phone: '0813-2211-8899',
        password: '123456',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 64)),
      ),
      AppUser(
        id: 'user-andi',
        name: 'Andi Pratama',
        email: 'andi@mail.com',
        phone: '0857-3322-1100',
        password: '123456',
        role: UserRole.customer,
        createdAt: now.subtract(const Duration(days: 41)),
      ),
    ];

    final addresses = <Address>[
      const Address(
        id: 'addr-budi-1',
        userId: 'user-budi',
        label: 'Rumah',
        recipient: 'Budi Santoso',
        phone: '0812-9876-5432',
        detail: 'Jl. Melati No. 12, RT 03/RW 05, Sukajadi, Bandung',
        zoneId: 'zone-sekitar',
        isPrimary: true,
      ),
      const Address(
        id: 'addr-siti-1',
        userId: 'user-siti',
        label: 'Kantor',
        recipient: 'Siti Rahayu',
        phone: '0813-2211-8899',
        detail: 'Jl. Setiabudi No. 210, Lantai 2, Bandung',
        zoneId: 'zone-dalam',
        isPrimary: true,
      ),
      const Address(
        id: 'addr-andi-1',
        userId: 'user-andi',
        label: 'Rumah',
        recipient: 'Andi Pratama',
        phone: '0857-3322-1100',
        detail: 'Jl. Cihampelas No. 45, Bandung',
        zoneId: 'zone-sekitar',
        isPrimary: true,
      ),
    ];

    const categories = <Category>[
      Category(id: 'cat-kebab', name: 'Kebab', emoji: '🌯', sortOrder: 0),
      Category(
        id: 'cat-mozarella',
        name: 'Mozarella',
        emoji: '🧀',
        sortOrder: 1,
      ),
      Category(id: 'cat-hottang', name: 'Hottang', emoji: '🌭', sortOrder: 2),
      Category(id: 'cat-sandwich', name: 'Sandwich', emoji: '🥪', sortOrder: 3),
      Category(id: 'cat-burger', name: 'Burger', emoji: '🍔', sortOrder: 4),
      Category(id: 'cat-bakso', name: 'Bakso', emoji: '🍲', sortOrder: 5),
      Category(id: 'cat-mie', name: 'Mie Ayam', emoji: '🍜', sortOrder: 6),
      Category(id: 'cat-miso', name: 'Miso', emoji: '🍥', sortOrder: 7),
      Category(id: 'cat-lotek', name: 'Lotek', emoji: '🥗', sortOrder: 8),
      Category(
        id: 'cat-nasgor',
        name: 'Nasi Goreng',
        emoji: '🍚',
        sortOrder: 9,
      ),
      Category(
        id: 'cat-es-jeruk',
        name: 'Es Jeruk',
        emoji: '🍊',
        sortOrder: 10,
      ),
      Category(
        id: 'cat-jeruk-hangat',
        name: 'Jeruk Hangat',
        emoji: '🍵',
        sortOrder: 11,
      ),
      Category(
        id: 'cat-juice-kurma',
        name: 'Juice Kurma',
        emoji: '🥤',
        sortOrder: 12,
      ),
    ];

    const products = <Product>[
      Product(
        id: 'prod-kebab',
        categoryId: 'cat-kebab',
        image: 'assets/images/products/kebab.jpg',
        name: 'Kebab',
        description:
            'Kebab hangat dengan isian pilihan, sayuran segar, dan saus khas Kedai Ummi.',
        price: 7000,
        emoji: '🌯',
        sortOrder: 0,
        variants: [
          ProductVariant(id: 'kebab-daging', name: 'Daging'),
          ProductVariant(id: 'kebab-telur', name: 'Telur'),
          ProductVariant(id: 'kebab-keju', name: 'Keju'),
          ProductVariant(
            id: 'kebab-daging-keju',
            name: 'Daging Keju',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'kebab-daging-telur',
            name: 'Daging Telur',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'kebab-spesial',
            name: 'Spesial',
            priceDelta: 4000,
          ),
        ],
      ),
      Product(
        id: 'prod-mozarella',
        categoryId: 'cat-mozarella',
        image: 'assets/images/products/mozarella.jpg',
        name: 'Mozarella',
        description:
            'Mozarella gurih dengan aneka rasa manis, cocok untuk camilan sore.',
        price: 7000,
        emoji: '🧀',
        sortOrder: 1,
        variants: [
          ProductVariant(id: 'mozarella-original', name: 'Original'),
          ProductVariant(id: 'mozarella-coklat', name: 'Coklat'),
          ProductVariant(id: 'mozarella-tiramisu', name: 'Tiramisu'),
          ProductVariant(id: 'mozarella-greentea', name: 'Greentea'),
        ],
      ),
      Product(
        id: 'prod-hottang',
        categoryId: 'cat-hottang',
        image: 'assets/images/products/hottang.jpg',
        name: 'Hottang',
        description:
            'Hottang renyah dengan isian sosis atau keju mozarella yang lumer.',
        price: 7000,
        emoji: '🌭',
        sortOrder: 2,
        variants: [
          ProductVariant(id: 'hottang-sosis', name: 'Sosis'),
          ProductVariant(id: 'hottang-keju', name: 'Keju Mozarella'),
        ],
      ),
      Product(
        id: 'prod-sandwich',
        categoryId: 'cat-sandwich',
        image: 'assets/images/products/sandwich.jpg',
        name: 'Sandwich',
        description: 'Sandwich praktis dengan roti lembut dan isian segar.',
        price: 7000,
        emoji: '🥪',
        sortOrder: 3,
      ),
      Product(
        id: 'prod-burger',
        categoryId: 'cat-burger',
        image: 'assets/images/products/burger.jpg',
        name: 'Burger',
        description:
            'Burger dengan daging olahan, keju, dan saus spesial kedai.',
        price: 7000,
        emoji: '🍔',
        sortOrder: 4,
        variants: [
          ProductVariant(id: 'burger-daging', name: 'Daging'),
          ProductVariant(
            id: 'burger-daging-telur',
            name: 'Daging Telur',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'burger-daging-keju',
            name: 'Daging Keju',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'burger-spesial',
            name: 'Daging Spesial',
            priceDelta: 4000,
          ),
        ],
      ),
      Product(
        id: 'prod-bakso',
        categoryId: 'cat-bakso',
        image: 'assets/images/products/bakso.jpg',
        name: 'Bakso',
        description:
            'Bakso sapi dengan kuah kaldu gurih dan pelengkap pilihan.',
        price: 8000,
        emoji: '🍲',
        sortOrder: 5,
        variants: [
          ProductVariant(id: 'bakso-biasa', name: 'Biasa'),
          ProductVariant(id: 'bakso-urat', name: 'Urat', priceDelta: 3000),
          ProductVariant(id: 'bakso-telur', name: 'Telur', priceDelta: 3000),
          ProductVariant(
            id: 'bakso-komplit',
            name: 'Komplit',
            priceDelta: 6000,
          ),
        ],
      ),
      Product(
        id: 'prod-mie-ayam',
        categoryId: 'cat-mie',
        image: 'assets/images/products/mie-ayam.jpg',
        name: 'Mie Ayam',
        description:
            'Mie ayam kenyal dengan topping ayam berbumbu dan kuah hangat.',
        price: 8000,
        emoji: '🍜',
        sortOrder: 6,
        variants: [
          ProductVariant(id: 'mie-ayam', name: 'Mie Ayam'),
          ProductVariant(id: 'mie-bakso', name: 'Bakso', priceDelta: 2000),
          ProductVariant(id: 'mie-telur', name: 'Telur', priceDelta: 5000),
          ProductVariant(id: 'mie-urat', name: 'Urat', priceDelta: 5000),
          ProductVariant(id: 'mie-komplit', name: 'Komplit', priceDelta: 8000),
        ],
      ),
      Product(
        id: 'prod-miso',
        categoryId: 'cat-miso',
        image: 'assets/images/products/miso.jpg',
        name: 'Miso',
        description: 'Miso hangat dengan kuah gurih, tersedia aneka topping.',
        price: 7000,
        emoji: '🍥',
        sortOrder: 7,
        variants: [
          ProductVariant(id: 'miso-biasa', name: 'Biasa'),
          ProductVariant(id: 'miso-bakso', name: 'Bakso', priceDelta: 2000),
          ProductVariant(id: 'miso-telur', name: 'Telur', priceDelta: 5000),
          ProductVariant(id: 'miso-urat', name: 'Urat', priceDelta: 5000),
          ProductVariant(id: 'miso-komplit', name: 'Komplit', priceDelta: 8000),
          ProductVariant(
            id: 'miso-nasi',
            name: 'Miso + Nasi',
            priceDelta: 3000,
          ),
        ],
      ),
      Product(
        id: 'prod-lotek',
        categoryId: 'cat-lotek',
        image: 'assets/images/products/lotek.jpg',
        name: 'Lotek',
        description:
            'Sayuran segar dengan bumbu kacang khas Sunda dan kerupuk.',
        price: 10000,
        emoji: '🥗',
        sortOrder: 8,
        variants: [
          ProductVariant(id: 'lotek-lontong', name: 'Lontong'),
          ProductVariant(id: 'lotek-biasa', name: 'Biasa'),
          ProductVariant(id: 'lotek-bakso', name: 'Bakso', priceDelta: 2000),
          ProductVariant(id: 'lotek-urat', name: 'Urat', priceDelta: 3000),
          ProductVariant(id: 'lotek-telur', name: 'Telur', priceDelta: 3000),
        ],
      ),
      Product(
        id: 'prod-nasi-goreng',
        categoryId: 'cat-nasgor',
        image: 'assets/images/products/nasi-goreng.jpg',
        name: 'Nasi Goreng',
        description:
            'Nasi goreng kampung dengan bumbu meresap dan topping pilihan.',
        price: 10000,
        emoji: '🍚',
        sortOrder: 9,
        variants: [
          ProductVariant(id: 'nasgor-telur', name: 'Telur'),
          ProductVariant(id: 'nasgor-bakso', name: 'Bakso', priceDelta: 3000),
          ProductVariant(id: 'nasgor-ayam', name: 'Ayam', priceDelta: 3000),
          ProductVariant(id: 'nasgor-petai', name: 'Petai', priceDelta: 3000),
          ProductVariant(id: 'nasgor-minas', name: 'Minas', priceDelta: 2000),
        ],
      ),
      Product(
        id: 'prod-es-jeruk',
        categoryId: 'cat-es-jeruk',
        image: 'assets/images/products/es-jeruk.jpg',
        name: 'Es Jeruk',
        description:
            'Perasan jeruk segar dengan es batu, tersedia aneka campuran.',
        price: 6000,
        emoji: '🍊',
        sortOrder: 10,
        variants: [
          ProductVariant(id: 'esjeruk-original', name: 'Original'),
          ProductVariant(id: 'esjeruk-susu', name: 'Susu', priceDelta: 2000),
          ProductVariant(id: 'esjeruk-madu', name: 'Madu', priceDelta: 2000),
          ProductVariant(
            id: 'esjeruk-yakult',
            name: 'Yakult',
            priceDelta: 3000,
          ),
        ],
      ),
      Product(
        id: 'prod-jeruk-hangat',
        categoryId: 'cat-jeruk-hangat',
        image: 'assets/images/products/jeruk-hangat.jpg',
        name: 'Jeruk Hangat',
        description:
            'Jeruk hangat yang menenangkan, cocok dinikmati kapan saja.',
        price: 6000,
        emoji: '🍵',
        sortOrder: 11,
        variants: [
          ProductVariant(id: 'jerukhangat-original', name: 'Original'),
          ProductVariant(
            id: 'jerukhangat-susu',
            name: 'Susu',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'jerukhangat-madu',
            name: 'Madu',
            priceDelta: 2000,
          ),
          ProductVariant(
            id: 'jerukhangat-yakult',
            name: 'Yakult',
            priceDelta: 3000,
          ),
        ],
      ),
      Product(
        id: 'prod-juice-kurma',
        categoryId: 'cat-juice-kurma',
        image: 'assets/images/products/juice-kurma.jpg',
        name: 'Juice Kurma',
        description:
            'Juice kurma lembut dan manis alami, tersedia varian buah.',
        price: 10000,
        emoji: '🥤',
        sortOrder: 12,
        variants: [
          ProductVariant(id: 'kurma-original', name: 'Original'),
          ProductVariant(id: 'kurma-alpukat', name: 'Alpukat'),
          ProductVariant(
            id: 'kurma-alpukat-kurma',
            name: 'Kurma Alpukat',
            priceDelta: 5000,
          ),
          ProductVariant(
            id: 'kurma-pisang',
            name: 'Kurma Pisang',
            priceDelta: 5000,
          ),
        ],
      ),
    ];

    const zones = <DeliveryZone>[
      DeliveryZone(
        id: 'zone-sekitar',
        name: 'Sekitar Kedai (0-2 km)',
        fee: 5000,
      ),
      DeliveryZone(id: 'zone-dalam', name: 'Dalam Kota (2-7 km)', fee: 8000),
      DeliveryZone(id: 'zone-luar', name: 'Luar Kota (7-15 km)', fee: 12000),
    ];

    const couriers = <Courier>[
      Courier(id: 'courier-andi', name: 'Andi', phone: '0813-1111-2222'),
      Courier(id: 'courier-rizky', name: 'Rizky', phone: '0813-3333-4444'),
      Courier(
        id: 'courier-dedi',
        name: 'Dedi',
        phone: '0813-5555-6666',
        available: false,
      ),
    ];

    const tables = <TableSpot>[
      TableSpot(id: 'table-a1', code: 'A1', label: 'Meja A1'),
      TableSpot(id: 'table-a2', code: 'A2', label: 'Meja A2'),
      TableSpot(id: 'table-a3', code: 'A3', label: 'Meja A3'),
      TableSpot(id: 'table-b1', code: 'B1', label: 'Meja B1'),
      TableSpot(id: 'table-b2', code: 'B2', label: 'Meja B2'),
      TableSpot(id: 'table-b3', code: 'B3', label: 'Meja B3'),
    ];

    const settings = StoreSettings(
      name: 'Kedai Ummi',
      tagline: 'Masakan rumahan, rasa istimewa',
      description:
          'Kedai Ummi menyajikan aneka makanan dan minuman rumahan dengan bahan segar setiap hari.',
      address: 'Jl. Sukajadi No. 88, Bandung',
      phone: '0812-3456-7890',
      isOpen: true,
      openHours: '09.00 - 21.00',
      bankName: 'BCA',
      bankNumber: '1234567890',
      bankHolder: 'Kedai Ummi',
      qrisNote:
          'QRIS resmi Kedai Ummi tersedia di kasir. Silakan scan dan unggah bukti pembayaran.',
    );

    final deliveryItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-kebab',
        image: 'assets/images/products/kebab.jpg',
        name: 'Kebab',
        emoji: '🌯',
        variantName: 'Daging Keju',
        unitPrice: 9000,
        qty: 2,
      ),
      const OrderItem(
        productId: 'prod-es-jeruk',
        image: 'assets/images/products/es-jeruk.jpg',
        name: 'Es Jeruk',
        emoji: '🍊',
        variantName: 'Original',
        unitPrice: 6000,
        qty: 1,
      ),
    ];
    final pendingItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-nasi-goreng',
        image: 'assets/images/products/nasi-goreng.jpg',
        name: 'Nasi Goreng',
        emoji: '🍚',
        variantName: 'Ayam',
        unitPrice: 13000,
        qty: 1,
      ),
      const OrderItem(
        productId: 'prod-es-jeruk',
        image: 'assets/images/products/es-jeruk.jpg',
        name: 'Es Jeruk',
        emoji: '🍊',
        variantName: 'Susu',
        unitPrice: 8000,
        qty: 1,
      ),
    ];
    final dineInItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-bakso',
        image: 'assets/images/products/bakso.jpg',
        name: 'Bakso',
        emoji: '🍲',
        variantName: 'Komplit',
        unitPrice: 14000,
        qty: 1,
      ),
      const OrderItem(
        productId: 'prod-mie-ayam',
        image: 'assets/images/products/mie-ayam.jpg',
        name: 'Mie Ayam',
        emoji: '🍜',
        variantName: 'Mie Ayam',
        unitPrice: 8000,
        qty: 1,
      ),
    ];
    final burgerItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-burger',
        image: 'assets/images/products/burger.jpg',
        name: 'Burger',
        emoji: '🍔',
        variantName: 'Daging Spesial',
        unitPrice: 11000,
        qty: 1,
      ),
      const OrderItem(
        productId: 'prod-es-jeruk',
        image: 'assets/images/products/es-jeruk.jpg',
        name: 'Es Jeruk',
        emoji: '🍊',
        variantName: 'Madu',
        unitPrice: 8000,
        qty: 1,
      ),
    ];
    final onDeliveryItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-kebab',
        image: 'assets/images/products/kebab.jpg',
        name: 'Kebab',
        emoji: '🌯',
        variantName: 'Spesial',
        unitPrice: 11000,
        qty: 2,
      ),
      const OrderItem(
        productId: 'prod-juice-kurma',
        image: 'assets/images/products/juice-kurma.jpg',
        name: 'Juice Kurma',
        emoji: '🥤',
        variantName: 'Kurma Alpukat',
        unitPrice: 15000,
        qty: 1,
      ),
    ];
    final readyItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-miso',
        image: 'assets/images/products/miso.jpg',
        name: 'Miso',
        emoji: '🍥',
        variantName: 'Komplit',
        unitPrice: 15000,
        qty: 1,
      ),
    ];
    final rejectedItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-lotek',
        image: 'assets/images/products/lotek.jpg',
        name: 'Lotek',
        emoji: '🥗',
        variantName: 'Telur',
        unitPrice: 13000,
        qty: 1,
      ),
    ];
    final completedItems = <OrderItem>[
      const OrderItem(
        productId: 'prod-nasi-goreng',
        image: 'assets/images/products/nasi-goreng.jpg',
        name: 'Nasi Goreng',
        emoji: '🍚',
        variantName: 'Minas',
        unitPrice: 12000,
        qty: 2,
      ),
      const OrderItem(
        productId: 'prod-es-jeruk',
        image: 'assets/images/products/es-jeruk.jpg',
        name: 'Es Jeruk',
        emoji: '🍊',
        variantName: 'Yakult',
        unitPrice: 9000,
        qty: 1,
      ),
    ];

    final created1 = now.subtract(const Duration(days: 2, hours: 3));
    final created2 = now.subtract(const Duration(hours: 3));
    final created3 = now.subtract(const Duration(minutes: 75));
    final created4 = now.subtract(const Duration(days: 1, hours: 4));
    final created5 = now.subtract(const Duration(minutes: 45));
    final created6 = now.subtract(const Duration(minutes: 20));
    final created7 = now.subtract(const Duration(days: 3, hours: 2));
    final created8 = now.subtract(const Duration(hours: 5));

    final orders = <Order>[
      Order(
        id: 'order-1',
        orderNumber: _orderNo(created1, 1),
        userId: 'user-budi',
        customerName: 'Budi Santoso',
        customerPhone: '0812-9876-5432',
        serviceType: ServiceType.delivery,
        addressText: 'Jl. Melati No. 12, RT 03/RW 05, Sukajadi, Bandung',
        zoneName: 'Sekitar Kedai (0-2 km)',
        items: deliveryItems,
        subtotal: 24000,
        deliveryFee: 5000,
        total: 29000,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.qris,
        paymentStatus: PaymentStatus.paid,
        createdAt: created1,
        updatedAt: created1.add(const Duration(hours: 2)),
        courierId: 'courier-andi',
        courierName: 'Andi',
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created1),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created1.add(const Duration(minutes: 4)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created1.add(const Duration(minutes: 11)),
          ),
          TimelineEntry(
            status: OrderStatus.outForDelivery,
            at: created1.add(const Duration(minutes: 32)),
            note: 'Diantar oleh Andi',
          ),
          TimelineEntry(
            status: OrderStatus.completed,
            at: created1.add(const Duration(hours: 2)),
          ),
        ],
      ),
      Order(
        id: 'order-2',
        orderNumber: _orderNo(created2, 2),
        userId: 'user-budi',
        customerName: 'Budi Santoso',
        customerPhone: '0812-9876-5432',
        serviceType: ServiceType.takeaway,
        items: pendingItems,
        subtotal: 21000,
        deliveryFee: 0,
        total: 21000,
        status: OrderStatus.pendingConfirmation,
        paymentMethod: PaymentMethod.transfer,
        paymentStatus: PaymentStatus.pending,
        createdAt: created2,
        updatedAt: created2,
        note: 'Sambal dipisah ya, terima kasih.',
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created2),
        ],
      ),
      Order(
        id: 'order-3',
        orderNumber: _orderNo(created3, 3),
        userId: 'user-budi',
        customerName: 'Budi Santoso',
        customerPhone: '0812-9876-5432',
        serviceType: ServiceType.dineIn,
        tableCode: 'A2',
        items: dineInItems,
        subtotal: 22000,
        deliveryFee: 0,
        total: 22000,
        status: OrderStatus.preparing,
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.unpaid,
        createdAt: created3,
        updatedAt: created3.add(const Duration(minutes: 8)),
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created3),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created3.add(const Duration(minutes: 3)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created3.add(const Duration(minutes: 8)),
          ),
        ],
      ),
      Order(
        id: 'order-4',
        orderNumber: _orderNo(created4, 4),
        userId: 'user-siti',
        customerName: 'Siti Rahayu',
        customerPhone: '0813-2211-8899',
        serviceType: ServiceType.takeaway,
        items: burgerItems,
        subtotal: 19000,
        deliveryFee: 0,
        total: 19000,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.cash,
        paymentStatus: PaymentStatus.paid,
        createdAt: created4,
        updatedAt: created4.add(const Duration(minutes: 25)),
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created4),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created4.add(const Duration(minutes: 2)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created4.add(const Duration(minutes: 6)),
          ),
          TimelineEntry(
            status: OrderStatus.readyForPickup,
            at: created4.add(const Duration(minutes: 18)),
          ),
          TimelineEntry(
            status: OrderStatus.completed,
            at: created4.add(const Duration(minutes: 25)),
          ),
        ],
      ),
      Order(
        id: 'order-5',
        orderNumber: _orderNo(created5, 5),
        userId: 'user-siti',
        customerName: 'Siti Rahayu',
        customerPhone: '0813-2211-8899',
        serviceType: ServiceType.delivery,
        addressText: 'Jl. Setiabudi No. 210, Lantai 2, Bandung',
        zoneName: 'Dalam Kota (2-7 km)',
        items: onDeliveryItems,
        subtotal: 37000,
        deliveryFee: 8000,
        total: 45000,
        status: OrderStatus.outForDelivery,
        paymentMethod: PaymentMethod.transfer,
        paymentStatus: PaymentStatus.paid,
        createdAt: created5,
        updatedAt: created5.add(const Duration(minutes: 28)),
        courierId: 'courier-rizky',
        courierName: 'Rizky',
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created5),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created5.add(const Duration(minutes: 3)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created5.add(const Duration(minutes: 9)),
          ),
          TimelineEntry(
            status: OrderStatus.outForDelivery,
            at: created5.add(const Duration(minutes: 28)),
            note: 'Diantar oleh Rizky',
          ),
        ],
      ),
      Order(
        id: 'order-6',
        orderNumber: _orderNo(created6, 6),
        userId: 'user-siti',
        customerName: 'Siti Rahayu',
        customerPhone: '0813-2211-8899',
        serviceType: ServiceType.takeaway,
        items: readyItems,
        subtotal: 15000,
        deliveryFee: 0,
        total: 15000,
        status: OrderStatus.readyForPickup,
        paymentMethod: PaymentMethod.qris,
        paymentStatus: PaymentStatus.paid,
        createdAt: created6,
        updatedAt: created6.add(const Duration(minutes: 12)),
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created6),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created6.add(const Duration(minutes: 1)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created6.add(const Duration(minutes: 4)),
          ),
          TimelineEntry(
            status: OrderStatus.readyForPickup,
            at: created6.add(const Duration(minutes: 12)),
          ),
        ],
      ),
      Order(
        id: 'order-7',
        orderNumber: _orderNo(created7, 7),
        userId: 'user-andi',
        customerName: 'Andi Pratama',
        customerPhone: '0857-3322-1100',
        serviceType: ServiceType.delivery,
        addressText: 'Jl. Cihampelas No. 45, Bandung',
        zoneName: 'Sekitar Kedai (0-2 km)',
        items: rejectedItems,
        subtotal: 13000,
        deliveryFee: 5000,
        total: 18000,
        status: OrderStatus.rejected,
        paymentMethod: PaymentMethod.qris,
        paymentStatus: PaymentStatus.rejected,
        rejectionReason: 'Stok lotek telur habis saat pesanan dikonfirmasi.',
        createdAt: created7,
        updatedAt: created7.add(const Duration(minutes: 7)),
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created7),
          TimelineEntry(
            status: OrderStatus.rejected,
            at: created7.add(const Duration(minutes: 7)),
            note: 'Stok lotek telur habis.',
          ),
        ],
      ),
      Order(
        id: 'order-8',
        orderNumber: _orderNo(created8, 8),
        userId: 'user-andi',
        customerName: 'Andi Pratama',
        customerPhone: '0857-3322-1100',
        serviceType: ServiceType.takeaway,
        items: completedItems,
        subtotal: 33000,
        deliveryFee: 0,
        total: 33000,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.transfer,
        paymentStatus: PaymentStatus.paid,
        createdAt: created8,
        updatedAt: created8.add(const Duration(minutes: 22)),
        timeline: [
          TimelineEntry(status: OrderStatus.pendingConfirmation, at: created8),
          TimelineEntry(
            status: OrderStatus.confirmed,
            at: created8.add(const Duration(minutes: 2)),
          ),
          TimelineEntry(
            status: OrderStatus.preparing,
            at: created8.add(const Duration(minutes: 7)),
          ),
          TimelineEntry(
            status: OrderStatus.readyForPickup,
            at: created8.add(const Duration(minutes: 16)),
          ),
          TimelineEntry(
            status: OrderStatus.completed,
            at: created8.add(const Duration(minutes: 22)),
          ),
        ],
      ),
    ];

    return {
      'users': users,
      'addresses': addresses,
      'categories': categories,
      'products': products,
      'zones': zones,
      'couriers': couriers,
      'tables': tables,
      'settings': settings,
      'orders': orders,
      'orderCounter': orders.length,
    };
  }

  static String _orderNo(DateTime date, int counter) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'KU-${date.year}$month$day-${counter.toString().padLeft(4, '0')}';
  }
}
