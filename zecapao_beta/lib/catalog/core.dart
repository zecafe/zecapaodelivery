import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const red = Color(0xFFE2231A);
const yellow = Color(0xFFFFC107);
const green = Color(0xFF1F5E3A);
const cream = Color(0xFFF2E6C9);
const bg = Color(0xFFF8F4EC);

String money(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
String valecoinMoney(int cents) => money(cents / 100);

double cashbackRate(num eligible) {
  if (eligible <= 0) return 0;
  if (eligible <= 50) return 0.01;
  if (eligible <= 150) return 0.02;
  return 0.03;
}

int cashbackCoins(num eligible) => (eligible * cashbackRate(eligible) * 100).floor();

class Store {
  final String id, name, slug, description;
  final double deliveryFee;
  final int estimatedMinutes;
  final bool isOpen;

  Store.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        name = m['name'] ?? '',
        slug = m['slug'] ?? '',
        description = m['description'] ?? '',
        deliveryFee = double.tryParse('${m['delivery_fee'] ?? 0}') ?? 0,
        estimatedMinutes = m['estimated_minutes'] ?? 40,
        isOpen = m['is_open'] ?? false;

  String get logo => {
        'zecafe': 'Ativos/Marca/zecafe.jpg',
        'cafe-duvalle': 'Ativos/Marca/cafe_duvalle.jpg',
        'frutos': 'Ativos/Marca/frutos.jpg',
        'garimpo-burger': 'Ativos/Marca/garimpo_burger.jpg',
      }[slug] ??
      'Ativos/Marca/zecapao_app_icon.png';
}

class Product {
  final String id, storeId, name, description, category, imageUrl, badge;
  final double price;
  final bool featured;

  Product.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        storeId = m['store_id'],
        name = m['name'] ?? '',
        description = m['description'] ?? '',
        category = (m['category'] ?? 'Outros').toString(),
        imageUrl = (m['image_url'] ?? '').toString(),
        badge = (m['badge'] ?? '').toString(),
        price = double.tryParse('${m['price'] ?? 0}') ?? 0,
        featured = m['featured'] ?? false;
}

class ProductOption {
  final String id, name;
  final double priceDelta;
  ProductOption.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        name = m['name'] ?? '',
        priceDelta = double.tryParse('${m['price_delta'] ?? 0}') ?? 0;
}

class OptionGroup {
  final String id, name;
  final int minSelect, maxSelect;
  final bool required;
  final List<ProductOption> options;

  OptionGroup.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        name = m['name'] ?? '',
        minSelect = m['min_select'] ?? 0,
        maxSelect = m['max_select'] ?? 1,
        required = m['is_required'] ?? false,
        options = ((m['product_options'] ?? []) as List)
            .map((e) => ProductOption.fromMap(Map<String, dynamic>.from(e)))
            .toList();
}

class CartLine {
  final Product product;
  final List<ProductOption> options;
  int quantity;

  CartLine(this.product, {this.options = const [], this.quantity = 1});

  double get unitPrice => product.price + options.fold(0, (s, o) => s + o.priceDelta);
  double get total => unitPrice * quantity;
  String get key => '${product.id}:${options.map((e) => e.id).join(',')}';
  String get optionText => options.map((e) => e.name).join(', ');
}

class ValeCoinBalance {
  final int balanceCoins;
  final int lifetimeEarnedCoins;
  final int lifetimeSpentCoins;
  final DateTime? expiresNextAt;

  const ValeCoinBalance({
    required this.balanceCoins,
    required this.lifetimeEarnedCoins,
    required this.lifetimeSpentCoins,
    required this.expiresNextAt,
  });

  factory ValeCoinBalance.zero() => const ValeCoinBalance(
        balanceCoins: 0,
        lifetimeEarnedCoins: 0,
        lifetimeSpentCoins: 0,
        expiresNextAt: null,
      );
}

class Repo {
  final client = Supabase.instance.client;

  Future<List<Store>> stores() async {
    final d = await client.from('stores').select().eq('is_active', true).order('name');
    return (d as List).map((e) => Store.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Product>> products(String storeId) async {
    final d = await client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('is_available', true)
        .order('sort_order');
    return (d as List).map((e) => Product.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<OptionGroup>> options(String productId) async {
    final d = await client
        .from('product_option_groups')
        .select('id,name,min_select,max_select,is_required,sort_order,product_options(id,name,price_delta,is_available,sort_order)')
        .eq('product_id', productId)
        .order('sort_order');
    return (d as List).map((e) => OptionGroup.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<ValeCoinBalance> valecoinBalance(String phone) async {
    if (phone.trim().isEmpty) return ValeCoinBalance.zero();
    final d = await client.rpc('get_valecoin_balance', params: {'p_phone': phone});
    final rows = d as List;
    if (rows.isEmpty) return ValeCoinBalance.zero();
    final m = Map<String, dynamic>.from(rows.first);
    return ValeCoinBalance(
      balanceCoins: m['balance_cents'] ?? 0,
      lifetimeEarnedCoins: m['lifetime_earned_cents'] ?? 0,
      lifetimeSpentCoins: m['lifetime_spent_cents'] ?? 0,
      expiresNextAt: m['expires_next_at'] == null ? null : DateTime.tryParse('${m['expires_next_at']}'),
    );
  }

  Future<String> createOrder({
    required Store store,
    required String name,
    required String phone,
    required String address,
    required String payment,
    required String notes,
    required List<CartLine> items,
  }) async {
    final r = await client.rpc('create_guest_order', params: {
      'p_store_id': store.id,
      'p_customer_name': name,
      'p_customer_phone': phone,
      'p_delivery_address': address,
      'p_payment_method': payment,
      'p_notes': notes,
      'p_items': items
          .map((e) => {
                'product_id': e.product.id,
                'quantity': e.quantity,
                'option_ids': e.options.map((o) => o.id).toList(),
              })
          .toList(),
    });
    return r.toString();
  }

  Future<Map<String, dynamic>?> orderStatus(String id) async {
    final d = await client.rpc('get_guest_order_status', params: {'p_order_id': id});
    final l = d as List;
    return l.isEmpty ? null : Map<String, dynamic>.from(l.first);
  }
}
