import 'package:flutter/material.dart';

void main() {
  runApp(const ZecapaoApp());
}

const red = Color(0xFFE2231A);
const yellow = Color(0xFFFFC107);
const green = Color(0xFF1F5E3A);
const cream = Color(0xFFF2E6C9);

String money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

class Partner {
  final String name;
  final String subtitle;
  final String logo;

  const Partner(this.name, this.subtitle, this.logo);
}

class Product {
  final String name;
  final String description;
  final double price;

  const Product(this.name, this.description, this.price);
}

const partners = <Partner>[
  Partner('Zecafé', 'Cafés • Doces • Experiências', 'Ativos/Marca/zecafe.jpg'),
  Partner('Café DuValle', 'Café • Brunch', 'Ativos/Marca/cafe_duvalle.jpg'),
  Partner('Frutos', 'Sucos • Focaccias • Toasts', 'Ativos/Marca/frutos.jpg'),
  Partner('Garimpo Burger', 'Hambúrguer artesanal', 'Ativos/Marca/garimpo_burger.jpg'),
  Partner('Gatto Sete Bistrô', 'Bistrô • Gastronomia', 'Ativos/Marca/gatto_sete.jpg'),
  Partner('Green', 'Gastronomia', 'Ativos/Marca/green.jpg'),
  Partner('Mandioca Gastrobar', 'Restaurante • Bar', 'Ativos/Marca/mandioca.jpg'),
  Partner('Ôxe Restô', 'Restaurante', 'Ativos/Marca/oxe.jpg'),
  Partner('Paulistano Capão', 'Restaurante', 'Ativos/Marca/paulistano.jpg'),
  Partner('Pico do Açaí', 'Açaí • Lanches', 'Ativos/Marca/pico_acai.jpg'),
  Partner('Pizza Lab', 'Pizza • Music & Drinks', 'Ativos/Marca/pizza_lab.jpg'),
  Partner('Comercial Bastos', 'Mercado • Conveniência', 'Ativos/Marca/comercial_bastos.jpg'),
  Partner('Alma Bistrô', 'Bistrô', 'Ativos/Marca/alma.jpg'),
  Partner('Dona Beli', 'Comida caseira', 'Ativos/Marca/dona_beli.jpg'),
  Partner('Budha Restaurante', 'Restaurante', 'Ativos/Marca/budha.jpg'),
  Partner('Cabeça de Gelo', 'Turismo de aventura • Sucos', 'Ativos/Marca/cabeca_de_gelo.jpg'),
  Partner('Capão Grande', 'Pizzaria integral', 'Ativos/Marca/capao_grande.jpg'),
  Partner('CBD', 'Loja local', 'Ativos/Marca/cbd.jpg'),
  Partner('Charruá Restaurante', 'Restaurante', 'Ativos/Marca/charrua.jpg'),
];

const menu = <Product>[
  Product('Especial da casa', 'Seleção preparada pelo parceiro', 32),
  Product('Queridinho do Vale', 'Um dos mais pedidos da casa', 28),
  Product('Combo Capão', 'Principal + acompanhamento', 39),
  Product('Bebida da casa', 'Opção refrescante', 12),
];

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
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  bool terms = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  void enter() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(
          userName: name.text.trim().isEmpty ? 'capoeira' : name.text.trim(),
          phone: phone.text.trim(),
          email: email.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'Ativos/Marca/zecapao_app_icon.png',
                height: 108,
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
              'Um cadastro rapidinho e o Vale inteiro fica na sua mão.',
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 26),
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Como podemos te chamar?',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail (opcional)',
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: terms,
              onChanged: (value) => setState(() => terms = value ?? false),
              title: const Text(
                'Aceito os termos e a política de privacidade',
                style: TextStyle(fontSize: 13),
              ),
            ),
            FilledButton(
              onPressed: terms ? enter : null,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: const Text(
                'ENTRAR NO ZÉ CAPÃO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Beta 0.5 • Vale do Capão, Bahia',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final String userName;
  final String phone;
  final String email;

  const MainShell({
    super.key,
    required this.userName,
    required this.phone,
    required this.email,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  final Set<String> favorites = {};
  final List<String> orders = [];

  void toggleFavorite(String name) {
    setState(() {
      favorites.contains(name) ? favorites.remove(name) : favorites.add(name);
    });
  }

  void addOrder(String description) {
    setState(() {
      orders.insert(0, description);
      index = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        userName: widget.userName,
        favorites: favorites,
        toggleFavorite: toggleFavorite,
      ),
      SearchTab(
        favorites: favorites,
        toggleFavorite: toggleFavorite,
      ),
      OrdersTab(orders: orders),
      const EventsTab(),
      ProfileTab(
        userName: widget.userName,
        phone: widget.phone,
        email: widget.email,
        favorites: favorites,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.event_outlined), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final String userName;
  final Set<String> favorites;
  final ValueChanged<String> toggleFavorite;

  const HomeTab({
    super.key,
    required this.userName,
    required this.favorites,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Row(
            children: [
              Image.asset('Ativos/Marca/zecapao_app_icon.png', width: 52, height: 52, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salve, $userName!', style: const TextStyle(color: Colors.black54)),
                    const Text(
                      'Vale do Capão • BA',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(28)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pediu. Chegou.',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text('O Vale inteiro na sua mão.', style: TextStyle(color: cream, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Categorias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CategoryChip('Comida', Icons.restaurant),
              CategoryChip('Bebidas', Icons.local_bar),
              CategoryChip('Mercado', Icons.shopping_basket),
              CategoryChip('Cafés', Icons.coffee),
              CategoryChip('Eventos', Icons.event),
              CategoryChip('Pousadas', Icons.bed),
              CategoryChip('Experiências', Icons.landscape),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Parceiros do Capão', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...partners.map(
            (partner) => PartnerCard(
              partner: partner,
              favorite: favorites.contains(partner.name),
              onFavorite: () => toggleFavorite(partner.name),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchTab extends StatefulWidget {
  final Set<String> favorites;
  final ValueChanged<String> toggleFavorite;

  const SearchTab({
    super.key,
    required this.favorites,
    required this.toggleFavorite,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = partners.where((partner) {
      final text = '${partner.name} ${partner.subtitle}'.toLowerCase();
      return text.contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: false,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Buscar restaurante, café, mercado...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: filtered.map((partner) {
                return PartnerCard(
                  partner: partner,
                  favorite: widget.favorites.contains(partner.name),
                  onFavorite: () => widget.toggleFavorite(partner.name),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const CategoryChip(this.label, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          CircleAvatar(radius: 26, backgroundColor: cream, child: Icon(icon, color: red)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final bool favorite;
  final VoidCallback onFavorite;

  const PartnerCard({
    super.key,
    required this.partner,
    required this.favorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(width: 62, height: 62, child: Image.asset(partner.logo, fit: BoxFit.contain)),
        title: Text(partner.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${partner.subtitle}\n25–40 min • Entrega'),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onFavorite,
          icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? red : null),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PartnerPage(partner: partner)),
          );
        },
      ),
    );
  }
}

class PartnerPage extends StatefulWidget {
  final Partner partner;

  const PartnerPage({super.key, required this.partner});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  final Map<Product, int> cart = {};

  int get itemCount => cart.values.fold(0, (sum, quantity) => sum + quantity);

  double get subtotal {
    double total = 0;
    cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  void add(Product product) {
    setState(() => cart[product] = (cart[product] ?? 0) + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partner.name, style: const TextStyle(fontWeight: FontWeight.w900))),
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
                          partner: widget.partner,
                          initialCart: Map<Product, int>.from(cart),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  child: Text('VER CARRINHO • $itemCount item(ns) • ${money(subtotal)}'),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 160,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Image.asset(widget.partner.logo, fit: BoxFit.contain),
          ),
          const SizedBox(height: 18),
          Text(widget.partner.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(widget.partner.subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.star, color: yellow, size: 18),
              Text(' 4,8  •  25–40 min  •  Entrega', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Cardápio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text(
            'A estrutura já está pronta para receber fotos reais e itens específicos de cada parceiro.',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...menu.map(
            (product) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.restaurant_menu, color: red, size: 30),
                ),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${product.description}\n${money(product.price)}'),
                isThreeLine: true,
                trailing: IconButton.filled(onPressed: () => add(product), icon: const Icon(Icons.add)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Partner partner;
  final Map<Product, int> initialCart;

  const CartPage({
    super.key,
    required this.partner,
    required this.initialCart,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<Product, int> cart;
  String payment = 'Pix';
  final address = TextEditingController();
  final notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    cart = Map<Product, int>.from(widget.initialCart);
  }

  @override
  void dispose() {
    address.dispose();
    notes.dispose();
    super.dispose();
  }

  double get subtotal {
    double total = 0;
    cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  void change(Product product, int delta) {
    setState(() {
      final next = (cart[product] ?? 0) + delta;
      if (next <= 0) {
        cart.remove(product);
      } else {
        cart[product] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const deliveryFee = 7.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Seu carrinho', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ...cart.entries.map((entry) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                          Text(money(entry.key.price)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => change(entry.key, -1), icon: const Icon(Icons.remove_circle_outline)),
                    Text('${entry.value}', style: const TextStyle(fontWeight: FontWeight.w900)),
                    IconButton(onPressed: () => change(entry.key, 1), icon: const Icon(Icons.add_circle_outline)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          TextField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'Endereço / pousada / referência',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notes,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observações do pedido',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Forma de pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          RadioListTile<String>(
            value: 'Pix',
            groupValue: payment,
            title: const Text('Pix'),
            secondary: const Icon(Icons.pix),
            onChanged: (value) => setState(() => payment = value ?? 'Pix'),
          ),
          RadioListTile<String>(
            value: 'Cartão na entrega',
            groupValue: payment,
            title: const Text('Cartão na entrega'),
            secondary: const Icon(Icons.credit_card),
            onChanged: (value) => setState(() => payment = value ?? 'Cartão na entrega'),
          ),
          RadioListTile<String>(
            value: 'Dinheiro',
            groupValue: payment,
            title: const Text('Dinheiro'),
            secondary: const Icon(Icons.payments_outlined),
            onChanged: (value) => setState(() => payment = value ?? 'Dinheiro'),
          ),
          const Divider(),
          ListTile(title: const Text('Subtotal'), trailing: Text(money(subtotal))),
          const ListTile(title: Text('Entrega'), trailing: Text('R\$ 7,00')),
          ListTile(
            title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            trailing: Text(money(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: cart.isEmpty
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderSuccess(
                          partner: widget.partner.name,
                          total: total,
                          payment: payment,
                        ),
                      ),
                    );
                  },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: const Text('CONFIRMAR PEDIDO', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class OrderSuccess extends StatelessWidget {
  final String partner;
  final double total;
  final String payment;

  const OrderSuccess({
    super.key,
    required this.partner,
    required this.total,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 42, backgroundColor: green, child: Icon(Icons.check, color: Colors.white, size: 46)),
                const SizedBox(height: 22),
                const Text('Pedido recebido!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(partner, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                Text('${money(total)} • $payment'),
                const SizedBox(height: 22),
                const OrderStep(icon: Icons.receipt_long, text: 'Pedido recebido', active: true),
                const OrderStep(icon: Icons.restaurant, text: 'Em preparação', active: false),
                const OrderStep(icon: Icons.delivery_dining, text: 'Saiu para entrega', active: false),
                const OrderStep(icon: Icons.home, text: 'Entregue', active: false),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('VOLTAR AO PARCEIRO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OrderStep extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool active;

  const OrderStep({super.key, required this.icon, required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        backgroundColor: active ? green : Colors.black12,
        child: Icon(icon, color: active ? Colors.white : Colors.black45),
      ),
      title: Text(text, style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.w500)),
    );
  }
}

class OrdersTab extends StatelessWidget {
  final List<String> orders;

  const OrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pedidos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Expanded(
              child: orders.isEmpty
                  ? const Center(child: Text('Seus próximos pedidos aparecerão aqui.', style: TextStyle(color: Colors.black45)))
                  : ListView(children: orders.map((order) => ListTile(leading: const Icon(Icons.receipt_long), title: Text(order))).toList()),
            ),
          ],
        ),
      ),
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Eventos', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF191919), borderRadius: BorderRadius.circular(28)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAPÃO REGGAE VALE', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Música • Cultura • Natureza • Conexão', style: TextStyle(color: yellow)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String userName;
  final String phone;
  final String email;
  final Set<String> favorites;

  const ProfileTab({
    super.key,
    required this.userName,
    required this.phone,
    required this.email,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Seu Zé Capão', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          ListTile(leading: const Icon(Icons.person_outline), title: Text(userName), subtitle: const Text('Nome')), 
          ListTile(leading: const Icon(Icons.phone_outlined), title: Text(phone.isEmpty ? 'Não informado' : phone), subtitle: const Text('WhatsApp')),
          ListTile(leading: const Icon(Icons.mail_outline), title: Text(email.isEmpty ? 'Não informado' : email), subtitle: const Text('E-mail')),
          const Divider(),
          const Text('Favoritos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (favorites.isEmpty)
            const Text('Você ainda não favoritou nenhum parceiro.', style: TextStyle(color: Colors.black45)),
          ...favorites.map((name) => ListTile(leading: const Icon(Icons.favorite, color: red), title: Text(name))),
        ],
      ),
    );
  }
}
