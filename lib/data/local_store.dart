import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'seed_data.dart';

/// Penyimpanan lokal perangkat berbasis SharedPreferences.
/// Lapisan ini terisolasi agar mudah diganti implementasi API di kemudian hari.
class LocalStore {
  LocalStore._(this._prefs);

  final SharedPreferences _prefs;

  static const int _seedVersion = 3;
  static const String _seedKey = 'seed_version';
  static const String _sessionKey = 'session_user_id';

  static Future<LocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    final store = LocalStore._(prefs);
    if ((prefs.getInt(_seedKey) ?? 0) != _seedVersion) {
      await store.resetToSeed();
    }
    return store;
  }

  Future<void> resetToSeed() async {
    final data = SeedData.build();
    await _prefs.setString('users', _encode(data['users']));
    await _prefs.setString('addresses', _encode(data['addresses']));
    await _prefs.setString('categories', _encode(data['categories']));
    await _prefs.setString('products', _encode(data['products']));
    await _prefs.setString('zones', _encode(data['zones']));
    await _prefs.setString('couriers', _encode(data['couriers']));
    await _prefs.setString('tables', _encode(data['tables']));
    await _prefs.setString(
      'settings',
      jsonEncode((data['settings'] as StoreSettings).toJson()),
    );
    await _prefs.setString('orders', _encode(data['orders']));
    await _prefs.setInt('order_counter', data['orderCounter'] as int);
    await _prefs.setInt(_seedKey, _seedVersion);
  }

  String _encode(List<dynamic> items) => jsonEncode(
    items.map((e) => (e as dynamic).toJson() as Map<String, dynamic>).toList(),
  );

  List<T> _readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void _writeList(String key, List<dynamic> items) {
    final encoded = items
        .map((e) => (e as dynamic).toJson() as Map<String, dynamic>)
        .toList();
    unawaited(_prefs.setString(key, jsonEncode(encoded)));
  }

  // ---------- Users ----------
  List<AppUser> get users => _readList('users', AppUser.fromJson);
  void saveUsers(List<AppUser> users) => _writeList('users', users);

  // ---------- Addresses ----------
  List<Address> get addresses => _readList('addresses', Address.fromJson);
  void saveAddresses(List<Address> addresses) =>
      _writeList('addresses', addresses);

  // ---------- Categories ----------
  List<Category> get categories => _readList('categories', Category.fromJson);
  void saveCategories(List<Category> categories) =>
      _writeList('categories', categories);

  // ---------- Products ----------
  List<Product> get products => _readList('products', Product.fromJson);
  void saveProducts(List<Product> products) => _writeList('products', products);

  // ---------- Delivery zones ----------
  List<DeliveryZone> get zones => _readList('zones', DeliveryZone.fromJson);
  void saveZones(List<DeliveryZone> zones) => _writeList('zones', zones);

  // ---------- Couriers ----------
  List<Courier> get couriers => _readList('couriers', Courier.fromJson);
  void saveCouriers(List<Courier> couriers) => _writeList('couriers', couriers);

  // ---------- Tables ----------
  List<TableSpot> get tables => _readList('tables', TableSpot.fromJson);
  void saveTables(List<TableSpot> tables) => _writeList('tables', tables);

  // ---------- Settings ----------
  StoreSettings get settings {
    final raw = _prefs.getString('settings');
    if (raw == null || raw.isEmpty) {
      return StoreSettings.fromJson(
        (SeedData.build()['settings'] as StoreSettings).toJson(),
      );
    }
    return StoreSettings.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  void saveSettings(StoreSettings settings) {
    unawaited(_prefs.setString('settings', jsonEncode(settings.toJson())));
  }

  // ---------- Orders ----------
  List<Order> get orders => _readList('orders', Order.fromJson);
  void saveOrders(List<Order> orders) => _writeList('orders', orders);

  int get orderCounter => _prefs.getInt('order_counter') ?? 0;

  int nextOrderCounter() {
    final next = orderCounter + 1;
    unawaited(_prefs.setInt('order_counter', next));
    return next;
  }

  // ---------- Session ----------
  String? get sessionUserId => _prefs.getString(_sessionKey);

  void setSessionUserId(String? userId) {
    if (userId == null) {
      unawaited(_prefs.remove(_sessionKey));
    } else {
      unawaited(_prefs.setString(_sessionKey, userId));
    }
  }

  // ---------- Cart ----------
  List<CartItem> cartFor(String userId) =>
      _readList('cart_$userId', CartItem.fromJson);

  void saveCart(String userId, List<CartItem> items) =>
      _writeList('cart_$userId', items);

  void clearCart(String userId) {
    unawaited(_prefs.remove('cart_$userId'));
  }
}
