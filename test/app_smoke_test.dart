import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ummie/data/local_store.dart';
import 'package:ummie/main.dart';
import 'package:ummie/state/providers.dart';

Future<void> pumpApp(WidgetTester tester) async {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('menampilkan halaman login saat belum masuk', (tester) async {
    await pumpApp(tester);
    expect(find.text('Selamat Datang 👋'), findsOneWidget);
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Daftar Sekarang'), findsOneWidget);
    expect(find.text('Masuk sebagai tamu'), findsOneWidget);
  });

  testWidgets('masuk sebagai tamu membuka home', (tester) async {
    await pumpApp(tester);
    final guest = find.text('Masuk sebagai tamu');
    await tester.ensureVisible(guest);
    await tester.pumpAndSettle();
    await tester.tap(guest);
    await tester.pumpAndSettle();
    expect(find.textContaining('Mau makan apa'), findsOneWidget);
  });

  testWidgets('login admin membuka dashboard', (tester) async {
    await pumpApp(tester);
    await login(tester, 'admin@kedaiummi.id', 'admin123');
    expect(find.text('PANEL OPERASIONAL'), findsOneWidget);
    expect(find.text('Pesanan Masuk'), findsOneWidget);
  });

  testWidgets('login pelanggan membuka home', (tester) async {
    await pumpApp(tester);
    await login(tester, 'budi@mail.com', '123456');
    expect(find.textContaining('Mau makan apa'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Menu Populer'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Menu Populer'), findsOneWidget);
  });

  testWidgets('kredensial salah menampilkan pesan error', (tester) async {
    await pumpApp(tester);
    await login(tester, 'budi@mail.com', 'salah');
    expect(find.text('Kata sandi salah.'), findsOneWidget);
  });
}
