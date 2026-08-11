import 'package:flutter/material.dart';

void main() {
  runApp(const ZecapaoApp());
}

const red = Color(0xFFE2231A);
const yellow = Color(0xFFFFC107);
const green = Color(0xFF1F5E3A);
const cream = Color(0xFFF2E6C9);

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

String money(double value) => 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

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
  final emailController = TextEditingController();
  bool acceptedTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void enterApp() {
    final name = nameController.text.trim().isEmpty
        ? 'capoeira'
        : nameController.text.trim();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(user: name)),
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
                height: 118,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chegue mais. 🌵',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Um cadastro rapidinho e o Vale inteiro fica na sua mão.',
              style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Como podemos te chamar?',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail (opcional)',
                prefixIcon: Icon(Icons.mail_outline),
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: acceptedTerms,
              onChanged: (value) {
                setState(() => acceptedTerms = value ?? false);
              },
              title: const Text(
                'Aceito os termos e a política de privacidade',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: acceptedTerms ? enterApp : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text(
                'ENTRAR NO ZÉ CAPÃO',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'Beta 0.4 • Vale do Capão, Bahia',
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _header(),
            const SizedBox(height: 16),
            _searchBox(),
            const SizedBox(height: 16),
            _hero(),
            const SizedBox(height: 24),
            const Text(
              'Categorias',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
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
            const SizedBox(height: 26),
            const Text(
              'Parceiros do Capão',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...partners.map(
              (partner) => PartnerCard(partner: partner),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'Ativos/Marca/zecapao_app_icon.png',
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salve, $user!', style: const TextStyle(color: Colors.black54)),
              const Row(
                children: [
                  Icon(Icons.location_on, color: red, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Vale do Capão • BA',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.notifications_none),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.black45),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'O que você quer pedir hoje?',
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
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
            'O Vale inteiro na sua mão.',
            style: TextStyle(color: cream, fontWeight: FontWeight.w700),
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
          CircleAvatar(
            radius: 26,
            backgroundColor: cream,
            child: Icon(icon, color: red),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class PartnerCard extends StatelessWidget {
  final Partner partner;

  const PartnerCard({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: SizedBox(
          width: 64,
          height: 64,
          child: Image.asset(partner.logo, fit: BoxFit.contain),
        ),
        title: Text(
          partner.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${partner.subtitle}\n25–40 min • Entrega'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PartnerPage(partner: partner),
            ),
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
  final List<Product> cart = [];

  double get total {
    return cart.fold<double>(0, (sum, product) => sum + product.price);
  }

  void addToCart(Product product) {
    setState(() => cart.add(product));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.partner.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
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
                        builder: (_) => CartPage(items: List<Product>.from(cart)),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Text(
                    'VER CARRINHO • ${cart.length} item(ns) • ${money(total)}',
                  ),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 160,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(widget.partner.logo, fit: BoxFit.contain),
          ),
          const SizedBox(height: 18),
          Text(
            widget.partner.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(widget.partner.subtitle, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.star, color: yellow, size: 18),
              Text(
                ' 4,8  •  25–40 min  •  Entrega',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Cardápio',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Fotos reais dos produtos entram no próximo lote de mídia.',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...menu.map(
            (product) => ProductCard(
              product: product,
              onAdd: () => addToCart(product),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.restaurant_menu, color: red, size: 30),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${product.description}\n${money(product.price)}'),
        isThreeLine: true,
        trailing: IconButton.filled(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Product> items;

  const CartPage({super.key, required this.items});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const deliveryFee = 7.0;

  double get subtotal {
    return widget.items.fold<double>(0, (sum, product) => sum + product.price);
  }

  @override
  Widget build(BuildContext context) {
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seu carrinho',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          for (var i = 0; i < widget.items.length; i++)
            ListTile(
              title: Text(widget.items[i].name),
              subtitle: Text(money(widget.items[i].price)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  setState(() => widget.items.removeAt(i));
                },
              ),
            ),
          const Divider(),
          ListTile(
            title: const Text('Subtotal'),
            trailing: Text(money(subtotal)),
          ),
          const ListTile(
            title: Text('Entrega'),
            trailing: Text('R\$ 7,00'),
          ),
          ListTile(
            title: const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            trailing: Text(
              money(total),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          const SizedBox(height: 14),
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
              labelText: 'Observações do pedido',
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: widget.items.isEmpty
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderSuccess(total: total),
                      ),
                    );
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text(
              'CONFIRMAR PEDIDO',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSuccess extends StatelessWidget {
  final double total;

  const OrderSuccess({super.key, required this.total});

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
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: green,
                  child: Icon(Icons.check, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Pedido recebido!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text('Total ${money(total)}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                const Text(
                  'Agora o Zé coloca o pedido na trilha. Você acompanha cada etapa por aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(user: 'capoeira'),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('VOLTAR AO INÍCIO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
