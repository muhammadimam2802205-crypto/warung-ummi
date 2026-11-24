import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ummie/data/local_store.dart';
import 'package:ummie/main.dart';
import 'package:ummie/state/providers.dart';

Future<LocalStore> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 820);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({'onboarding_seen': true});
  final store = await LocalStore.create();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [localStoreProvider.overrideWithValue(store)],
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: const KedaiUmmiApp(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

Future<void> loginCustomer(WidgetTester tester) async {
  final emailField = find.byType(TextFormField).at(0);
  await tester.ensureVisible(emailField);
  await tester.pumpAndSettle();
  await tester.enterText(emailField, 'budi@mail.com');
  await tester.enterText(find.byType(TextFormField).at(1), '123456');
  final submit = find.text('Masuk');
  await tester.ensureVisible(submit);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// Menutup snackbar yang menutupi tombol di bagian bawah layar.
Future<void> dismissSnackBars(WidgetTester tester) async {
  final messenger = tester.state<ScaffoldMessengerState>(
    find.byType(ScaffoldMessenger).first,
  );
  messenger.clearSnackBars();
  await tester.pumpAndSettle();
}

/// Menambahkan produk pertama pada grid menu ke keranjang.
Future<void> addFirstProductToCart(WidgetTester tester) async {
  await openTab(tester, 'Menu');
  await tester.tap(find.text('Kebab').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah ke Keranjang'));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
  await tester.pumpAndSettle();
  // Snackbar "ditambahkan ke keranjang" menutupi tombol bawah layar.
  await dismissSnackBars(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkout takeaway membuat pesanan baru', (tester) async {
    final store = await pumpApp(tester);
    await loginCustomer(tester);
    await addFirstProductToCart(tester);

    await openTab(tester, 'Keranjang');
    expect(find.text('Kebab'), findsWidgets);
    await tester.tap(find.text('Lanjut ke Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pumpAndSettle();

    expect(find.text('Menunggu Konfirmasi'), findsWidgets);
    final newOrder = store.orders.first;
    expect(find.textContaining(newOrder.orderNumber), findsWidgets);
    expect(store.orders.length, 9);
    expect(store.orders.first.items.single.name, 'Kebab');
    expect(store.orders.first.serviceType.name, 'takeaway');
  });

  testWidgets('checkout dine-in memvalidasi kode meja', (tester) async {
    final store = await pumpApp(tester);
    await loginCustomer(tester);
    await addFirstProductToCart(tester);

    await openTab(tester, 'Keranjang');
    await tester.tap(find.text('Lanjut ke Checkout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dine-In'));
    await tester.pumpAndSettle();

    // Kode meja salah harus ditolak.
    await tester.enterText(find.byType(TextField).first, 'ZZ9');
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('tidak valid'), findsOneWidget);
    expect(store.orders.length, 8);

    // Tunggu snackbar hilang agar tidak menutupi tombol.
    await dismissSnackBars(tester);

    // Kode meja valid melanjutkan pesanan.
    await tester.enterText(find.byType(TextField).first, 'A1');
    await tester.tap(find.text('Buat Pesanan'));
    await tester.pumpAndSettle();
    expect(store.orders.length, 9);
    expect(store.orders.first.tableCode, 'A1');
    expect(store.orders.first.serviceType.name, 'dineIn');
  });
}
