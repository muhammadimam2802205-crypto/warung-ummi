import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ummie/core/widgets/app_widgets.dart';
import 'package:ummie/core/widgets/kedai_refresh.dart';
import 'package:ummie/data/local_store.dart';
import 'package:ummie/main.dart';
import 'package:ummie/state/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('KedaiRefreshIndicator memicu onRefresh saat ditarik', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KedaiRefreshIndicator(
            onRefresh: () async {
              calls++;
              await Future<void>.delayed(const Duration(milliseconds: 40));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const <Widget>[SizedBox(height: 1400)],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 360));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(calls, 1);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AnimatedRupiah dan BounceBadge tampil benar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              AnimatedRupiah(value: 53000),
              BounceBadge(count: 3, child: Icon(Icons.shopping_bag_rounded)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp 53.000'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('onboarding tampil sekali dan menyimpan status', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
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

    expect(find.textContaining('Selamat Datang'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_seen'), isTrue);
    expect(prefs.getBool('onboarding_completed'), isTrue);
    expect(find.text('Selamat Datang 👋'), findsOneWidget);
  });
}
