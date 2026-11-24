import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ummie/data/local_store.dart';
import 'package:ummie/main.dart';
import 'package:ummie/state/providers.dart';

/// Memastikan tampilan tidak overflow pada perangkat layar kecil.
Future<void> pumpAppAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
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
}

Future<void> login(WidgetTester tester, String email, String password) async {
  final emailField = find.byType(TextFormField).at(0);
  await tester.ensureVisible(emailField);
  await tester.pumpAndSettle();
  await tester.enterText(emailField, email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('halaman login muat pada layar 320x568', (tester) async {
    await pumpAppAt(tester, const Size(320, 568));
    expect(find.text('Selamat Datang 👋'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home & menu pelanggan muat pada layar 360x640', (tester) async {
    await pumpAppAt(tester, const Size(360, 640));
    await login(tester, 'budi@mail.com', '123456');
    expect(find.textContaining('Mau makan apa'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Menu');
    expect(find.text('Menu Kami'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Keranjang');
    expect(find.text('Keranjang masih kosong'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Pesanan');
    expect(find.text('Pesanan Saya'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Profil');
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard & tab admin muat pada layar 360x640', (tester) async {
    await pumpAppAt(tester, const Size(360, 640));
    await login(tester, 'admin@kedaiummi.id', 'admin123');
    expect(find.text('PANEL OPERASIONAL'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Pesanan');
    expect(find.text('Pesanan'), findsWidgets);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Menu');
    expect(find.text('KATALOG KEDAI'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await openTab(tester, 'Setelan');
    expect(find.text('Setelan Kedai'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
