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
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? logoUrl;
  final double deliveryFee;
  final double minOrder;
  final int estimatedMinutes;
  final bool isOpen;

  const Store({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logoUrl,
    required this.deliveryFee,
    required this.minOrder,
    required this.estimatedMinutes,
    required this.isOpen,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      description: map['description'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      deliveryFee: double.tryParse('${map['delivery_fee'] ?? 0}') ?? 0,
      minOrder: double.tryParse('${map['min_order'] ?? 0}') ?? 0,
      estimatedMinutes: map['estimated_minutes'] as int? ?? 40,
      isOpen: map['is_open'] as bool? ?? false,
    );
  }

  String get localLogo {
    const logos = <String, String>{
      'zecafe': 'Ativos/Marca/zecafe.jpg',
      'cafe-duvalle': 'Ativos/Marca/cafe_duvalle.jpg',
      'frutos': 'Ativos/Marca/frutos.jpg',
      'garimpo-burger': 'Ativos/Marca/garimpo_burger.jpg',
    };
    return logos[slug] ?? 'Ativos/Marca/zecapao_app_icon.png';
  }
}

class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      storeId: map['store_id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: double.tryParse('${map['price'] ?? 0}') ?? 0,
      imageUrl: map['image_url'] as String?,
      category: map['category'] as String? ?? '',
    );
  }
}

class CartLine {
  final Product product;
  int quantity;

  CartLine(this.product, {this.quantity = 1});

  double get total => product.price * quantity;
}

class MarketplaceRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Store>> fetchStores() async {
    final data = await client
        .from('stores')
        .select('id,name,slug,description,logo_url,delivery_fee,min_order,estimated_minutes,is_open')
        .eq('is_active', true)
        .order('name');
    return (data as List<dynamic>)
        .map((item) => Store.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> fetchProducts(String storeId) async {
    final data = await client
        .from('products')
        .select('id,store_id,name,description,price,image_url,category')
        .eq('store_id', storeId)
        .eq('is_available', true)
        .order('sort_order');
    return (data as List<dynamic>)
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}

class ZecapaoApp extends StatelessWidget {
  const ZecapaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zé Capão Delivery',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F4EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          primary: red,
          secondary: yellow,
        ),
      ),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool acceptedTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void enterApp() {
    final name = nameController.text.trim().isEmpty
        ? 'capoeira'
        : nameController.text.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'Ativos/Marca/zecapao_app_icon.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Chegue mais. 🌵',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agora o Zé Capão já conversa com a nuvem. Seu cadastro ainda é simples, mas os estabelecimentos e produtos passam a vir do servidor.',
              style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.45),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Como podemos te chamar?',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: acceptedTerms,
              onChanged: (value) => setState(() => acceptedTerms = value ?? false),
              title: const Text(
                'Aceito os termos e a política de privacidade',
                style: TextStyle(fontSize: 13),
              ),
            ),
            FilledButton(
              onPressed: acceptedTerms ? enterApp : null,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: const Text(
                'ENTRAR NO ZÉ CAPÃO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Foundation 1.0 • Supabase conectado',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repository = MarketplaceRepository();
  late Future<List<Store>> storesFuture;
  String query = '';

  @override
  void initState() {
    super.initState();
    storesFuture = repository.fetchStores();
  }

  Future<void> refresh() async {
    setState(() {
      storesFuture = repository.fetchStores();
    });
    await storesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
            children: [
              Row(
                children: [
                  Image.asset(
                    'Ativos/Marca/zecapao_app_icon.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salve, ${widget.userName}!',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const Text(
                          'Vale do Capão • BA',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.cloud_done_outlined, color: green),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pediu. Chegou.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Agora com dados reais vindos do servidor.',
                      style: TextStyle(color: cream, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar estabelecimento...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Estabelecimentos online',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Store>>(
                future: storesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return ErrorCard(
                      message: 'Não consegui consultar o servidor.\n${snapshot.error}',
                      onRetry: refresh,
                    );
                  }

                  final allStores = snapshot.data ?? const <Store>[];
                  final filtered = allStores.where((store) {
                    final text = '${store.name} ${store.description}'.toLowerCase();
                    return text.contains(query.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Nenhum estabelecimento encontrado.')),
                    );
                  }

                  return Column(
                    children: filtered
                        .map((store) => StoreCard(store: store, repository: repository))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const ErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: red, size: 36),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('TENTAR NOVAMENTE')),
          ],
        ),
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Store store;
  final MarketplaceRepository repository;

  const StoreCard({super.key, required this.store, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SizedBox(
          width: 64,
          height: 64,
          child: store.logoUrl != null && store.logoUrl!.isNotEmpty
              ? Image.network(
                  store.logoUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(store.localLogo, fit: BoxFit.contain),
                )
              : Image.asset(store.localLogo, fit: BoxFit.contain),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                store.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: store.isOpen ? const Color(0xFFE5F5E8) : const Color(0xFFFFE4E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                store.isOpen ? 'ABERTO' : 'FECHADO',
                style: TextStyle(
                  color: store.isOpen ? green : red,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${store.description}\n${store.estimatedMinutes} min • Entrega ${money(store.deliveryFee)}',
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorePage(store: store, repository: repository),
            ),
          );
        },
      ),
    );
  }
}

class StorePage extends StatefulWidget {
  final Store store;
  final MarketplaceRepository repository;

  const StorePage({
    super.key,
    required this.store,
    required this.repository,
  });

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Product>> productsFuture;
  final Map<String, CartLine> cart = {};

  @override
  void initState() {
    super.initState();
    productsFuture = widget.repository.fetchProducts(widget.store.id);
  }

  int get itemCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  double get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);

  void add(Product product) {
    setState(() {
      final current = cart[product.id];
      if (current == null) {
        cart[product.id] = CartLine(product);
      } else {
        current.quantity++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(
                          store: widget.store,
                          lines: cart.values.toList(),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: Text(
                    'VER CARRINHO • $itemCount item(ns) • ${money(subtotal)}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: widget.store.logoUrl != null && widget.store.logoUrl!.isNotEmpty
                ? Image.network(
                    widget.store.logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(widget.store.localLogo),
                  )
                : Image.asset(widget.store.localLogo),
          ),
          const SizedBox(height: 18),
          Text(
            widget.store.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(widget.store.description, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            '${widget.store.estimatedMinutes} min • Entrega ${money(widget.store.deliveryFee)} • Pedido mín. ${money(widget.store.minOrder)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          const Text('Cardápio do servidor', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          FutureBuilder<List<Product>>(
            future: productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snapshot.hasError) {
                return Text('Erro ao carregar cardápio: ${snapshot.error}');
              }
              final products = snapshot.data ?? const <Product>[];
              if (products.isEmpty) {
                return const Text('Este estabelecimento ainda não cadastrou produtos.');
              }
              return Column(
                children: products.map((product) {
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.coffee, color: red, size: 30),
                      ),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text('${product.description}\n${money(product.price)}'),
                      isThreeLine: true,
                      trailing: IconButton.filled(
                        onPressed: () => add(product),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Store store;
  final List<CartLine> lines;

  const CartPage({super.key, required this.store, required this.lines});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get subtotal => widget.lines.fold(0, (sum, line) => sum + line.total);
  double get total => subtotal + widget.store.deliveryFee;

  void change(CartLine line, int delta) {
    setState(() {
      line.quantity += delta;
      if (line.quantity <= 0) {
        widget.lines.remove(line);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seu carrinho', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(widget.store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...widget.lines.map((line) {
            return Card(
              child: ListTile(
                title: Text(line.product.name),
                subtitle: Text('${money(line.product.price)} cada'),
                trailing: SizedBox(
                  width: 128,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: () => change(line, -1), icon: const Icon(Icons.remove_circle_outline)),
                      Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      IconButton(onPressed: () => change(line, 1), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Divider(height: 30),
          ListTile(title: const Text('Subtotal'), trailing: Text(money(subtotal))),
          ListTile(title: const Text('Entrega'), trailing: Text(money(widget.store.deliveryFee))),
          ListTile(
            title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            trailing: Text(
              money(total),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Endereço / pousada / referência',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Observações',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: widget.lines.isEmpty
                ? null
                : () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Fundação conectada ✅'),
                        content: const Text(
                          'Este carrinho já usa produtos reais do Supabase. A gravação do pedido no banco será a próxima etapa.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: const Text('VALIDAR CARRINHO', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
