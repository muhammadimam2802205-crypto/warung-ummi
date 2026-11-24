import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ummie/data/local_store.dart';
import 'package:ummie/data/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed data awal tersedia dan dapat dibaca kembali', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.create();

    expect(store.products.length, greaterThanOrEqualTo(8));
    expect(store.categories.length, greaterThanOrEqualTo(4));
    expect(store.users.any((user) => user.role == UserRole.admin), isTrue);
    expect(store.tables.any((table) => table.code == 'A1'), isTrue);
    expect(store.settings.isOpen, isTrue);
    expect(store.orders.length, 8);

    final product = store.products.first;
    store.saveProducts([product.copyWith(price: 99999)]);
    expect(store.products.first.price, 99999);
  });

  test('nomor transaksi bertambah setiap pesanan baru', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.create();
    final first = store.nextOrderCounter();
    final second = store.nextOrderCounter();
    expect(second, first + 1);
  });

  test('login admin dan pelanggan menggunakan seed', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await LocalStore.create();
    final admin = store.users.firstWhere(
      (user) => user.email == 'admin@kedaiummi.id',
    );
    expect(admin.role, UserRole.admin);
    expect(admin.password, 'admin123');
  });
}
