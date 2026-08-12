import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const red = Color(0xFFE2231A);
const yellow = Color(0xFFFFC107);
const green = Color(0xFF1F5E3A);
const cream = Color(0xFFF2E6C9);

const supabaseUrl = 'https://yovjbqtazkreruvxoawf.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdmpicXRhemtyZXJ1dnhvYXdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1NjA1NTgsImV4cCI6MjEwMjEzNjU1OH0.4uwUVON1aNdH1D1UKMzNaOn5xplGf1ffwNkcwSw_30U';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const ZecapaoApp());
}

String money(num value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

class Store {
  final String id, name, slug, description;
  final double deliveryFee, minOrder;
  final int estimatedMinutes;
  final bool isOpen;

  Store.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        name = m['name'] ?? '',
        slug = m['slug'] ?? '',
        description = m['description'] ?? '',
        deliveryFee = double.tryParse('${m['delivery_fee'] ?? 0}') ?? 0,
        minOrder = double.tryParse('${m['min_order'] ?? 0}') ?? 0,
        estimatedMinutes = m['estimated_minutes'] ?? 40,
        isOpen = m['is_open'] ?? false;

  String get localLogo {
    const logos = {
      'zecafe': 'Ativos/Marca/zecafe.jpg',
      'cafe-duvalle': 'Ativos/Marca/cafe_duvalle.jpg',
      'frutos': 'Ativos/Marca/frutos.jpg',
      'garimpo-burger': 'Ativos/Marca/garimpo_burger.jpg',
    };
    return logos[slug] ?? 'Ativos/Marca/zecapao_app_icon.png';
  }
}

class Product {
  final String id, storeId, name, description, category;
  final double price;

  Product.fromMap(Map<String, dynamic> m)
      : id = m['id'],
        storeId = m['store_id'],
        name = m['name'] ?? '',
        description = m['description'] ?? '',
        category = m['category'] ?? '',
        price = double.tryParse('${m['price'] ?? 0}') ?? 0;
}

class CartLine {
  final Product product;
  int quantity;
  CartLine(this.product, {this.quantity = 1});
  double get total => product.price * quantity;
}

class Repo {
  final client = Supabase.instance.client;

  Future<List<Store>> stores() async {
    final data = await client.from('stores').select().eq('is_active', true).order('name');
    return (data as List).map((e) => Store.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Product>> products(String storeId) async {
    final data = await client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('is_available', true)
        .order('sort_order');
    return (data as List).map((e) => Product.fromMap(Map<String, dynamic>.from(e))).toList();
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
    final result = await client.rpc('create_guest_order', params: {
      'p_store_id': store.id,
      'p_customer_name': name,
      'p_customer_phone': phone,
      'p_delivery_address': address,
      'p_payment_method': payment,
      'p_notes': notes,
      'p_items': items.map((e) => {'product_id': e.product.id, 'quantity': e.quantity}).toList(),
    });
    return result.toString();
  }

  Future<Map<String, dynamic>?> orderStatus(String orderId) async {
    final data = await client.rpc('get_guest_order_status', params: {'p_order_id': orderId});
    final list = data as List;
    return list.isEmpty ? null : Map<String, dynamic>.from(list.first);
  }
}

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Zé Capão Delivery',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F4EC),
          colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red, secondary: yellow),
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const SignupPage(),
      );
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool terms = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 28),
              Center(child: Image.asset('Ativos/Marca/zecapao_app_icon.png', height: 108)),
              const SizedBox(height: 24),
              const Text('Chegue mais. 🌵', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Seu pedido agora vai de verdade para o estabelecimento.', style: TextStyle(color: Colors.black54, fontSize: 15)),
              const SizedBox(height: 24),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Seu nome', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'WhatsApp', prefixIcon: Icon(Icons.phone_outlined))),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: terms,
                onChanged: (v) => setState(() => terms = v ?? false),
                title: const Text('Aceito os termos e a política de privacidade', style: TextStyle(fontSize: 13)),
              ),
              FilledButton(
                onPressed: terms
                    ? () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomePage(
                              customerName: name.text.trim().isEmpty ? 'Cliente' : name.text.trim(),
                              phone: phone.text.trim(),
                            ),
                          ),
                        )
                    : null,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                child: const Text('ENTRAR NO ZÉ CAPÃO', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Operação 1.1 • Status automático', style: TextStyle(color: Colors.black38))),
            ],
          ),
        ),
      );
}

class HomePage extends StatefulWidget {
  final String customerName, phone;
  const HomePage({super.key, required this.customerName, required this.phone});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repo = Repo();
  late Future<List<Store>> future;

  @override
  void initState() {
    super.initState();
    future = repo.stores();
  }

  Future<void> reload() async {
    final next = repo.stores();
    setState(() => future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(children: [
                  Image.asset('Ativos/Marca/zecapao_app_icon.png', width: 52, height: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Salve, ${widget.customerName}!', style: const TextStyle(color: Colors.black54)),
                      const Text('Vale do Capão • BA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    ]),
                  ),
                  const Icon(Icons.cloud_done, color: green),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(26)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pediu. Chegou.', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                    SizedBox(height: 5),
                    Text('Pedido, loja e status conectados à operação.', style: TextStyle(color: cream)),
                  ]),
                ),
                const SizedBox(height: 22),
                const Text('Estabelecimentos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                FutureBuilder<List<Store>>(
                  future: future,
                  builder: (_, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
                    }
                    if (snap.hasError) return Text('Erro: ${snap.error}');
                    final stores = snap.data ?? [];
                    if (stores.isEmpty) return const Text('Nenhum estabelecimento disponível.');
                    return Column(
                      children: stores.map((s) => Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: SizedBox(width: 60, height: 60, child: Image.asset(s.localLogo, fit: BoxFit.contain)),
                          title: Row(children: [
                            Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w900))),
                            Text(s.isOpen ? 'ABERTO' : 'FECHADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: s.isOpen ? green : red)),
                          ]),
                          subtitle: Text('${s.description}\n${s.estimatedMinutes} min • Entrega ${money(s.deliveryFee)}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: s.isOpen
                              ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StorePage(
                                        store: s,
                                        customerName: widget.customerName,
                                        phone: widget.phone,
                                        repo: repo,
                                      ),
                                    ),
                                  )
                              : null,
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

class StorePage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  const StorePage({super.key, required this.store, required this.customerName, required this.phone, required this.repo});
  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Product>> future;
  final cart = <String, CartLine>{};

  @override
  void initState() {
    super.initState();
    future = widget.repo.products(widget.store.id);
  }

  double get subtotal => cart.values.fold(0, (s, e) => s + e.total);
  int get count => cart.values.fold(0, (s, e) => s + e.quantity);
  void add(Product p) => setState(() => cart.update(p.id, (e) => e..quantity++, ifAbsent: () => CartLine(p)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.w900))),
        bottomNavigationBar: cart.isEmpty
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(
                          store: widget.store,
                          customerName: widget.customerName,
                          phone: widget.phone,
                          repo: widget.repo,
                          items: cart.values.toList(),
                        ),
                      ),
                    ),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    child: Text('CARRINHO • $count item(ns) • ${money(subtotal)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
        body: FutureBuilder<List<Product>>(
          future: future,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
            final products = snap.data ?? [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Image.asset(widget.store.localLogo, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
                Text(widget.store.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                Text('${widget.store.estimatedMinutes} min • Entrega ${money(widget.store.deliveryFee)}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 22),
                const Text('Cardápio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                ...products.map((p) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.restaurant_menu, color: red),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${p.description}\n${money(p.price)}'),
                    isThreeLine: true,
                    trailing: IconButton.filled(onPressed: () => add(p), icon: const Icon(Icons.add)),
                  ),
                )),
              ],
            );
          },
        ),
      );
}

class CheckoutPage extends StatefulWidget {
  final Store store;
  final String customerName, phone;
  final Repo repo;
  final List<CartLine> items;
  const CheckoutPage({super.key, required this.store, required this.customerName, required this.phone, required this.repo, required this.items});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final address = TextEditingController();
  final notes = TextEditingController();
  String payment = 'pix';
  bool sending = false;

  double get subtotal => widget.items.fold(0, (s, e) => s + e.total);
  double get total => subtotal + widget.store.deliveryFee;

  @override
  void dispose() {
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (address.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o endereço ou referência.')));
      return;
    }
    setState(() => sending = true);
    try {
      final orderId = await widget.repo.createOrder(
        store: widget.store,
        name: widget.customerName,
        phone: widget.phone,
        address: address.text.trim(),
        payment: payment,
        notes: notes.text.trim(),
        items: widget.items,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessPage(orderId: orderId, repo: widget.repo)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível enviar: $e')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Finalizar pedido', style: TextStyle(fontWeight: FontWeight.w900))),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            ...widget.items.map((e) => ListTile(title: Text('${e.quantity}× ${e.product.name}'), trailing: Text(money(e.total)))),
            const Divider(),
            ListTile(title: const Text('Subtotal'), trailing: Text(money(subtotal))),
            ListTile(title: const Text('Entrega'), trailing: Text(money(widget.store.deliveryFee))),
            ListTile(
              title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              trailing: Text(money(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Endereço / pousada / referência', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: payment,
              decoration: const InputDecoration(labelText: 'Pagamento', prefixIcon: Icon(Icons.payments_outlined)),
              items: const [
                DropdownMenuItem(value: 'pix', child: Text('Pix')),
                DropdownMenuItem(value: 'card', child: Text('Cartão na entrega')),
                DropdownMenuItem(value: 'cash', child: Text('Dinheiro')),
              ],
              onChanged: (v) => setState(() => payment = v ?? 'pix'),
            ),
            const SizedBox(height: 12),
            TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Observações')),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: sending ? null : send,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: sending
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('ENVIAR PEDIDO REAL', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
}

class OrderSuccessPage extends StatefulWidget {
  final String orderId;
  final Repo repo;
  const OrderSuccessPage({super.key, required this.orderId, required this.repo});
  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  Map<String, dynamic>? order;
  Timer? timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
    timer = Timer.periodic(const Duration(seconds: 4), (_) => refresh(silent: true));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> refresh({bool silent = false}) async {
    try {
      final next = await widget.repo.orderStatus(widget.orderId);
      if (!mounted) return;
      if (next != null) setState(() { order = next; loading = false; });
    } catch (_) {
      if (!silent && mounted) setState(() => loading = false);
    }
  }

  String label(String s) => const {
        'pending': 'Aguardando confirmação',
        'accepted': 'Aceito',
        'preparing': 'Em preparo',
        'ready': 'Pronto',
        'out_for_delivery': 'Saiu para entrega',
        'delivered': 'Entregue',
        'cancelled': 'Cancelado',
      }[s] ?? s;

  IconData iconFor(String s) => const {
        'pending': Icons.schedule,
        'accepted': Icons.thumb_up_alt_outlined,
        'preparing': Icons.restaurant,
        'ready': Icons.check_circle_outline,
        'out_for_delivery': Icons.delivery_dining,
        'delivered': Icons.home_filled,
        'cancelled': Icons.cancel_outlined,
      }[s] ?? Icons.receipt_long;

  @override
  Widget build(BuildContext context) {
    final status = '${order?['status'] ?? 'pending'}';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 44, backgroundColor: status == 'cancelled' ? red : green, child: Icon(iconFor(status), color: Colors.white, size: 44)),
                const SizedBox(height: 20),
                const Text('Pedido enviado!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Pedido #${widget.orderId.substring(0, 8).toUpperCase()}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 18),
                if (loading) const CircularProgressIndicator(),
                if (!loading)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(18)),
                    child: Column(children: [
                      const Text('STATUS ATUAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 7),
                      Text(label(status), textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: status == 'cancelled' ? red : green)),
                      const SizedBox(height: 7),
                      if (order != null) Text('Total ${money(double.tryParse('${order!['total']}') ?? 0)}'),
                      const SizedBox(height: 10),
                      const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.sync, size: 15, color: Colors.black45),
                        SizedBox(width: 5),
                        Text('Atualização automática', style: TextStyle(fontSize: 12, color: Colors.black45)),
                      ]),
                    ]),
                  ),
                const SizedBox(height: 20),
                OutlinedButton.icon(onPressed: refresh, icon: const Icon(Icons.refresh), label: const Text('ATUALIZAR AGORA')),
                const SizedBox(height: 8),
                FilledButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('VOLTAR AO INÍCIO')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
